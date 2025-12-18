import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'local_notification_provider.dart';
import 'package:cake_by_mommy/app/app.dart';

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  print('Background Handler: ${message.notification?.title}');
}

class FirebaseMessagingProvider extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<FirebaseMessagingProvider> init() async {
    print('Inisialisasi Firebase Messaging...');

    // 1. LISTENER UTAMA (Background -> Klik Notif)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notifikasi diklik dari Background!');
      print('Data Payload: ${message.data}');

      _handleTap(message.data);
    });

    // 2. LISTENER TERMINATED (App Mati -> Klik Notif)
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from TERMINATED state');
        _handleTap(message.data);
      }
    });

    // 3. LISTENER FOREGROUND (App Sedang Dibuka)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('☀ Foreground Message: ${message.notification?.title}');
      try {
        if (Get.isRegistered<LocalNotificationProvider>()) {
          Get.find<LocalNotificationProvider>().showNotification(
            title: message.notification?.title ?? 'Notifikasi',
            body: message.notification?.body ?? '',
            payload: message.data['screen'] ?? 'produk',
          );
        }
      } catch (e) {
        print('Error showing local notification: $e');
      }
    });

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    _fcm.requestPermission(alert: true, badge: true, sound: true);
    _fcm.getToken().then((token) => print('FCM Token: $token'));

    return this;
  }

  void _handleTap(Map<String, dynamic> data) {
    print('Processing Tap Payload: $data');

    final screen = data['screen'];

    Future.delayed(const Duration(milliseconds: 1500), () {
      try {
        // LOGIC 1: MENU PRODUK
        if (screen == 'produk') {
          print('Target: MENU PRODUK');
          final dashboardController = Get.find<DashboardController>();
          dashboardController.changeTabIndex(1);
        }
        // LOGIC 2: PROFILE
        else if (screen == 'profile') {
          print('Target: PROFILE');
          final dashboardController = Get.find<DashboardController>();
          dashboardController.changeTabIndex(4);
        }
        // LOGIC 3: DELIVERY
        else if (screen == 'delivery') {
          print('Target: DELIVERY');
          final dashboardController = Get.find<DashboardController>();
          dashboardController.changeTabIndex(3);
        }
        // LOGIC 4: FAVORITE
        else if (screen == 'favorite') {
          print('Target: FAVORITE');
          final dashboardController = Get.find<DashboardController>();
          dashboardController.changeTabIndex(2);
        }
        // LOGIC 5: FALLBACK (HOME)
        else {
          print('Screen "$screen" tidak dikenal. Default ke Produk.');
          final dashboardController = Get.find<DashboardController>();
          dashboardController.changeTabIndex(1);
        }
      } catch (e) {
        print('Gagal navigasi: $e');
        Get.snackbar('Error', 'Gagal membuka halaman: $e');
      }
    });
  }
}
