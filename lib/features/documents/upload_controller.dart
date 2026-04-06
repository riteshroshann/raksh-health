import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:raksh_health/repositories/profile_repository.dart';

class UploadState {
  final bool isUploading;
  final String statusMessage;
  final File? pickedFile;
  final String? fileName;
  final String selectedDocType;
  final String? error;

  UploadState({
    this.isUploading = false,
    this.statusMessage = '',
    this.pickedFile,
    this.fileName,
    this.selectedDocType = 'Lab Report',
    this.error,
  });

  UploadState copyWith({
    bool? isUploading,
    String? statusMessage,
    File? pickedFile,
    String? fileName,
    String? selectedDocType,
    String? error,
  }) {
    return UploadState(
      isUploading: isUploading ?? this.isUploading,
      statusMessage: statusMessage ?? this.statusMessage,
      pickedFile: pickedFile ?? this.pickedFile,
      fileName: fileName ?? this.fileName,
      selectedDocType: selectedDocType ?? this.selectedDocType,
      error: error ?? this.error,
    );
  }
}

// Modern Riverpod 3.x Notifier syntax
final uploadControllerProvider = NotifierProvider<UploadController, UploadState>(() {
  return UploadController();
});

class UploadController extends Notifier<UploadState> {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  @override
  UploadState build() {
    return UploadState();
  }

  void setDocType(String type) {
    state = state.copyWith(selectedDocType: type);
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        state = state.copyWith(
          pickedFile: File(picked.path),
          fileName: picked.name,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        state = state.copyWith(
          pickedFile: File(result.files.single.path!),
          fileName: result.files.single.name,
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> uploadAndAnalyze() async {
    if (state.pickedFile == null) return false;

    state = state.copyWith(isUploading: true, statusMessage: 'Preparing secure upload...', error: null);

    try {
      // 1. Get profile_id from relational schema
      final profileData = await ref.read(userProfileProvider.future);
      final profileId = profileData?['profile_id'];

      if (profileId == null) throw 'Profile not found. Please complete your profile.';

      // 2. Prepare file metadata
      final file = state.pickedFile!;
      final extension = state.fileName?.split('.').last ?? 'bin';
      final fileName = '${const Uuid().v4()}.$extension';
      final storagePath = '$profileId/$fileName';

      // 3. Upload to Supabase Storage
      state = state.copyWith(statusMessage: 'Uploading to Raksh Vault...');
      await _supabase.storage.from('documents').upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      // 4. Get Public URL
      final fileUrl = _supabase.storage.from('documents').getPublicUrl(storagePath);

      // 5. Insert initial document record
      final insertResult = await _supabase.from('documents').insert({
        'profile_id': profileId,
        'file_url': fileUrl,
        'file_type': extension,
        'category': state.selectedDocType,
        'file_size_kb': (await file.length()) ~/ 1024,
        'processing_status': 'pending',
      }).select().single();

      final documentId = insertResult['id'];

      // 6. AI PIPELINE: Combined OCR & Extraction
      state = state.copyWith(statusMessage: 'Reading & analyzing with AI...');
      final response = await _supabase.functions.invoke('process-document', body: {
        'document_id': documentId,
        'file_url': fileUrl,
        'category': state.selectedDocType,
        'profile_id': profileId,
      });

      if (response.status != 200) throw 'AI processing failed: ${response.data}';
      
      state = state.copyWith(isUploading: false, statusMessage: 'Analysis complete! ✓');
      return true;
    } catch (e) {
      state = state.copyWith(isUploading: false, error: e.toString());
      return false;
    }
  }

  void clear() {
    state = UploadState();
  }
}
