import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'local_notification_provider.dart';

// Background handler (di luar class!)
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  print('Background: ${message.notification?.title}');
}

class FirebaseMessagingProvider extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<FirebaseMessagingProvider> init() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Permission: ${settings.authorizationStatus}');
    
    // Get token
    String? token = await _fcm.getToken();
    print('FCM Token: $token');
    
    // Setup background handler
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    
    // PERBAIKAN: Gunakan Get.find dengan error handling
    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground: ${message.notification?.title}');
      
      // Cek apakah LocalNotificationProvider sudah ada
      try {
        final localNotif = Get.find<LocalNotificationProvider>();
        localNotif.showNotification(
          title: message.notification?.title ?? 'Notifikasi',
          body: message.notification?.body ?? '',
          payload: message.data['productId'],
        );
      } catch (e) {
        print('LocalNotificationProvider belum ready: $e');
        // Fallback: print saja jika service belum ready
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
      }
    });
    
    // Tap handler
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Tapped: ${message.notification?.title}');
      _handleTap(message.data);
    });
    
    // Check initial message (app opened from terminated state)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from notification');
      _handleTap(initialMessage.data);
    }
    
    return this;
  }

  void _handleTap(Map<String, dynamic> data) {
    if (data['productId'] != null) {
      // TODO: Update route sesuai dengan routes KatalogKue
      Get.toNamed('/product-detail', arguments: data['productId']);
    }
  }
}
