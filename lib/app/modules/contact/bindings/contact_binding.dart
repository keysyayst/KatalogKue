import 'package:get/get.dart';
import '../controllers/contact_controller.dart';

class ContactBinding extends Bindings {
  @override
  void dependencies() {
    // Daftarkan controller untuk halaman kontak
    Get.lazyPut(() => ContactController());
  }
}
