import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'local_notification_provider.dart';

// ✅ PERBAIKAN IMPORT: Gunakan package absolute path agar pasti ketemu
// Pastikan 'katalog' adalah nama package di pubspec.yaml Anda (sesuai history chat sebelumnya)
import 'package:katalog/app/routes/app_pages.dart';
import 'package:katalog/app/app.dart'; // ← TAMBAH: Import DashboardController

@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  print('🌙 Background Handler: ${message.notification?.title}');
}

class FirebaseMessagingProvider extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<FirebaseMessagingProvider> init() async {
    print('🔄 Inisialisasi Firebase Messaging...');

    // 1. LISTENER UTAMA (Background -> Klik Notif)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('👆 Notifikasi diklik dari Background!');
      print('📦 Data Payload: ${message.data}');

      Get.snackbar(
        'Debug',
        'Notif diklik. Memproses navigasi...',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      _handleTap(message.data);
    });

    // 2. LISTENER TERMINATED (App Mati -> Klik Notif)
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('🚀 App opened from TERMINATED state');
        _handleTap(message.data);
      }
    });

    // 3. LISTENER FOREGROUND (App Sedang Dibuka)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('☀️ Foreground Message: ${message.notification?.title}');
      try {
        if (Get.isRegistered<LocalNotificationProvider>()) {
          Get.find<LocalNotificationProvider>().showNotification(
            title: message.notification?.title ?? 'Notifikasi',
            body: message.notification?.body ?? '',
            // Default payload ke 'produk'
            payload: message.data['screen'] ?? 'produk',
          );
        }
      } catch (e) {
        print('Error showing local notification: $e');
      }
    });

    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    _fcm.requestPermission(alert: true, badge: true, sound: true);
    _fcm.getToken().then((token) => print('🔥 FCM Token: $token'));

    return this;
  }

  // ==============================================================
  // LOGIC NAVIGASI
  // ==============================================================
  void _handleTap(Map<String, dynamic> data) {
    print('📦 Processing Tap Payload: $data');

    // Ambil target screen
    final screen = data['screen'];

    // Delay 1.5 detik agar aplikasi benar-benar siap
    Future.delayed(const Duration(milliseconds: 1500), () {
      // LOGIC 1: MENU PRODUK
      if (screen == 'produk') {
        print('📍 Target: MENU PRODUK');
        try {
          // ✅ PERBAIKAN: Navigasi ke Dashboard dulu, lalu set tab ke Produk
          Get.offAllNamed(Routes.dashboard);

          // Tunggu sebentar agar DashboardController siap
          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.isRegistered<DashboardController>()) {
              Get.find<DashboardController>().changeTabIndex(
                1,
              ); // Index 1 = Produk
              print('✅ Tab switched to Produk (index 1)');
            }
          });
        } catch (e) {
          print('❌ Gagal Navigasi Produk: $e');
          Get.snackbar('Error', 'Gagal membuka produk: $e');
        }
      }
      // LOGIC 2: PROFILE
      else if (screen == 'profile') {
        print('📍 Target: PROFILE');
        try {
          Get.offAllNamed(Routes.dashboard);

          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.isRegistered<DashboardController>()) {
              Get.find<DashboardController>().changeTabIndex(
                4,
              ); // Index 4 = Profile
              print('✅ Tab switched to Profile (index 4)');
            }
          });
        } catch (e) {
          print('❌ Gagal Navigasi Profile: $e');
        }
      }
      // LOGIC 3: DELIVERY
      else if (screen == 'delivery') {
        print('📍 Target: DELIVERY');
        try {
          Get.offAllNamed(Routes.dashboard);

          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.isRegistered<DashboardController>()) {
              Get.find<DashboardController>().changeTabIndex(
                3,
              ); // Index 3 = Delivery
              print('✅ Tab switched to Delivery (index 3)');
            }
          });
        } catch (e) {
          print('❌ Gagal Navigasi Delivery: $e');
        }
      }
      // LOGIC 4: FALLBACK
      else {
        print('⚠️ Screen "$screen" tidak dikenal. Default ke Home.');
        Get.offAllNamed(Routes.dashboard);
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().changeTabIndex(0); // Index 0 = Home
        }
      }
    });
  }
}
