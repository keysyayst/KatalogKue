import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // WAJIB IMPORT
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
import 'firebase_options.dart';
import 'app/modules/notification/providers/firebase_messaging_provider.dart';
import 'app/modules/notification/providers/local_notification_provider.dart';
import 'app/modules/notification/providers/mood_notification_provider.dart';
import 'app/routes/app_pages.dart';

Future<void> initServices() async {
  // 1. Timezone
  try {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    debugPrint('✅ Timezone initialized');
  } catch (e) {
    debugPrint('❌ Timezone init error: $e');
  }

  // 2. Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl != null && supabaseAnonKey != null) {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  } else {
    debugPrint('❌ Supabase Env Missing');
  }

  // 3. Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Firebase initialized');

  // 4. Shared Preferences
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);
  debugPrint('SharedPreferences initialized');

  // 5. Hive Services
  final favoriteService = FavoriteHiveService();
  await favoriteService.init();
  Get.put(favoriteService);

  final searchHistoryService = SearchHistoryHiveService();
  await searchHistoryService.init();
  Get.put(searchHistoryService);

  // 6. Core Services
  Get.put(AuthService());
  Get.put(ProductService());
  Get.put(LocationService());

  // 7. Notification Services
  try {
    await Get.putAsync(() => LocalNotificationProvider().init()).timeout(
      const Duration(seconds: 5),
      onTimeout: () => LocalNotificationProvider(),
    );
    await Get.putAsync(() => FirebaseMessagingProvider().init()).timeout(
      const Duration(seconds: 5),
      onTimeout: () => FirebaseMessagingProvider(),
    );
    await Get.putAsync(() => MoodNotificationProvider().init()).timeout(
      const Duration(seconds: 5),
      onTimeout: () => MoodNotificationProvider(),
    );
  } catch (e) {
    debugPrint('❌ Notification Services error: $e');
  }

  debugPrint('All services initialized successfully!');
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // TAHAN SPLASH NATIVE (Agar loading tidak terlihat user)
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: '.env');

  // Jalankan semua service
  await initServices();

  // Cek Status Login
  final authService = Get.find<AuthService>();
  final initialRoute = authService.isLoggedIn ? Routes.dashboard : Routes.auth;

  // Jalankan App
  runApp(App(initialRoute: initialRoute));

  // Lepaskan Splash Native
  FlutterNativeSplash.remove();
}
