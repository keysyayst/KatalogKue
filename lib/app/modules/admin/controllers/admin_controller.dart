import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart'; // Pastikan package ini ada

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

  // Translator
  final GoogleTranslator _translator = GoogleTranslator();

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
          nutrition: editingProduct.value!.nutrition,
          // HAPUS CATEGORY DI SINI (Error 1)
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
          // HAPUS CATEGORY DI SINI (Error 2)
        );

        result = await _productService.createProduct(tempProduct, userId);

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
            final updatedProduct = Product(
              id: result.id,
              title: result.title,
              price: result.price,
              location: result.location,
              image: uploadedUrl,
              description: result.description,
              composition: result.composition,
              nutrition: result.nutrition,
              // HAPUS CATEGORY DI SINI (Error 3)
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
        Get.back();
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
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
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(() {
                        Widget imageWidget;
                        if (selectedImageFile.value != null) {
                          imageWidget = Image.file(
                            selectedImageFile.value!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        } else if (imageUrlController.text.isNotEmpty) {
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
                                    child: const Icon(Icons.broken_image),
                                  ),
                                )
                              : Container(
                                  height: 150,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 50),
                                );
                        } else {
                          imageWidget = SizedBox(
                            height: 120,
                            width: 120,
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
                            OutlinedButton.icon(
                              onPressed: showImageSourceDialog,
                              icon: const Icon(Icons.image),
                              label: const Text('Pilih Gambar'),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Judul *'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Harga *'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi *',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: compositionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Komposisi',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
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
                        child: Text(
                          isUploadingImage.value ? 'Uploading...' : 'Simpan',
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
              title: const Text('Dari Otomatis (TheMealDB)'),
              subtitle: const Text('Import resep & nutrisi otomatis'),
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

  void showMealDBBrowser() async {
    try {
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
      Get.back();

      if (desserts.isEmpty) {
        Get.snackbar(
          'Info',
          'Tidak ada dessert ditemukan',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      Get.dialog(
        Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Column(
              children: [
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
      Get.back();
      Get.snackbar(
        'Error',
        'Gagal mengambil data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void selectMealFromDB(Meal meal) async {
    try {
      Get.back();

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
                  Text('Menerjemahkan ke Bahasa Indonesia...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

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

      Map<String, dynamic>? nutritionData;
      try {
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
      }

      String translatedDesc = mealDetail.strInstructions ?? '';
      String translatedComp = mealDetail.compositionText;

      try {
        if (translatedDesc.isNotEmpty) {
          final translation = await _translator.translate(
            translatedDesc,
            from: 'en',
            to: 'id',
          );
          translatedDesc = translation.text;
        }

        if (translatedComp.isNotEmpty) {
          final translation = await _translator.translate(
            translatedComp,
            from: 'en',
            to: 'id',
          );
          translatedComp = translation.text;
        }
      } catch (e) {
        print('❌ Translation error: $e');
      }

      Get.back(); // Tutup dialog loading

      showMealConfirmationForm(
        mealDetail,
        nutritionData,
        translatedDesc,
        translatedComp,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showMealConfirmationForm(
    Meal meal,
    Map<String, dynamic>? nutrition,
    String desc,
    String comp,
  ) {
    titleController.text = meal.strMeal;
    priceController.text = '100.000/kg';
    locationController.text = meal.strArea ?? 'International';

    // GUNAKAN HASIL TRANSLATE
    descriptionController.text = desc;
    compositionController.text = comp;

    imageUrlController.text = meal.strMealThumb;

    Get.dialog(
      Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            children: [
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (meal.strMealThumb.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            meal.strMealThumb,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (nutrition != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Data nutrisi berhasil diambil dari USDA',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
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
                            children: const [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Data nutrisi tidak tersedia',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
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
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi (Bahasa Indonesia)',
                          border: OutlineInputBorder(),
                          helperText: 'Otomatis diterjemahkan',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: compositionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Komposisi (Bahasa Indonesia)',
                          border: OutlineInputBorder(),
                          helperText: 'Otomatis diterjemahkan',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
        nutrition: nutrition,
        // HAPUS CATEGORY (Error 4)
      );

      final result = await _productService.createProduct(product, userId);

      if (result != null) {
        Get.back();
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

  String _improveMealNameForNutrition(String mealName) {
    final nameLower = mealName.toLowerCase();
    final Map<String, String> mappings = {
      'cake': 'cake',
      'chocolate cake': 'chocolate cake',
      'vanilla cake': 'vanilla cake',
      'carrot cake': 'carrot cake',
      'red velvet': 'red velvet cake',
      'cheesecake': 'cheesecake',
      'pound cake': 'pound cake',
      'pie': 'pie',
      'apple pie': 'apple pie',
      'pumpkin pie': 'pumpkin pie',
      'cherry pie': 'cherry pie',
      'pecan pie': 'pecan pie',
      'tart': 'tart',
      'cookie': 'cookie',
      'chocolate chip': 'chocolate chip cookie',
      'oatmeal cookie': 'oatmeal cookie',
      'sugar cookie': 'sugar cookie',
      'biscuit': 'cookie',
      'brownie': 'brownie',
      'blondie': 'blondie',
      'pudding': 'pudding',
      'custard': 'custard',
      'tiramisu': 'tiramisu',
      'mousse': 'chocolate mousse',
      'ice cream': 'ice cream',
      'sorbet': 'sorbet',
      'gelato': 'ice cream',
      'croissant': 'croissant',
      'danish': 'danish pastry',
      'eclair': 'eclair',
      'macaron': 'macaroon',
      'donut': 'doughnut',
      'doughnut': 'doughnut',
      'pancake': 'pancake',
      'waffle': 'waffle',
      'crepe': 'crepe',
      'muffin': 'muffin',
      'scone': 'scone',
      'cupcake': 'cupcake',
      'parfait': 'parfait',
    };

    for (var entry in mappings.entries) {
      if (nameLower.contains(entry.key)) {
        return entry.value;
      }
    }

    String cleaned = mealName
        .replaceAll(
          RegExp(r'\b(with|and|or|the|a|an)\b', caseSensitive: false),
          '',
        )
        .trim();

    List<String> words = cleaned.split(' ');
    if (words.length > 3) {
      cleaned = words.take(3).join(' ');
    }

    return cleaned.isNotEmpty ? cleaned : mealName;
  }
}
