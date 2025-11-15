import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/product.dart';
import '../../../data/models/meal_model.dart';
import '../../../data/providers/product_api_provider.dart';
import '../../../data/providers/mealdb_api_provider.dart';
import '../../../data/providers/nutrition_api_provider.dart';
import '../../../data/sources/products.dart';
import '../../../data/services/auth_service.dart';

class AdminController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();
  final AuthService _authService = Get.find<AuthService>();
  final ProductApiProvider _apiProvider = ProductApiProvider();
  final MealDBApiProvider _mealDBProvider = MealDBApiProvider();
  final NutritionApiProvider _nutritionProvider = NutritionApiProvider();
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final compositionController = TextEditingController();
  final imageUrlController = TextEditingController();

  var editingProduct = Rx<Product?>(null);
  var selectedImageFile = Rx<File?>(null);
  var isLoading = false.obs;
  var isUploadingImage = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    priceController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    compositionController.dispose();
    imageUrlController.dispose();
    super.onClose();
  }

  List<Product> get products => _productService.getAllProducts();
  bool get isProductsLoading => _productService.isLoading.value;

  Future<void> refreshProducts() async {
    await _productService.loadProducts();
  }

  void clearForm() {
    titleController.clear();
    priceController.clear();
    locationController.clear();
    descriptionController.clear();
    compositionController.clear();
    imageUrlController.clear();
    selectedImageFile.value = null;
    editingProduct.value = null;
  }

  void loadProductForEdit(Product product) {
    editingProduct.value = product;
    titleController.text = product.title;
    priceController.text = product.price;
    locationController.text = product.location;
    descriptionController.text = product.description ?? '';
    compositionController.text = product.composition ?? '';
    imageUrlController.text = product.image;
    selectedImageFile.value = null;
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImageFile.value = File(image.path);
        imageUrlController.clear();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih gambar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImageFile.value = File(image.path);
        imageUrlController.clear();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveProduct() async {
    if (titleController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Judul, harga, dan lokasi harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      Product? result;
      final userId = _authService.currentUser.value?.id;

      if (editingProduct.value != null) {
        // MODE EDIT
        String imageUrl = editingProduct.value!.image;

        // Upload gambar baru jika ada file yang dipilih
        if (selectedImageFile.value != null) {
          isUploadingImage.value = true;

          final imageBytes = await selectedImageFile.value!.readAsBytes();
          final fileName =
              'product_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final uploadedUrl = await _apiProvider.uploadProductImage(
            editingProduct.value!.id,
            imageBytes,
            fileName,
          );

          isUploadingImage.value = false;

          if (uploadedUrl != null) {
            imageUrl = uploadedUrl;
          } else {
            Get.snackbar(
              'Warning',
              'Gagal upload gambar, menggunakan gambar lama',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        }

        final product = Product(
          id: editingProduct.value!.id,
          title: titleController.text.trim(),
          price: priceController.text.trim(),
          location: locationController.text.trim(),
          image: imageUrl,
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          composition: compositionController.text.trim().isEmpty
              ? null
              : compositionController.text.trim(),
        );

        result = await _productService.updateProduct(
          editingProduct.value!.id,
          product,
        );
      } else {
        // MODE CREATE
        if (userId == null) {
          Get.snackbar(
            'Error',
            'User tidak ditemukan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }

        // 1. Buat produk dulu dengan placeholder image
        final tempProduct = Product(
          id: '',
          title: titleController.text.trim(),
          price: priceController.text.trim(),
          location: locationController.text.trim(),
          image: 'https://via.placeholder.com/300',
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          composition: compositionController.text.trim().isEmpty
              ? null
              : compositionController.text.trim(),
        );

        result = await _productService.createProduct(tempProduct, userId);

        // 2. Jika ada gambar, upload dan update produk
        if (result != null && selectedImageFile.value != null) {
          isUploadingImage.value = true;

          final imageBytes = await selectedImageFile.value!.readAsBytes();
          final fileName =
              'product_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final uploadedUrl = await _apiProvider.uploadProductImage(
            result.id,
            imageBytes,
            fileName,
          );

          isUploadingImage.value = false;

          if (uploadedUrl != null) {
            // Update produk dengan URL gambar yang benar
            final updatedProduct = Product(
              id: result.id,
              title: result.title,
              price: result.price,
              location: result.location,
              image: uploadedUrl,
              description: result.description,
              composition: result.composition,
            );

            result = await _productService.updateProduct(
              result.id,
              updatedProduct,
            );
          } else {
            Get.snackbar(
              'Warning',
              'Produk tersimpan, tapi gagal upload gambar',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        }
      }

      if (result != null) {
        Get.back(); // Close dialog/form
        Get.snackbar(
          'Berhasil',
          editingProduct.value != null
              ? 'Produk berhasil diperbarui'
              : 'Produk berhasil ditambahkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        clearForm();
      } else {
        Get.snackbar(
          'Error',
          'Gagal menyimpan produk',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      isUploadingImage.value = false;
    }
  }

  void deleteProduct(Product product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Hapus produk "${product.title}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Get.back();
              isLoading.value = true;

              final success = await _productService.deleteProduct(product.id);
              isLoading.value = false;

              if (success) {
                Get.snackbar(
                  'Berhasil',
                  'Produk "${product.title}" telah dihapus',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Gagal menghapus produk',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void showProductForm({Product? product}) {
    if (product != null) {
      loadProductForEdit(product);
    } else {
      clearForm();
    }

    Get.dialog(
      Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      product != null ? 'Edit Produk' : 'Tambah Produk',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Get.back();
                        clearForm();
                      },
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Preview & Picker
                      Obx(() {
                        Widget imageWidget;

                        if (selectedImageFile.value != null) {
                          // Tampilkan gambar dari file yang dipilih
                          imageWidget = Image.file(
                            selectedImageFile.value!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        } else if (imageUrlController.text.isNotEmpty) {
                          // Tampilkan gambar dari URL (untuk edit)
                          imageWidget =
                              imageUrlController.text.startsWith('http')
                              ? Image.network(
                                  imageUrlController.text,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 50),
                                );
                        } else {
                          // Placeholder
                          imageWidget = Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                            ),
                          );
                        }

                        return Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageWidget,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: showImageSourceDialog,
                                    icon: const Icon(Icons.image),
                                    label: const Text('Pilih Gambar'),
                                  ),
                                ),
                                if (selectedImageFile.value != null) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () =>
                                        selectedImageFile.value = null,
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Hapus gambar',
                                  ),
                                ],
                              ],
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Harga *',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 50.000/toples',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: compositionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Komposisi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        clearForm();
                      },
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => ElevatedButton(
                        onPressed: isLoading.value || isUploadingImage.value
                            ? null
                            : saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading.value || isUploadingImage.value
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isUploadingImage.value
                                        ? 'Upload...'
                                        : 'Menyimpan...',
                                  ),
                                ],
                              )
                            : const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== FITUR BARU: TAMBAH PRODUK DARI MEALDB ==========

  /// Tampilkan dialog pilihan: Manual atau dari MealDB
  void showAddProductOptionsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Tambah Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFFE8C00)),
              title: const Text('Tambah Manual'),
              subtitle: const Text('Isi data produk secara manual'),
              onTap: () {
                Get.back();
                showProductForm();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.restaurant_menu,
                color: Color(0xFFFE8C00),
              ),
              title: const Text('Dari TheMealDB'),
              subtitle: const Text('Pilih dari database dessert'),
              onTap: () {
                Get.back();
                showMealDBBrowser();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Browse desserts dari MealDB API
  void showMealDBBrowser() async {
    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFE8C00),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Mengambil data dari TheMealDB...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final desserts = await _mealDBProvider.getDesserts();
      Get.back(); // Close loading dialog

      if (desserts.isEmpty) {
        Get.snackbar(
          'Info',
          'Tidak ada dessert ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Show desserts in dialog/bottomsheet
      Get.dialog(
        Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFE8C00),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Pilih Dessert dari TheMealDB',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                // List of desserts
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: desserts.length,
                    itemBuilder: (context, index) {
                      final meal = desserts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: meal.strMealThumb.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    meal.strMealThumb,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.cake),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.cake),
                                ),
                          title: Text(
                            meal.strMeal,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('ID: ${meal.idMeal}'),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () => selectMealFromDB(meal),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      Get.back(); // Close loading if still open
      Get.snackbar(
        'Error',
        'Gagal mengambil data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Proses setelah user pilih meal dari list
  void selectMealFromDB(Meal meal) async {
    try {
      Get.back(); // Close meal browser

      // Show loading
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFE8C00),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Mengambil detail produk...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // 1. Get detail meal (untuk ingredients)
      final mealDetail = await _mealDBProvider.getMealDetail(meal.idMeal);

      if (mealDetail == null) {
        Get.back();
        Get.snackbar(
          'Error',
          'Gagal mengambil detail produk',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // 2. Fetch nutrition data dari USDA API
      Map<String, dynamic>? nutritionData;
      try {
        // Improve search query untuk nutrition
        final searchQuery = _improveMealNameForNutrition(mealDetail.strMeal);
        print('🔍 Nutrition search query: $searchQuery');

        final nutritionResult = await _nutritionProvider.searchNutrition(
          searchQuery,
        );

        if (nutritionResult != null) {
          nutritionData = {
            'calories': nutritionResult.calories.toStringAsFixed(1),
            'protein': nutritionResult.protein.toStringAsFixed(1),
            'fat': nutritionResult.fat.toStringAsFixed(1),
            'carbs': nutritionResult.carbs.toStringAsFixed(1),
            'sugar': nutritionResult.sugar.toStringAsFixed(1),
            'fiber': nutritionResult.fiber.toStringAsFixed(1),
          };
          print('✅ Nutrition data found for: ${mealDetail.strMeal}');
        } else {
          print('⚠️ No nutrition data found for: ${mealDetail.strMeal}');
        }
      } catch (e) {
        print('⚠️ Failed to fetch nutrition: $e');
        // Continue tanpa nutrition data
      }

      Get.back(); // Close loading

      // 3. Show form untuk konfirmasi/edit data sebelum save
      showMealConfirmationForm(mealDetail, nutritionData);
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Form konfirmasi sebelum save produk dari MealDB
  void showMealConfirmationForm(Meal meal, Map<String, dynamic>? nutrition) {
    // Set data ke form
    titleController.text = meal.strMeal;
    priceController.text = '100.000/kg'; // Default price
    locationController.text = meal.strArea ?? 'International';
    descriptionController.text =
        meal.strInstructions ?? 'Dessert lezat dari TheMealDB';
    compositionController.text = meal.compositionText;
    imageUrlController.text = meal.strMealThumb;

    Get.dialog(
      Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFE8C00),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Konfirmasi Produk',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        Get.back();
                        clearForm();
                      },
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Preview
                      if (meal.strMealThumb.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            meal.strMealThumb,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 50),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Nutrition Info Banner
                      if (nutrition != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Data nutrisi berhasil diambil dari USDA',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Data nutrisi tidak tersedia',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Harga *',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 100.000/kg',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: compositionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Komposisi',
                          border: OutlineInputBorder(),
                          helperText: 'Diambil otomatis dari TheMealDB',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        clearForm();
                      },
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => ElevatedButton.icon(
                        onPressed: isLoading.value
                            ? null
                            : () => saveMealProduct(nutrition),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFE8C00),
                          foregroundColor: Colors.white,
                        ),
                        icon: isLoading.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          isLoading.value ? 'Menyimpan...' : 'Simpan Produk',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Save produk dari MealDB ke database
  Future<void> saveMealProduct(Map<String, dynamic>? nutrition) async {
    if (titleController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Judul, harga, dan lokasi harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null) {
        Get.snackbar(
          'Error',
          'User tidak ditemukan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      final product = Product(
        id: '',
        title: titleController.text.trim(),
        price: priceController.text.trim(),
        location: locationController.text.trim(),
        image: imageUrlController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        composition: compositionController.text.trim().isEmpty
            ? null
            : compositionController.text.trim(),
        nutrition: nutrition, // Include nutrition data
      );

      final result = await _productService.createProduct(product, userId);

      if (result != null) {
        Get.back(); // Close dialog
        Get.snackbar(
          'Berhasil',
          'Produk dari TheMealDB berhasil ditambahkan${nutrition != null ? ' dengan data nutrisi' : ''}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        clearForm();
      } else {
        Get.snackbar(
          'Error',
          'Gagal menyimpan produk',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper: Improve meal name untuk nutrition search
  /// Mapping nama dessert ke term yang lebih umum untuk USDA API
  String _improveMealNameForNutrition(String mealName) {
    // Convert to lowercase untuk matching
    final nameLower = mealName.toLowerCase();

    // Mapping spesifik dessert ke kategori nutrition
    final Map<String, String> mappings = {
      // Cakes
      'cake': 'cake',
      'chocolate cake': 'chocolate cake',
      'vanilla cake': 'vanilla cake',
      'carrot cake': 'carrot cake',
      'red velvet': 'red velvet cake',
      'cheesecake': 'cheesecake',
      'pound cake': 'pound cake',

      // Pies & Tarts
      'pie': 'pie',
      'apple pie': 'apple pie',
      'pumpkin pie': 'pumpkin pie',
      'cherry pie': 'cherry pie',
      'pecan pie': 'pecan pie',
      'tart': 'tart',

      // Cookies & Biscuits
      'cookie': 'cookie',
      'chocolate chip': 'chocolate chip cookie',
      'oatmeal cookie': 'oatmeal cookie',
      'sugar cookie': 'sugar cookie',
      'biscuit': 'cookie',

      // Brownies & Bars
      'brownie': 'brownie',
      'blondie': 'blondie',

      // Puddings & Custards
      'pudding': 'pudding',
      'custard': 'custard',
      'tiramisu': 'tiramisu',
      'mousse': 'chocolate mousse',

      // Ice Cream & Frozen
      'ice cream': 'ice cream',
      'sorbet': 'sorbet',
      'gelato': 'ice cream',

      // Pastries
      'croissant': 'croissant',
      'danish': 'danish pastry',
      'eclair': 'eclair',
      'macaron': 'macaroon',
      'donut': 'doughnut',
      'doughnut': 'doughnut',

      // Other desserts
      'pancake': 'pancake',
      'waffle': 'waffle',
      'crepe': 'crepe',
      'muffin': 'muffin',
      'scone': 'scone',
      'cupcake': 'cupcake',
      'parfait': 'parfait',
    };

    // Cek apakah ada exact match atau partial match
    for (var entry in mappings.entries) {
      if (nameLower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Jika tidak ada match, coba extract keyword penting
    // Remove common words yang tidak penting untuk nutrition search
    String cleaned = mealName
        .replaceAll(
          RegExp(r'\b(with|and|or|the|a|an)\b', caseSensitive: false),
          '',
        )
        .trim();

    // Limit ke 2-3 kata pertama (lebih spesifik)
    List<String> words = cleaned.split(' ');
    if (words.length > 3) {
      cleaned = words.take(3).join(' ');
    }

    return cleaned.isNotEmpty ? cleaned : mealName;
  }
}
