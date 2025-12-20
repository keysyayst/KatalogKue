import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile_model.dart';

class AuthService extends GetxService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Rx<User?> currentUser = Rx<User?>(null);
  Rx<ProfileModel?> currentProfile = Rx<ProfileModel?>(null);

  @override
  void onInit() {
    super.onInit();

    // Listen perubahan auth
    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      if (data.session?.user != null) {
        loadProfile();
      } else {
        currentProfile.value = null;
      }
    });

    // Set user awal kalau sudah login
    currentUser.value = _supabase.auth.currentUser;
    if (currentUser.value != null) {
      loadProfile();
    }
  }

  bool get isLoggedIn => currentUser.value != null;

  bool get isAdmin {
    final role = currentProfile.value?.role;
    return role == 'admin';
  }

  // Untuk kebutuhan auto‑reload profile dari controller lain
  Future<void> fetchProfileFromServer() async {
    await loadProfile();
  }

  // ================= SIGN IN =================
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        await loadProfile();
      }

      return response;
    } on SocketException {
      throw AuthException(
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
        statusCode: 'NETWORK_ERROR',
      );
    } on TimeoutException {
      throw AuthException(
        'Koneksi timeout. Server tidak merespon. Coba lagi nanti.',
        statusCode: 'TIMEOUT',
      );
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('failed host lookup') ||
          errorString.contains('socketexception') ||
          errorString.contains('clientexception') ||
          errorString.contains('network')) {
        throw AuthException(
          'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
          statusCode: 'NETWORK_ERROR',
        );
      }
      rethrow;
    }
  }

  // ================= SIGN UP =================
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? '',
          'phone': phone ?? '',
        },
      );

      if (response.user != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        await loadProfile();
      }

      return response;
    } on SocketException {
      throw AuthException(
        'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
        statusCode: 'NETWORK_ERROR',
      );
    } on TimeoutException {
      throw AuthException(
        'Koneksi timeout. Server tidak merespon. Coba lagi nanti.',
        statusCode: 'TIMEOUT',
      );
    } catch (e) {
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('failed host lookup') ||
          errorString.contains('socketexception') ||
          errorString.contains('clientexception') ||
          errorString.contains('network')) {
        throw AuthException(
          'Tidak ada koneksi internet. Periksa koneksi Anda dan coba lagi.',
          statusCode: 'NETWORK_ERROR',
        );
      }
      rethrow;
    }
  }

  // ================= LOAD PROFILE =================
  Future<void> loadProfile() async {
    try {
      final userId = currentUser.value?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      currentProfile.value = ProfileModel.fromJson(response);
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  // ================= UPDATE PROFILE =================
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final userId = currentUser.value?.id;
      if (userId == null) return;

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase.from('profiles').update(updates).eq('id', userId);

      await loadProfile();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  // ================= UPLOAD AVATAR =================
  Future<String?> uploadAvatar(File file) async {
    try {
      final userId = currentUser.value?.id;
      if (userId == null) return null;

      // Hapus avatar lama
      final oldAvatarUrl = currentProfile.value?.avatarUrl;
      if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
        try {
          final oldPath = oldAvatarUrl.split('/').last;
          await _supabase.storage.from('avatars').remove([oldPath]);
        } catch (e) {
          print('Error deleting old avatar: $e');
        }
      }

      final fileName = '$userId${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage.from('avatars').upload(
        fileName,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('Error uploading avatar: $e');
      return null;
    }
  }

  // ================= SIGN OUT =================
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    currentUser.value = null;
    currentProfile.value = null;
  }
}
