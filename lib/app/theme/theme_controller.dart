import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _keyDarkMode = 'isDarkMode';
  
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTheme();
  }

  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode.value = prefs.getBool(_keyDarkMode) ?? false;
      _updateTheme();
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    try {
      isDarkMode.value = !isDarkMode.value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDarkMode, isDarkMode.value);
      _updateTheme();
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  void _updateTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
