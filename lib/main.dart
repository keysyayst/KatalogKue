import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'app/app.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/sources/products.dart';
import 'app/data/services/favorite_hive_service.dart';
import 'app/data/services/search_history_hive_service.dart';
import 'app/data/services/location_service.dart';

// Firebase imports
import 'firebase_options.dart';

// Notification services imports
import 'app/modules/notification/providers/firebase_messaging_provider.dart';
import 'app/modules/notification/providers/local_notification_provider.dart';
import 'app/modules/notification/providers/mood_notification_provider.dart';

Future<void> initServices() async {
  // ========== TIMEZONE SETUP ==========
  // Initialize timezone data SEBELUM notification service
  try {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    debugPrint('✅ Timezone initialized');
  } catch (e) {
    debugPrint('❌ Timezone init error: $e');
  }

  // ========== SUPABASE SETUP ==========
  // Ambil variabel environment
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    throw Exception(
      'Environment variables SUPABASE_URL atau SUPABASE_ANON_KEY tidak ditemukan. Pastikan file .env sudah dibuat.',
    );
  }

  // Initialize Supabase menggunakan variabel .env
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // ========== FIREBASE SETUP ==========
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Firebase initialized');

  // ========== SHARED PREFERENCES ==========
  // Initialize SharedPreferences untuk menyimpan settings notifikasi
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);
  debugPrint('SharedPreferences initialized');

  // ========== EXISTING SERVICES ==========
  // Initialize Hive for favorites
  final favoriteService = FavoriteHiveService();
  await favoriteService.init();
  Get.put(favoriteService);

  // Initialize Hive for search history
  final searchHistoryService = SearchHistoryHiveService();
  await searchHistoryService.init();
  Get.put(searchHistoryService);

  // Initialize Auth Service
  Get.put(AuthService());

  // Initialize ProductService
  Get.put(ProductService());

  // Initialize Location Service
  Get.put(LocationService());

  // ========== NOTIFICATION SERVICES (MODUL 6) ==========
  // Initialize Local Notification Service (harus duluan)
  try {
    await Get.putAsync(() => LocalNotificationProvider().init()).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('⚠️ LocalNotificationProvider init timeout, continuing...');
        return LocalNotificationProvider();
      },
    );
    debugPrint('Local Notification Service initialized');
  } catch (e) {
    debugPrint('❌ LocalNotificationProvider error: $e');
  }

  // Initialize Firebase Messaging Service
  try {
    await Get.putAsync(() => FirebaseMessagingProvider().init()).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('⚠️ FirebaseMessagingProvider init timeout, continuing...');
        return FirebaseMessagingProvider();
      },
    );
    debugPrint('Firebase Messaging Service initialized');
  } catch (e) {
    debugPrint('❌ FirebaseMessagingProvider error: $e');
  }

  // Initialize Mood-Based Notification Service
  try {
    await Get.putAsync(() => MoodNotificationProvider().init()).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('⚠️ MoodNotificationProvider init timeout, continuing...');
        return MoodNotificationProvider();
      },
    );
    debugPrint('Mood Notification Service initialized');
  } catch (e) {
    debugPrint('❌ MoodNotificationProvider error: $e');
  }

  debugPrint('All services initialized successfully!');
}

void main() async {
  // Pastikan Flutter binding sudah ready
  WidgetsFlutterBinding.ensureInitialized();

  // Load file .env
  await dotenv.load(fileName: '.env');
  debugPrint('Environment variables loaded');

  // Initialize all services
  await initServices();

  // Run app
  runApp(const App());
}
