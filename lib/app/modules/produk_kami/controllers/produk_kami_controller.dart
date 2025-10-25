import 'package:get/get.dart';
import '../../../data/models/product.dart'; // <-- Path Relatif
import '../../../data/sources/products.dart'; // <-- Path Relatif

class ProdukKamiController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  List<Product> get allProducts {
    return _productService.allProducts;
  }
}
