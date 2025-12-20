import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../data/services/product_supabase_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ProductSupabaseService>(ProductSupabaseService(), permanent: true);
    Get.lazyPut(() => HomeController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
