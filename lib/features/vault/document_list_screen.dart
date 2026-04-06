import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raksh_health/config/app_theme.dart';
import 'package:raksh_health/widgets/glass_container.dart';
import 'package:raksh_health/features/vault/document_repository.dart';
import 'package:intl/intl.dart';

class DocumentListScreen extends ConsumerWidget {
  const DocumentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultState = ref.watch(vaultProvider);
    final categories = ['All', 'Lab Report', 'Prescription', 'Scan', 'Doctor Note'];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Health Vault',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ),
            
            // 🏷️ Category Filters
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  // Simple local selection for filtering
                  return _CategoryChip(label: cat);
                },
              ),
            ),

            Expanded(
              child: vaultState.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
                error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
                data: (docs) {
                  if (docs.isEmpty) {
                    return _EmptyState();
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref.read(vaultProvider.notifier).refresh(),
                    color: AppTheme.primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        return _DocumentCard(doc: docs[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends ConsumerWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: To be fully functional with setCategory, we would need to track current selection
    return ChoiceChip(
      label: Text(label),
      selected: false, // Placeholder for state selection
      onSelected: (selected) {
        ref.read(vaultProvider.notifier).setCategory(label);
      },
      backgroundColor: Colors.white10,
      selectedColor: AppTheme.primaryColor,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _DocumentCard({required this.doc});

  IconData _getIcon(String? category) {
    switch (category) {
      case 'Lab Report': return Icons.science_outlined;
      case 'Prescription': return Icons.medication_outlined;
      case 'Scan': return Icons.biotech_outlined; // Proxy for Scan
      case 'Doctor Note': return Icons.face_retouching_natural_outlined;
      default: return Icons.description_outlined;
    }
  }

  String _getFinding(Map<String, dynamic> doc) {
    final status = doc['processing_status'];
    if (status != 'completed') return 'Processing findings...';
    
    final json = doc['extraction_json'];
    if (json == null) return 'No summary available.';

    final category = doc['category'];
    if (category == 'Lab Report' && json['tests'] != null && (json['tests'] as List).isNotEmpty) {
      final test = json['tests'][0];
      return "${test['test_name']}: ${test['value'] ?? test['test_value']} ${test['unit'] ?? ''}";
    } else if (category == 'Prescription' && json['medicines'] != null && (json['medicines'] as List).isNotEmpty) {
      final med = json['medicines'][0];
      return "Med: ${med['name'] ?? med['medicine_name']} (${med['dose'] ?? med['dosage']})";
    }

    return json['summary'] ?? json['key_findings'] ?? 'Data extracted successfully.';
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(doc['uploaded_at'] ?? '') ?? DateTime.now();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 🧪 Icon
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getIcon(doc['category']), color: AppTheme.secondaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              
              // 📝 Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(doc['category'] ?? 'Document', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        _StatusBadge(status: doc['processing_status']),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(DateFormat('MMM dd, yyyy • hh:mm a').format(date), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(
                      _getFinding(doc),
                      style: const TextStyle(color: AppTheme.secondaryColor, fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String? status;
  const _StatusBadge({this.status});

  @override
  Widget build(BuildContext context) {
    final isDone = status == 'completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isDone ? Colors.green : Colors.orange).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isDone ? Icons.check_circle_outline : Icons.pending_outlined, size: 12, color: isDone ? Colors.greenAccent : Colors.orangeAccent),
          const SizedBox(width: 4),
          Text(
            isDone ? 'Completed' : 'Pending',
            style: TextStyle(color: isDone ? Colors.greenAccent : Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
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
          Icon(Icons.folder_open_outlined, size: 80, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          const Text('No records yet.', style: TextStyle(fontSize: 18, color: Colors.white54)),
          const SizedBox(height: 8),
          const Text('Tap + to upload your first document.', style: TextStyle(color: Colors.white30, fontSize: 14)),
        ],
      ),
    );
  }
}
