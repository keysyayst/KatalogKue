import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/product.dart';
import '../../../data/sources/products.dart';

class AdminController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();
  
  // Form controllers
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final locationController = TextEditingController();
  
  var editingProduct = Rx<Product?>(null);

  @override
  void onClose() {
    titleController.dispose();
    priceController.dispose();
    locationController.dispose();
    super.onClose();
  }

  List<Product> get products => _productService.getAllProducts();

  void clearForm() {
    titleController.clear();
    priceController.clear();
    locationController.clear();
    editingProduct.value = null;
  }

  void loadProductForEdit(Product product) {
    editingProduct.value = product;
    titleController.text = product.title;
    priceController.text = product.price;
    locationController.text = product.location;
  }

  void deleteProduct(Product product) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Hapus produk "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // TODO: Implement actual delete
              Get.snackbar(
                'Berhasil',
                'Produk "${product.title}" telah dihapus',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
