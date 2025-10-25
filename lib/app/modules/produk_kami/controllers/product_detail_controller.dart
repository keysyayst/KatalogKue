import 'package:get/get.dart';
import '../../../data/models/product.dart'; // <-- Path Relatif
import '../../../data/sources/products.dart'; // <-- Path Relatif

class ProductDetailController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  final product = Rxn<Product>();

  @override
  void onInit() {
    super.onInit();
    String? id = Get.parameters['id'];

    if (id != null) {
      product.value = _productService.getProductById(id);
    }

    if (product.value == null) {
      Get.snackbar('Error', 'Produk tidak ditemukan');
      Get.back();
    }
  }
}
