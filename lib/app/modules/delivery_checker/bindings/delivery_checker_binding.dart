import 'package:get/get.dart';
import '../controllers/delivery_checker_controller.dart';
import '../../../data/services/location_service.dart';

class DeliveryCheckerBinding extends Bindings {
  @override
  void dependencies() {
    // Inject LocationService if not already injected
    if (!Get.isRegistered<LocationService>()) {
      Get.put(LocationService());
    }
    
    // Inject DeliveryCheckerController
    Get.lazyPut<DeliveryCheckerController>(
      () => DeliveryCheckerController(),
    );
  }
}
