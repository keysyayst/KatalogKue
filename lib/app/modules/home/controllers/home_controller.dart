import 'package:get/get.dart';
import '../../../data/models/product.dart';
import '../../../data/sources/products.dart';

class HomeController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  List<Product> get rekomendasiProducts {
    return _productService.getAllProducts().take(4).toList();
  }
}