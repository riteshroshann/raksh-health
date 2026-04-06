import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raksh_health/config/app_theme.dart';
import 'package:raksh_health/features/documents/upload_controller.dart';
import 'package:raksh_health/widgets/glass_container.dart';
import 'package:raksh_health/utils/ui_utils.dart';

class UploadDocumentScreen extends ConsumerWidget {
  const UploadDocumentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(uploadControllerProvider);
    final controller = ref.read(uploadControllerProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Upload Document', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A0F1E), Color(0xFF1A1F3D), Color(0xFF0A0F1E)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Select Source',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SourceButton(
                        icon: CupertinoIcons.camera_fill,
                        label: 'Camera',
                        onTap: () => controller.pickImage(ImageSource.camera),
                      ),
                      _SourceButton(
                        icon: CupertinoIcons.photo_fill,
                        label: 'Gallery',
                        onTap: () => controller.pickImage(ImageSource.gallery),
                      ),
                      _SourceButton(
                        icon: CupertinoIcons.doc_text_fill,
                        label: 'PDF',
                        onTap: () => controller.pickPdf(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Document Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.selectedDocType,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1A1F3D),
                        icon: const Icon(CupertinoIcons.chevron_down, color: Colors.white54),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        items: ['Lab Report', 'Prescription', 'Scan', 'Doctor Note', 'Other']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) controller.setDocType(value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (state.pickedFile != null) ...[
                    const Text(
                      'Preview',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    GlassContainer(
                      width: double.infinity,
                      height: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: state.fileName?.toLowerCase().endsWith('.pdf') ?? false
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(CupertinoIcons.doc_text_fill, color: Colors.white, size: 64),
                                  const SizedBox(height: 12),
                                  Text(state.fileName ?? 'document.pdf', style: const TextStyle(color: Colors.white70)),
                                ],
                              )
                            : Image.file(state.pickedFile!, fit: BoxFit.cover),
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: state.pickedFile == null || state.isUploading
                          ? LinearGradient(colors: [Colors.grey.withValues(alpha: 0.1), Colors.grey.withValues(alpha: 0.1)])
                          : const LinearGradient(colors: [AppTheme.primaryColor, AppTheme.secondaryColor]),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: state.pickedFile == null || state.isUploading
                          ? []
                          : [BoxShadow(color: AppTheme.primaryColor.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: ElevatedButton(
                      onPressed: state.pickedFile == null || state.isUploading
                          ? null
                          : () async {
                              final success = await controller.uploadAndAnalyze();
                              if (success && context.mounted) {
                                context.showSnackBar('Document uploaded! AI processing will begin shortly.');
                                Navigator.pop(context);
                              } else if (state.error != null && context.mounted) {
                                context.showSnackBar(state.error!, isError: true);
                              }
                            },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                      child: state.isUploading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                const SizedBox(width: 12),
                                Expanded(child: Text(state.statusMessage, style: const TextStyle(fontSize: 14))),
                              ],
                            )
                          : const Text('Upload & Analyze', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: MediaQuery.of(context).size.width * 0.26,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.secondaryColor, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
