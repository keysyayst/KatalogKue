import 'package:get/get.dart';

import 'package:katalog/app/modules/notification/controllers/mood_notification_controller.dart';

import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoodNotificationController>(() => MoodNotificationController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}
