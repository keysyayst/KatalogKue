import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'app/data/sources/products.dart';
import 'app/data/services/favorite_hive_service.dart';

Future<void> initServices() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://sinjtvyyomaxsmaziczx.supabase.co',              // ← GANTI dengan URL Supabase Anda
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpbmp0dnl5b21heHNtYXppY3p4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwNDI2OTEsImV4cCI6MjA3ODYxODY5MX0.-d4k2sfwgYlQ13lBpFt9k4eO0_MYKXXiqF5GJoz_J_8',     // ← GANTI dengan anon key Anda
  );

  // Initialize Hive
  final favoriteService = FavoriteHiveService();
  await favoriteService.init();
  Get.put(favoriteService);
  
  // Initialize ProductService
  Get.put(ProductService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServices();
  runApp(const App());
}
