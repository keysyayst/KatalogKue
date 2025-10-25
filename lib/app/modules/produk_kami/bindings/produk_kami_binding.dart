import 'package:get/get.dart';
import '../controllers/product_detail_controller.dart'; // <-- Path Relatif
import '../controllers/produk_kami_controller.dart'; // <-- Path Relatif

class ProdukKamiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProdukKamiController());
    Get.lazyPut(() => ProductDetailController());
  }
}
