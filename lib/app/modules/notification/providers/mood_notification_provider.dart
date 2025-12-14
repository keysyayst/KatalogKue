import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'local_notification_provider.dart';

class MoodNotificationProvider extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final String _channelId = LocalNotificationProvider.channelId;
  final String _channelName = LocalNotificationProvider.channelName;
  final String _soundFile = LocalNotificationProvider.soundFile;

  // Daftar notifikasi BERURUTAN (13:46 - 14:00)
  final Map<String, MoodConfig> moods = {
    // TESTING MARATHON (13:46 - 14:00)

    // TEST 1: Cek Suara & Pop-up (Aplikasi Dibuka/Background)
    'test_1': MoodConfig(
      hour: 13,
      minute: 46,
      title: '🔔 Test 1 (13:46)',
      body: 'Cek suara custom & pop-up (App Foreground/Background)',
      productId: 'lidah_kucing',
    ),

    // TEST 2: Cek Lock Screen (Matikan Layar HP Sekarang)
    'test_2': MoodConfig(
      hour: 13,
      minute: 48,
      title: '🔔 Test 2 (13:48)',
      body: 'Saat dilock, layar harus menyala + bunyi',
      productId: 'nastar',
    ),

    // TEST 3: Cek Terminated (Matikan Total Aplikasi Sekarang)
    'test_3': MoodConfig(
      hour: 13,
      minute: 50,
      title: '🔔 Test 3 (13:50)',
      body: 'Kill App sukses? Klik aku untuk masuk ke Detail Produk',
      productId: 'kastengel',
    ),

    // TEST 4: Cek Navigasi
    'test_4': MoodConfig(
      hour: 13,
      minute: 53,
      title: '🔔 Test 4 (13:53)',
      body: 'Klik notifikasi ini, harus pindah ke halaman Sagu Keju',
      productId: 'sagu_keju',
    ),

    // TEST 5: Tambahan
    'test_5': MoodConfig(
      hour: 13,
      minute: 56,
      title: '🔔 Test 5 (13:56)',
      body: 'Tes konsistensi suara custom',
      productId: 'putri_salju',
    ),

    // TEST 6: Penutup
    'test_6': MoodConfig(
      hour: 14,
      minute: 00,
      title: '🔔 Test 6 (14:00)',
      body: 'Sesi testing selesai. Selamat makan siang!',
      productId: 'thumbprint',
    ),

    // DAILY SCHEDULE (Jadwal Asli - Tetap Disimpan)
    'morning': MoodConfig(
      hour: 8,
      minute: 0,
      title: '☕ Selamat pagi!',
      body: 'Lidah Kucing cocok untuk teman kopi pagi',
      productId: 'lidah_kucing',
    ),
    'afternoon': MoodConfig(
      hour: 15,
      minute: 30,
      title: '☕ Jam teh nih!',
      body: 'Sagu Keju perfect pair dengan teh hangat',
      productId: 'sagu_keju',
    ),
    'evening': MoodConfig(
      hour: 18,
      minute: 0,
      title: '🎉 Waktunya santai!',
      body: 'Kastengel untuk teman nongkrong sore',
      productId: 'kastengel',
    ),
    'night': MoodConfig(
      hour: 20,
      minute: 0,
      title: '🌙 Lembur?',
      body: 'Thumbprint bisa jadi teman begadangmu',
      productId: 'thumbprint',
    ),
  };

  Future<MoodNotificationProvider> init() async {
    print(' Mood Notification Service initialized');
    // Jadwalkan ulang segera saat init agar test schedule masuk
    await scheduleAllNotifications();
    return this;
  }

  Future<void> scheduleAllNotifications() async {
    try {
      final prefs = Get.find<SharedPreferences>();
      final enabled = prefs.getBool('mood_notifications_enabled') ?? true;

      if (!enabled) {
        print('Mood notifications are disabled');
        return;
      }

      // 1. Cancel jadwal lama
      await _plugin.cancelAll();
      print('Old schedules cancelled');

      int id = 1000;

      // 2. Loop & Jadwalkan
      for (var entry in moods.entries) {
        final moodName = entry.key;
        final config = entry.value;

        final now = tz.TZDateTime.now(tz.local);
        var scheduledDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          config.hour,
          config.minute,
        );

        // Jika jam sudah lewat, geser ke besok
        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        try {
          await _plugin.zonedSchedule(
            id++,
            config.title,
            config.body,
            scheduledDate,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channelId, 
                _channelName,
                channelDescription: 'Notifikasi mood-based',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
                playSound: true,
                // CUSTOM SOUND
                sound: RawResourceAndroidNotificationSound(_soundFile),
              ),
              iOS: const DarwinNotificationDetails(presentSound: true),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,

            payload: config.productId,

            matchDateTimeComponents: DateTimeComponents.time,
          );

          print(
            'Terjadwal: [$moodName] jam ${config.hour}:${config.minute.toString().padLeft(2, '0')}',
          );
        } catch (e) {
          print('Gagal: $moodName - $e');
        }
      }
    } catch (e) {
      print('Error scheduleAllNotifications: $e');
    }
  }

  Future<void> cancelAllScheduled() async {
    await _plugin.cancelAll();
  }

  Future<void> toggle(bool enabled) async {
    final prefs = Get.find<SharedPreferences>();
    await prefs.setBool('mood_notifications_enabled', enabled);

    if (enabled) {
      await scheduleAllNotifications();
    } else {
      await cancelAllScheduled();
    }
  }
}

class MoodConfig {
  final int hour;
  final int minute;
  final String title;
  final String body;
  final String productId;

  MoodConfig({
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
    required this.productId,
  });
}
