import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raksh_health/config/app_theme.dart';
import 'package:raksh_health/widgets/glass_container.dart';
import 'package:raksh_health/features/medicines/medicine_repository.dart';
import 'package:intl/intl.dart';

class AddMedicineScreen extends ConsumerStatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  ConsumerState<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends ConsumerState<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  
  String _frequency = 'Once daily';
  String _timing = 'After meals';
  List<TimeOfDay> _reminderTimes = [const TimeOfDay(hour: 8, minute: 0)];
  DateTime _startDate = DateTime.now();

  final List<String> _frequencies = ['Once daily', 'Twice daily', 'Three times daily', 'Four times daily', 'As needed'];
  final List<String> _timings = ['Before meals', 'After meals', 'With meals', 'Empty stomach', 'Bedtime'];

  void _updateDefaultTimes(String freq) {
    setState(() {
      switch (freq) {
        case 'Once daily':
          _reminderTimes = [const TimeOfDay(hour: 8, minute: 0)]; break;
        case 'Twice daily':
          _reminderTimes = [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 20, minute: 0)]; break;
        case 'Three times daily':
          _reminderTimes = [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 14, minute: 0), const TimeOfDay(hour: 20, minute: 0)]; break;
        case 'Four times daily':
          _reminderTimes = [const TimeOfDay(hour: 8, minute: 0), const TimeOfDay(hour: 13, minute: 0), const TimeOfDay(hour: 18, minute: 0), const TimeOfDay(hour: 22, minute: 0)]; break;
        default:
          _reminderTimes = [const TimeOfDay(hour: 8, minute: 0)];
      }
    });
  }

  Future<void> _selectTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTimes[index],
    );
    if (picked != null) {
      setState(() => _reminderTimes[index] = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final List<String> formattedTimes = _reminderTimes.map((t) => 
      "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}"
    ).toList();

    try {
      await ref.read(medicinesProvider.notifier).addMedicine({
        'medicine_name': _nameController.text,
        'dose': _doseController.text,
        'frequency': _frequency,
        'timing': _timing,
        'reminder_times': formattedTimes,
        'start_date': _startDate.toIso8601String(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1E),
      appBar: AppBar(
        title: const Text('Add Medicine'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassContainer(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Medicine Name', Icons.medication),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _doseController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Dose (e.g. 500mg)', Icons.straighten),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Schedule & Timing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              const SizedBox(height: 16),
              GlassContainer(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _frequency,
                        dropdownColor: const Color(0xFF1A1F3D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Frequency', Icons.repeat),
                        items: _frequencies.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                        onChanged: (v) {
                          setState(() => _frequency = v!);
                          _updateDefaultTimes(v!);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _timing,
                        dropdownColor: const Color(0xFF1A1F3D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Instruction', Icons.info_outline),
                        items: _timings.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => _timing = v!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Reminder Times', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: List.generate(_reminderTimes.length, (index) {
                  final time = _reminderTimes[index];
                  return GestureDetector(
                    onTap: () => _selectTime(index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, color: AppTheme.secondaryColor, size: 18),
                          const SizedBox(width: 8),
                          Text(time.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save & Schedule Reminders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(icon, color: AppTheme.secondaryColor),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.secondaryColor)),
    );
  }
}
