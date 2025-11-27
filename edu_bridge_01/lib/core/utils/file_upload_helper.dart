import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FileUploadHelper {
  static const List<String> allowedExtensions = [
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'txt',
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];

  /// Pick a file with multiple format support
  static Future<Map<String, dynamic>?> pickFile(BuildContext context, {
    List<String>? customExtensions,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: customExtensions ?? allowedExtensions,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        
        // Validate file size (max 10MB)
        if (file.size > 10 * 1024 * 1024) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 10MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return null;
        }

        return {
          'bytes': file.bytes!,
          'name': file.name,
          'size': file.size,
          'extension': file.extension,
        };
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }

  /// Upload file to Firebase Storage
  static Future<Map<String, String>?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String folderPath,
    required BuildContext context,
    Function(double)? onProgress,
  }) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last;
      final uniqueFileName = '${timestamp}_$fileName';
      
      // Create reference
      final ref = FirebaseStorage.instance
          .ref()
          .child('$folderPath/$uniqueFileName');

      // Upload file with progress tracking
      final uploadTask = ref.putData(
        fileBytes,
        SettableMetadata(
          contentType: _getContentType(extension),
          customMetadata: {
            'originalName': fileName,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // Wait for completion
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return {
        'url': downloadUrl,
        'name': fileName,
        'path': ref.fullPath,
      };
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  /// Delete file from Firebase Storage
  static Future<bool> deleteFile(String filePath) async {
    try {
      await FirebaseStorage.instance.ref(filePath).delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Get content type based on file extension
  static String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get icon for file type
  static IconData getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Get color for file type
  static Color getFileColor(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE53935);
      case 'doc':
      case 'docx':
        return const Color(0xFF1976D2);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF6F00);
      case 'txt':
        return const Color(0xFF616161);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF757575);
    }
  }
}
