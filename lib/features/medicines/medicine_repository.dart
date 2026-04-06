import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:raksh_health/repositories/profile_repository.dart';
import 'package:raksh_health/services/notification_service.dart';

final medicineRepositoryProvider = Provider((ref) => MedicineRepository(ref));

final medicinesProvider = AsyncNotifierProvider<MedicinesNotifier, List<Map<String, dynamic>>>(() {
  return MedicinesNotifier();
});

class MedicinesNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  late final MedicineRepository _repository;

  @override
  Future<List<Map<String, dynamic>>> build() async {
    _repository = ref.watch(medicineRepositoryProvider);
    return _repository.fetchActiveMedicines();
  }

  Future<void> addMedicine(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.addMedicine(data);
      return _repository.fetchActiveMedicines();
    });
  }

  Future<void> toggleActive(String id, bool isActive) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.updateMedicine(id, {'is_active': isActive});
      return _repository.fetchActiveMedicines();
    });
  }

  Future<void> deleteMedicine(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteMedicine(id);
      return _repository.fetchActiveMedicines();
    });
  }
}

class MedicineRepository {
  final Ref _ref;
  final _supabase = Supabase.instance.client;

  MedicineRepository(this._ref);

  Future<List<Map<String, dynamic>>> fetchActiveMedicines() async {
    try {
      final profileData = await _ref.read(userProfileProvider.future);
      final profileId = profileData?['profile_id'];
      if (profileId == null) return [];

      final response = await _supabase
          .from('medicines')
          .select('*')
          .eq('profile_id', profileId)
          .eq('is_deleted', false)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw 'Failed to fetch medicines: $e';
    }
  }

  Future<void> addMedicine(Map<String, dynamic> data) async {
    try {
      final profileData = await _ref.read(userProfileProvider.future);
      final profileId = profileData?['profile_id'];
      if (profileId == null) throw 'Missing profileId';

      final insertData = {
        ...data,
        'profile_id': profileId,
        'is_active': true,
        'is_deleted': false,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase.from('medicines').insert(insertData).select().single();
      
      // Schedule Local Notifications
      final timesList = List<String>.from(data['reminder_times'] ?? []);
      if (timesList.isNotEmpty) {
        await NotificationService().scheduleMedicineReminder(
          id: response['id'].hashCode,
          title: '💊 Time for your Medicine!',
          body: "Take ${data['medicine_name']} (${data['dose']}) - ${data['timing']}",
          times: timesList,
        );
      }
    } catch (e) {
      throw 'Failed to add medicine: $e';
    }
  }

  Future<void> updateMedicine(String id, Map<String, dynamic> update) async {
    try {
      await _supabase.from('medicines').update(update).eq('id', id);
      
      // If deactivating, cancel notifications
      if (update['is_active'] == false) {
        await NotificationService().cancelReminder(id.hashCode);
      }
    } catch (e) {
      throw 'Failed to update medicine: $e';
    }
  }

  Future<void> deleteMedicine(String id) async {
    try {
      await _supabase.from('medicines').update({'is_deleted': true}).eq('id', id);
      await NotificationService().cancelReminder(id.hashCode);
    } catch (e) {
      throw 'Failed to delete medicine: $e';
    }
  }
}
