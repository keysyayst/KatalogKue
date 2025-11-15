import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';
import 'app/data/services/auth_service.dart';
import 'app/data/sources/products.dart';
import 'app/data/services/favorite_hive_service.dart';
import 'app/data/services/search_history_hive_service.dart';

Future<void> initServices() async {
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

  // Initialize Hive for favorites
  final favoriteService = FavoriteHiveService();
  await favoriteService.init();
  Get.put(favoriteService);

  // Initialize Hive for search history
  final searchHistoryService = SearchHistoryHiveService();
  await searchHistoryService.init();
  Get.put(searchHistoryService);

  Get.put(AuthService());

  // Initialize ProductService
  Get.put(ProductService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load file .env
  await dotenv.load(fileName: '.env');
  await initServices();
  runApp(const App());
}
