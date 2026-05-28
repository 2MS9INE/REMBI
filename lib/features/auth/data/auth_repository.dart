// ignore_for_file: null_aware_elements
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/image_utils.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(Supabase.instance.client),
);

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  User? getCurrentUser() => _supabase.auth.currentUser;

  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;

  /// Creates a new farmer account.
  /// Email is derived as phone@rembi.dz, password is the phone number.
  Future<void> registerFarmer({
    required String fullName,
    required String phone,
    String? whatsapp,
    required String wilaya,
    required String password,
    File? profilePhotoFile,
  }) async {
    final email = 'farmer_$phone@rembi.dz';

    // 1. Create Supabase Auth user
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    final uid = response.user?.id;
    if (uid == null) {
      throw Exception('Registration failed: no user ID returned');
    }

    // 2. Upload profile photo if provided
    String? profilePhotoUrl;
    if (profilePhotoFile != null) {
      profilePhotoUrl = await uploadAvatarPhoto(profilePhotoFile, uid);
    }

    // 3. INSERT into users table
    final data = <String, dynamic>{
      'full_name': fullName,
      'phone': phone,
      'wilaya': wilaya,
      'role': 'farmer',
    };
    if (whatsapp != null) data['whatsapp'] = whatsapp;
    if (profilePhotoUrl != null) data['profile_photo_url'] = profilePhotoUrl;
    await _supabase.from('users').update(data).eq('id', uid);
  }

  Future<void> loginFarmer({
    required String phone,
    required String password,
  }) async {
    final email = 'farmer_$phone@rembi.dz';
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logoutFarmer() async {
    await _supabase.auth.signOut();
  }

  Future<Map<String, dynamic>?> fetchCurrentUserProfile() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return null;
    final data = await _supabase
        .from('users')
        .select('*')
        .eq('id', uid)
        .single();
    return data;
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? whatsapp,
    String? wilaya,
    File? profilePhotoFile,
  }) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');

    String? profilePhotoUrl;
    if (profilePhotoFile != null) {
      profilePhotoUrl = await uploadAvatarPhoto(profilePhotoFile, uid);
    }

    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (whatsapp != null) updates['whatsapp'] = whatsapp;
    if (wilaya != null) updates['wilaya'] = wilaya;
    if (profilePhotoUrl != null) updates['profile_photo_url'] = profilePhotoUrl;

    if (updates.isNotEmpty) {
      await _supabase.from('users').update(updates).eq('id', uid);
    }
  }

  Future<void> requestVerificationBadge() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');
    await _supabase
        .from('users')
        .update({'verification_requested': true})
        .eq('id', uid);
  }
}
