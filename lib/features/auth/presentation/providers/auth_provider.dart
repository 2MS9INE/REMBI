import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/auth_repository.dart';

/// Watches Supabase auth state changes.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateStream;
});

/// Provides the current user's full profile row from the users table.
final currentUserProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // Re-fetch whenever auth state changes
  ref.watch(authStateProvider);
  return ref.read(authRepositoryProvider).fetchCurrentUserProfile();
});
