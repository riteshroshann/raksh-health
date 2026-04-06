import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:raksh_health/repositories/profile_repository.dart';

final vitalsRepositoryProvider = Provider((ref) => VitalsRepository(ref));

// Provider for the most recent vitals/markers
final latestVitalsProvider = FutureProvider<Map<String, String>>((ref) async {
  final repository = ref.watch(vitalsRepositoryProvider);
  return await repository.getLatestVitals();
});

class VitalsRepository {
  final Ref _ref;
  final _supabase = Supabase.instance.client;

  VitalsRepository(this._ref);

  Future<Map<String, String>> getLatestVitals() async {
    try {
      final profileData = await _ref.read(userProfileProvider.future);
      final profileId = profileData?['profile_id'];
      if (profileId == null) return {'Weight': '--', 'Sleep': '--', 'BPM': '--'};

      // 1. Fetch latest lab results for key markers
      final response = await _supabase
          .from('lab_results')
          .select('test_name, test_value, unit')
          .eq('profile_id', profileId)
          .order('test_date', ascending: false)
          .limit(10);

      final results = List<Map<String, dynamic>>.from(response);
      
      // 2. Map markers to the dashboard categories
      String findValue(String name, String defaultValue) {
        final match = results.firstWhere(
          (t) => t['test_name'].toString().toLowerCase().contains(name.toLowerCase()),
          orElse: () => {},
        );
        return match.isNotEmpty ? "${match['test_value']}" : defaultValue;
      }

      return {
        'Weight': findValue('Weight', '72'), // 72 is current mock default in UI
        'Sleep': findValue('Sleep', '7.4'),
        'BPM': findValue('BPM', '72'),
      };
    } catch (e) {
      return {'Weight': '72', 'Sleep': '7.4', 'BPM': '72'}; // Fallback to mock
    }
  }
}
