import 'package:get/get.dart';
import '../../../data/models/product.dart'; 
import '../../../data/sources/products.dart'; 

class FavoriteController extends GetxController {
  final ProductService _productService = Get.find<ProductService>();

  List<Product> get favoriteProducts {
    return _productService.getFavoriteProducts();
  }
  
  // Method untuk manual refresh (dipanggil dari UI jika perlu)
  void refreshFavorites() {
    update();
  }
}
