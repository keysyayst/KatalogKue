import 'package:shared_preferences/shared_preferences.dart';

class ThemePref {
  static const String key = "isDarkTheme";

  // Mengambil preferensi tema dari penyimpanan (default: false/terang)
  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false; // false = light
  }

  // Menyimpan preferensi tema (true=gelap, false=terang)
  static Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, isDark);
  }
}
