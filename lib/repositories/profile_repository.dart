import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:raksh_health/repositories/auth_repository.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository(Supabase.instance.client));

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.value?.session?.user ?? ref.watch(authRepositoryProvider).currentUser;
  
  if (user == null) return null;
  
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.getProfile(user.id);
});

class ProfileRepository {
  final SupabaseClient _supabase;
  ProfileRepository(this._supabase);

  // Helper to generate a unique Raksh ID: RK-XXXXXXXX
  String _generateRakshId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // No ambiguous chars like O, I, 1, 0
    final rnd = Random();
    final randomPart = String.fromCharCodes(Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
    return 'RK-$randomPart';
  }

  Future<Map<String, dynamic>?> getProfile(String authUid) async {
    try {
      // 1. Find user in the 'users' table using auth_id (linked to auth.users.id)
      final userData = await _supabase
          .from('users')
          .select('*, profiles(*)') // Join with profiles
          .eq('auth_id', authUid)
          .maybeSingle();
      
      if (userData == null) return null;
      
      // Combine user and profile data for easier consumption in the UI
      final profile = (userData['profiles'] as List).isNotEmpty ? userData['profiles'][0] : null;
      
      return {
        'id': userData['id'],
        'profile_id': profile?['id'],
        'raksh_id': userData['raksh_id'],
        'phone_number': userData['phone_number'],
        'full_name': profile?['full_name'] ?? 'Raksh User',
        'is_primary': profile?['is_primary'] ?? true,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createProfile({
    required String authId,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      // 1. Create entry in 'users' table
      final rakshId = _generateRakshId();
      final userInsert = await _supabase.from('users').insert({
        'auth_id': authId,
        'phone_number': phoneNumber,
        'raksh_id': rakshId,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      final userId = userInsert['id'];

      // 2. Create entry in 'profiles' table
      await _supabase.from('profiles').insert({
        'user_id': userId,
        'raksh_id': rakshId, // Your schema has raksh_id in both tables
        'full_name': fullName,
        'is_primary': true,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
