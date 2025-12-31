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

    _supabase.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
      if (data.session?.user != null) {
        loadProfile();
      } else {
        currentProfile.value = null;
      }
    });

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

  Future<void> fetchProfileFromServer() async {
    await loadProfile();
  }

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

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
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

  Future<String?> uploadAvatar(File file) async {
    try {
      final userId = currentUser.value?.id;
      if (userId == null) return null;

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

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    currentUser.value = null;
    currentProfile.value = null;
  }
}
