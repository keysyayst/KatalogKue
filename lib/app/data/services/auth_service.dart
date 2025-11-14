import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import 'dart:io';

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

  Future<void> loadProfile() async {
    try {
      final userId = currentUser.value?.id;
      if (userId == null) {
        print('❌ User ID is null');
        return;
      }

      print('🔍 Loading profile for user: $userId');

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        print('⚠️ Profile not found, creating new one');
        await _createProfile(userId);
        return;
      }

      currentProfile.value = ProfileModel.fromJson(response);
      print('✅ Profile loaded successfully');
    } catch (e) {
      print('❌ Error loading profile: $e');
    }
  }

  Future<void> _createProfile(String userId) async {
    try {
      final email = currentUser.value?.email ?? '';
      
      await _supabase.from('profiles').insert({
        'id': userId,
        'email': email,
        'role': 'user',
      });

      print('✅ Profile created for user: $userId');
      await loadProfile();
    } catch (e) {
      print('❌ Error creating profile: $e');
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phone,
  }) async {
    try {
      print('📝 Signing up user: $email');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? '',
          'phone': phone ?? '',
        },
      );

      print('✅ Sign up response: ${response.user?.id}');

      if (response.user != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        await loadProfile();
      }

      return response;
    } catch (e) {
      print('❌ Sign up error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login for: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ Login response: ${response.user?.id}');

      if (response.user != null) {
        await loadProfile();
      }

      return response;
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    currentUser.value = null;
    currentProfile.value = null;
  }

  Future<String?> uploadAvatar(File imageFile) async {
    try {
      final userId = currentUser.value?.id;
      if (userId == null) {
        print('❌ User ID is null');
        return null;
      }

      // Delete old avatar dulu
      try {
        final oldAvatarUrl = currentProfile.value?.avatarUrl;
        if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
          final uri = Uri.parse(oldAvatarUrl);
          final oldFileName = uri.pathSegments.last;
          await _supabase.storage
              .from('avatars')
              .remove([oldFileName]);
          print('🗑️ Deleted old avatar');
        }
      } catch (e) {
        print('⚠️ Could not delete old avatar: $e');
      }

      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      print('📤 Uploading avatar: $fileName');

      await _supabase.storage
          .from('avatars')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final avatarUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      print('✅ Avatar uploaded: $avatarUrl');
      return avatarUrl;
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final userId = currentUser.value?.id;
      if (userId == null) throw Exception('User not logged in');

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      await _supabase.from('profiles').update(updateData).eq('id', userId);

      await loadProfile();
      print('✅ Profile updated successfully');
    } catch (e) {
      print('❌ Error updating profile: $e');
      rethrow;
    }
  }

  bool get isLoggedIn => currentUser.value != null;
  bool get isAdmin => currentProfile.value?.isAdmin ?? false;
}
