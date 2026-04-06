import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:raksh_health/repositories/profile_repository.dart';

final vaultProvider = AsyncNotifierProvider<VaultRepository, List<Map<String, dynamic>>>(() {
  return VaultRepository();
});

class VaultRepository extends AsyncNotifier<List<Map<String, dynamic>>> {
  final _supabase = Supabase.instance.client;
  String? _selectedCategory;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    return _fetchDocuments();
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    ref.invalidateSelf();
  }

  Future<List<Map<String, dynamic>>> _fetchDocuments() async {
    try {
      // 1. Get profile_id using relational join logic
      final profileData = await ref.read(userProfileProvider.future);
      final profileId = profileData?['profile_id'];

      if (profileId == null) return [];

      // 2. Build Query
      var query = _supabase
          .from('documents')
          .select('*')
          .eq('profile_id', profileId)
          .eq('is_deleted', false);

      if (_selectedCategory != null && _selectedCategory != 'All') {
        query = query.eq('category', _selectedCategory!);
      }

      final response = await query.order('uploaded_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Failed to fetch vault: $e';
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchDocuments());
  }
}
