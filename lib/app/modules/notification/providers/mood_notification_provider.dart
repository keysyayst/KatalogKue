import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class MoodNotificationProvider extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Konfigurasi waktu notifikasi
  final Map<String, MoodConfig> moods = {
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
    print('✅ Mood Notification Service initialized (scheduling deferred)');
    return this;
  }

  Future<void> scheduleAllNotifications() async {
    try {
      final prefs = Get.find<SharedPreferences>();
      final enabled = prefs.getBool('mood_notifications_enabled') ?? true;

      if (!enabled) return;

      int id = 1000;

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
                'katalog_kue_channel',
                'Katalog Kue Notifications',
                channelDescription: 'Notifikasi mood-based',
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
                playSound: true,
              ),
              iOS: const DarwinNotificationDetails(presentSound: true),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            payload: config.productId,
            // REPEAT SETIAP HARI
            matchDateTimeComponents: DateTimeComponents.time,
          );

          print('Scheduled $moodName at ${config.hour}:${config.minute}');
        } catch (e) {
          print('Error scheduling $moodName: $e');
        }
      }
    } catch (e) {
      print('Error in scheduleAllNotifications: $e');
    }
  }

  // Cancel all scheduled notifications
  Future<void> cancelAllScheduled() async {
    await _plugin.cancelAll();
    print('All scheduled notifications cancelled');
  }

  // Toggle mood notifications
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

// Model konfigurasi
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