import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthService _authService = Get.find<AuthService>();

  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void onInit() {
    super.onInit();

    // PERUBAHAN: Durasi animasi dipercepat jadi 1 detik
    animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );

    animationController.forward();

    _checkAuthStatus();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  Future<void> _checkAuthStatus() async {
    // PERUBAHAN: Total waktu tunggu dipersingkat jadi 1.5 detik
    await Future.delayed(const Duration(milliseconds: 1500));

    if (_authService.isLoggedIn) {
      Get.offAllNamed(Routes.dashboard);
    } else {
      Get.offAllNamed(Routes.auth);
    }
  }
}
