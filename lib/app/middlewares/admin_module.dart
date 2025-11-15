import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/auth_service.dart';
import '../routes/app_pages.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    if (!authService.isAdmin) {
      Get.snackbar(
        'Akses Ditolak',
        'Anda tidak memiliki akses admin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return const RouteSettings(name: Routes.dashboard);
    }

    return null;
  }
}
