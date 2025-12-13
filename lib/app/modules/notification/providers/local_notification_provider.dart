import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class LocalNotificationProvider extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<LocalNotificationProvider> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          Get.toNamed('/product-detail', arguments: response.payload);
        }
      },
    );

    // Create Android channel
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'katalog_kue_channel',
            'Katalog Kue Notifications',
            description: 'Notifikasi promo dan pengingat',
            importance: Importance.high,
          ),
        );

    print('Local Notification Service initialized');
    return this;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'katalog_kue_channel',
          'Katalog Kue Notifications',
          channelDescription: 'Notifikasi promo dan pengingat',
          importance: Importance.high,
          priority: Priority.high,
          // PERBAIKAN: Ganti icon jadi @mipmap/ic_launcher
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }
}
