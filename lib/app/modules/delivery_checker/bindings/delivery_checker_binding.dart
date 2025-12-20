import 'package:get/get.dart';
import '../controllers/delivery_checker_controller.dart';
import '../../../data/services/location_service.dart';

class DeliveryCheckerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LocationService>()) {
      Get.put(LocationService());
    }

    Get.lazyPut<DeliveryCheckerController>(() => DeliveryCheckerController());
  }
}
