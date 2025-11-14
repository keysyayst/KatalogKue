import 'package:get/get.dart';
import '../controllers/eksperimen_controller.dart';

class EksperimenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EksperimenController>(() => EksperimenController());
  }
}
