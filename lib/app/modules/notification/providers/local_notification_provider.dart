import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:katalog/app/app.dart';

class LocalNotificationProvider extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const String channelId = 'katalog_kue_channel_v2';
  static const String channelName = 'Katalog Kue Promo';
  static const String channelDesc = 'Notifikasi dengan suara kustom';
  static const String soundFile =
      'notif_sound';

  Future<LocalNotificationProvider> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationClick(response.payload);
      },
    );

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.deleteNotificationChannel(
        'katalog_kue_channel',
      );

      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDesc,
          importance: Importance.max, 
          playSound: true,
          sound: RawResourceAndroidNotificationSound(soundFile),
        ),
      );
    }

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _plugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
      if (payload != null) {
        print(
          'Aplikasi dibuka dari notifikasi (Terminated). Payload: $payload',
        );
        Future.delayed(const Duration(milliseconds: 800), () {
          _handleNotificationClick(payload);
        });
      }
    }

    print('Local Notification Service initialized with Custom Sound');
    return this;
  }

  void _handleNotificationClick(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      print('Local Notification diklik. Payload: $payload');

      try {
        if (Get.isRegistered<DashboardController>()) {
          final dashboardController = Get.find<DashboardController>();

          switch (payload.toLowerCase()) {
            case 'produk':
              print('Target: Tab Produk (Index 1)');
              dashboardController.changeTabIndex(1);
              break;
            case 'profile':
              print('Target: Tab Profile (Index 4)');
              dashboardController.changeTabIndex(4);
              break;
            case 'delivery':
              print('Target: Tab Delivery (Index 3)');
              dashboardController.changeTabIndex(3);
              break;
            case 'favorite':
              print('Target: Tab Favorite (Index 2)');
              dashboardController.changeTabIndex(2);
              break;
            case 'home':
              print('Target: Tab Home (Index 0)');
              dashboardController.changeTabIndex(0);
              break;
            default:
              print('⚠ Payload "$payload" tidak dikenal. Default ke Produk.');
              dashboardController.changeTabIndex(1);
          }
        } else {
          print('DashboardController tidak ditemukan. Payload: $payload');
        }
      } catch (e) {
        print('Error handling notification click: $e');
      }
    }
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
          channelId, 
          channelName,
          channelDescription: channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          sound: const RawResourceAndroidNotificationSound(soundFile),
        ),
        iOS: const DarwinNotificationDetails(presentSound: true),
      ),
      payload: payload,
    );
  }
}