import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app.dart'; // <-- Path Relatif
import 'app/data/sources/products.dart'; // <-- Path Relatif

// Fungsi untuk inisialisasi Service Global
Future<void> initServices() async {
  Get.put(ProductService());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding siap
  await initServices();

  runApp(const App());
}