import 'package:get/get.dart';

import '../controllers/delivery_checker_controller.dart';

class DeliveryCheckerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryCheckerController>(
      () => DeliveryCheckerController(),
    );
  }
}
