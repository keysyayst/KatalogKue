import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  final moodEnabled = true.obs;
  final promoEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPrefs();
  }

  void _loadPrefs() {
    final prefs = Get.find<SharedPreferences>();
    moodEnabled.value = prefs.getBool('mood_notif') ?? true;
    promoEnabled.value = prefs.getBool('promo_notif') ?? true;
  }

  Future<void> toggleMood(bool value) async {
    moodEnabled.value = value;
    final prefs = Get.find<SharedPreferences>();
    await prefs.setBool('mood_notif', value);
    
    Get.snackbar(
      value ? 'Aktif' : 'Nonaktif',
      'Rekomendasi harian ${value ? "aktif" : "nonaktif"}',
    );
  }

  Future<void> togglePromo(bool value) async {
    promoEnabled.value = value;
    final prefs = Get.find<SharedPreferences>();
    await prefs.setBool('promo_notif', value);
  }
}
