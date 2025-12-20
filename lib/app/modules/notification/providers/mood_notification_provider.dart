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

  final Map<String, MoodConfig> moods = {
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
