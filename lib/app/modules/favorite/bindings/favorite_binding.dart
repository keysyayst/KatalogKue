import 'package:get/get.dart';
import '../controllers/favorite_controller.dart';
import '../../../data/services/favorite_supabase_service.dart';

class FavoriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FavoriteSupabaseService());
    Get.lazyPut(() => FavoriteController());
  }
}
