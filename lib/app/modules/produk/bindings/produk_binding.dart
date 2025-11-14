import 'package:get/get.dart';
import '../controllers/produk_controller.dart';
import '../../../data/services/nutrition_service.dart';

class ProdukBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NutritionService());
    Get.lazyPut(() => ProdukController());
  }
}
