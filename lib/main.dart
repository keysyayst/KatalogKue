import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/app.dart'; 
import 'app/data/sources/products.dart';

Future<void> initServices() async {
  Get.put(ProductService());
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await initServices();

  runApp(const App());
}

