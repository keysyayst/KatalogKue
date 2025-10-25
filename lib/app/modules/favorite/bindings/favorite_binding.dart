import 'package:get/get.dart';
import '../controllers/favorite_controller.dart'; // <-- Path Relatif

class FavoriteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FavoriteController());
  }
}