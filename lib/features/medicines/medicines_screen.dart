import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raksh_health/config/app_theme.dart';
import 'package:raksh_health/widgets/glass_container.dart';
import 'package:raksh_health/features/medicines/medicine_repository.dart';
import 'package:raksh_health/features/medicines/add_medicine_screen.dart';

class MedicinesScreen extends ConsumerWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesState = ref.watch(medicinesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Icon(Icons.medication, color: AppTheme.secondaryColor, size: 32),
                  SizedBox(width: 12),
                  Text(
                    'My Medicines',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: medicinesState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                data: (medicines) {
                  if (medicines.isEmpty) {
                    return _EmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.refresh(medicinesProvider),
                    color: AppTheme.primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: medicines.length,
                      itemBuilder: (context, index) {
                        final med = medicines[index];
                        return _MedicineCard(medicine: med);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), // Above bottom nav
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          ),
          backgroundColor: AppTheme.secondaryColor,
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }
}

class _MedicineCard extends ConsumerWidget {
  final Map<String, dynamic> medicine;
  const _MedicineCard({required this.medicine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = medicine['is_active'] ?? true;
    final times = List<String>.from(medicine['reminder_times'] ?? []);

    return Dismissible(
      key: Key(medicine['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      onDismissed: (_) {
        ref.read(medicinesProvider.notifier).deleteMedicine(medicine['id']);
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.medication, color: AppTheme.secondaryColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(medicine['medicine_name'] ?? 'Medicine', 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text(medicine['dose'] ?? '', 
                            style: const TextStyle(color: Colors.white54, fontSize: 14)),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isActive,
                      activeColor: AppTheme.secondaryColor,
                      onChanged: (val) {
                        ref.read(medicinesProvider.notifier).toggleActive(medicine['id'], val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.repeat, size: 14, color: Colors.white38),
                    const SizedBox(width: 6),
                    Text("${medicine['frequency']} • ${medicine['timing']}", 
                      style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                if (times.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: times.map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text('No medicines active.', style: TextStyle(fontSize: 18, color: Colors.white54)),
          const SizedBox(height: 8),
          const Text('Tap + to set a new reminder.', style: TextStyle(color: Colors.white30, fontSize: 14)),
        ],
      ),
    );
  }
}
