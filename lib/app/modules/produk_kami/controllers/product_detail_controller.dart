import 'package:get/get.dart';
import '../../../data/models/product.dart'; 
import '../../../data/sources/products.dart';

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
