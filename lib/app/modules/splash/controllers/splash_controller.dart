import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Beri sedikit waktu agar Supabase selesai memuat sesi
    await Future.delayed(const Duration(seconds: 2));
    
    if (_authService.isLoggedIn) {
      Get.offAllNamed(Routes.dashboard);
    } else {
      Get.offAllNamed(Routes.auth);
    }
  }
}
