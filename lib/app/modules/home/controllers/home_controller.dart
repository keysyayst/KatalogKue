import 'package:get/get.dart';
import '../../../data/models/product.dart'; // <-- Path Relatif
import '../../../data/sources/products.dart'; // <-- Path Relatif

class HomeController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  List<Product> get rekomendasiProducts {
    return _productService.allProducts.take(4).toList();
  }
}