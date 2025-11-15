import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // State
  var isLogin = true.obs;
  var isLoading = false.obs;
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;
  var errorMessage = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleAuthMode() {
    isLogin.value = !isLogin.value;
    clearForm();
    errorMessage.value = '';
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
    phoneController.clear();
    confirmPasswordController.clear();
    errorMessage.value = '';
  }

  // ========================================
  // LOGIN
  // ========================================
  Future<void> login() async {
    errorMessage.value = '';
    
    if (!_validateLoginForm()) return;

    try {
      isLoading.value = true;

      final response = await _authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.user != null) {
        Get.offAllNamed(Routes.dashboard);
        Get.snackbar(
          'Berhasil',
          'Selamat datang kembali!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      }
    } on AuthException catch (e) {
      _handleAuthException(e, isLogin: true);
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // REGISTER
  // ========================================
  Future<void> register() async {
    errorMessage.value = '';
    
    if (!_validateRegisterForm()) return;

    try {
      isLoading.value = true;

      final response = await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      if (response.user != null) {
        Get.snackbar(
          'Berhasil',
          'Akun berhasil dibuat! Silakan login.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
        
        isLogin.value = true;
        passwordController.clear();
        confirmPasswordController.clear();
      }
    } on AuthException catch (e) {
      _handleAuthException(e, isLogin: false);
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // ========================================
  // VALIDATION
  // ========================================
  bool _validateLoginForm() {
    if (emailController.text.trim().isEmpty) {
      errorMessage.value = 'Email tidak boleh kosong';
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      errorMessage.value = 'Format email tidak valid';
      return false;
    }

    if (passwordController.text.isEmpty) {
      errorMessage.value = 'Password tidak boleh kosong';
      return false;
    }

    if (passwordController.text.length < 6) {
      errorMessage.value = 'Password minimal 6 karakter';
      return false;
    }

    return true;
  }

  bool _validateRegisterForm() {
    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'Nama lengkap tidak boleh kosong';
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      errorMessage.value = 'Email tidak boleh kosong';
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      errorMessage.value = 'Format email tidak valid';
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      errorMessage.value = 'Nomor telepon tidak boleh kosong';
      return false;
    }

    if (passwordController.text.isEmpty) {
      errorMessage.value = 'Password tidak boleh kosong';
      return false;
    }

    if (passwordController.text.length < 6) {
      errorMessage.value = 'Password minimal 6 karakter';
      return false;
    }

    if (confirmPasswordController.text != passwordController.text) {
      errorMessage.value = 'Password dan konfirmasi password tidak sama';
      return false;
    }

    return true;
  }

  // ========================================
  // ERROR HANDLING
  // ========================================
  void _handleAuthException(AuthException exception, {required bool isLogin}) {
    switch (exception.statusCode) {
      case '400':
        errorMessage.value = isLogin
            ? 'Email atau password salah. Silakan coba lagi.'
            : 'Data tidak valid. Periksa kembali form Anda.';
        break;

      case '422':
        if (exception.message.contains('already registered')) {
          errorMessage.value = 'Email sudah terdaftar. Silakan gunakan email lain atau login.';
        } else {
          errorMessage.value = 'Data tidak valid. Silakan periksa kembali.';
        }
        break;

      case '500':
        errorMessage.value = 'Server sedang bermasalah. Coba lagi nanti.';
        break;

      default:
        if (exception.message.contains('Invalid login credentials')) {
          errorMessage.value = 'Email atau password salah. Silakan coba lagi.';
        } else if (exception.message.contains('Email not confirmed')) {
          errorMessage.value = 'Email belum dikonfirmasi. Cek inbox Anda.';
        } else if (exception.message.contains('User already registered')) {
          errorMessage.value = 'Email sudah terdaftar. Silakan login.';
        } else if (exception.message.contains('Password')) {
          errorMessage.value = 'Password tidak memenuhi kriteria keamanan.';
        } else {
          errorMessage.value = exception.message;
        }
    }
  }
}
