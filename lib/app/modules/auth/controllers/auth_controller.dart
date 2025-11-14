import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  
  // UI states
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var isLoginMode = true.obs; // true = login, false = register

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Toggle login/register mode
  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    // Clear form
    emailController.clear();
    passwordController.clear();
    fullNameController.clear();
    phoneController.clear();
  }

  // Sign In
  Future<void> signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan password harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      await _authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      Get.snackbar(
        'Berhasil',
        'Login berhasil!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to dashboard
      Get.offAllNamed(Routes.dashboard);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login gagal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign Up
  Future<void> signUp() async {
    if (emailController.text.isEmpty || 
        passwordController.text.isEmpty ||
        fullNameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Semua field harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar(
        'Error',
        'Password minimal 6 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      Get.snackbar(
        'Berhasil',
        'Registrasi berhasil! Silakan login.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Switch to login mode
      toggleMode();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registrasi gagal: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
