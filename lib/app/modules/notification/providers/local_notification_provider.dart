import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class LocalNotificationProvider extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // DEFINISI KONSTANTA AGAR KONSISTEN
  // PENTING: ID Channel diganti (_v2) agar settingan suara baru terbaca oleh Android
  static const String channelId = 'katalog_kue_channel_v2';
  static const String channelName = 'Katalog Kue Promo';
  static const String channelDesc = 'Notifikasi dengan suara kustom';
  static const String soundFile =
      'notif_sound'; // Nama file di res/raw tanpa ekstensi

  Future<LocalNotificationProvider> init() async {
    // 1. Setup Android Settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // 2. Setup iOS Settings (Request Permission Sound)
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
    );

    // 3. Initialize Plugin & Handle Click (Foreground & Background)
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Logika ketika notif diklik saat aplikasi sedang berjalan (background/foreground)
        _handleNotificationClick(response.payload);
      },
    );

    // 4. Create Channel Khusus Android (Wajib untuk Custom Sound)
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // Hapus channel lama agar bersih (opsional)
      await androidImplementation.deleteNotificationChannel(
        'katalog_kue_channel',
      );

      // Buat channel baru dengan suara
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          channelId,
          channelName,
          description: channelDesc,
          importance: Importance.max, // Max = Muncul Popup (Heads-up)
          playSound: true,
          // PENTING: Link ke file di android/app/src/main/res/raw/notif_sound.mp3
          sound: RawResourceAndroidNotificationSound(soundFile),
        ),
      );
    }

    // 5. Handle Click (Terminated / Mati Total)
    // Cek apakah aplikasi baru saja dibuka karena user menekan notifikasi?
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _plugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload =
          notificationAppLaunchDetails!.notificationResponse?.payload;
      if (payload != null) {
        print(
          '📱 Aplikasi dibuka dari notifikasi (Terminated). Payload: $payload',
        );
        // Beri delay sedikit agar GetX Routing siap
        Future.delayed(const Duration(milliseconds: 800), () {
          _handleNotificationClick(payload);
        });
      }
    }

    print('✅ Local Notification Service initialized with Custom Sound');
    return this;
  }

  // Fungsi Navigasi Terpusat
  void _handleNotificationClick(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      print('🚀 Navigasi ke Product Detail: $payload');
      // Pastikan route ini ada di AppPages Anda
      Get.toNamed('/product-detail', arguments: payload);
    }
  }

  // Fungsi Show Notification Manual
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
          channelId, // Gunakan ID V2
          channelName,
          channelDescription: channelDesc,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          // Sound di set ulang disini untuk kepastian
          sound: const RawResourceAndroidNotificationSound(soundFile),
        ),
        iOS: const DarwinNotificationDetails(presentSound: true),
      ),
      payload: payload,
    );
  }
}
