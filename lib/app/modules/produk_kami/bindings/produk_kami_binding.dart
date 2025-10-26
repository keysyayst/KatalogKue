import 'package:get/get.dart';
import '../controllers/product_detail_controller.dart'; 
import '../controllers/produk_kami_controller.dart';

class ProdukKamiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProdukKamiController());
    Get.lazyPut(() => ProductDetailController());
  }
}
