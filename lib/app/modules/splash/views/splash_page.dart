import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller akan menangani logika navigasi
    controller.onInit();

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
