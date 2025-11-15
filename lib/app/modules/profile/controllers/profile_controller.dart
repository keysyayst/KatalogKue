import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../../../theme/theme_controller.dart'; // ← TAMBAH INI

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ThemeController _themeController =
      Get.find<ThemeController>(); // ← TAMBAH INI

  // Form controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  // Reactive text values untuk force rebuild
  var fullNameText = ''.obs;
  var phoneText = ''.obs;
  var emailText = ''.obs;

  var isEditing = false.obs;
  var isLoading = false.obs;
  var isUploadingAvatar = false.obs;
  var selectedAvatar = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    print('🎯 ProfileController onInit called');
    loadProfile();
    // Listen to profile changes
    ever(_authService.currentProfile, (profile) {
      print('🔄 Profile changed detected: ${profile?.email}');
      loadProfile();
    });
  }

  @override
  void onReady() {
    super.onReady();
    print('✅ ProfileController onReady called');
    // Load lagi saat view sudah siap, untuk memastikan data tampil
    loadProfile();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  // ← TAMBAH GETTER INI
  bool get isDarkMode => _themeController.isDarkMode.value;

  void toggleTheme() {
    _themeController.toggleTheme();
  }

  void loadProfile() {
    final profile = _authService.currentProfile.value;
    if (profile != null) {
      fullNameController.text = profile.fullName ?? '';
      phoneController.text = profile.phone ?? '';
      emailController.text = profile.email;

      // Update reactive variables untuk trigger rebuild
      fullNameText.value = profile.fullName ?? '';
      phoneText.value = profile.phone ?? '';
      emailText.value = profile.email;

      print(
        '📝 Profile loaded to controllers: ${profile.email}, ${profile.fullName}, ${profile.phone}',
      );
    } else {
      print('⚠ Profile is null in loadProfile()');
    }
  }

  void toggleEdit() {
    isEditing.value = !isEditing.value;
    if (!isEditing.value) {
      loadProfile();
      selectedAvatar.value = null;
    }
  }

  Future<void> pickAvatar() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        selectedAvatar.value = File(image.path);
        await uploadAvatar();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memilih foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickAvatarFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        selectedAvatar.value = File(image.path);
        await uploadAvatar();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> uploadAvatar() async {
    if (selectedAvatar.value == null) return;

    try {
      isUploadingAvatar.value = true;

      final avatarUrl = await _authService.uploadAvatar(selectedAvatar.value!);

      if (avatarUrl != null) {
        await _authService.updateProfile(avatarUrl: avatarUrl);

        Get.snackbar(
          'Berhasil',
          'Foto profil berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        selectedAvatar.value = null;
      } else {
        Get.snackbar(
          'Error',
          'Gagal upload foto profil',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal upload foto: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  void showAvatarPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Foto Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFFFE8C00),
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Get.back();
                pickAvatar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFE8C00)),
              title: const Text('Ambil Foto'),
              onTap: () {
                Get.back();
                pickAvatarFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.grey),
              title: const Text('Batal'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      await _authService.updateProfile(
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
      );

      Get.snackbar(
        'Berhasil',
        'Profil berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      isEditing.value = false;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memperbarui profil: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Get.back();
              await _authService.signOut();
              Get.offAllNamed(Routes.auth);
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  get profile => _authService.currentProfile.value;
  bool get isAdmin => _authService.isAdmin;
}
