import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FileUploadHelper {
  // Toggle between Storage and Firestore
  static const bool useFirestore = true; // Set to false to use Firebase Storage
  static const List<String> allowedExtensions = [
    // Documents
    'pdf',
    'doc',
    'docx',
    // Spreadsheets
    'xls',
    'xlsx',
    'csv',
    // Presentations
    'ppt',
    'pptx',
    // Text files
    'txt',
    // Images
    'jpg',
    'jpeg',
    'png',
    'gif',
    'bmp',
    'webp',
    // Archives
    'zip',
    'rar',
    // Other common formats
    'mp4',
    'mp3',
    'avi',
    'mov',
  ];

  /// Show dialog to select file source
  static Future<String?> showFileSourceDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder, color: Colors.blue),
                title: const Text('Choose File'),
                subtitle: const Text('Select from device storage'),
                onTap: () => Navigator.pop(context, 'file'),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Take Photo'),
                subtitle: const Text('Use camera'),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.purple),
                title: const Text('Photo Gallery'),
                subtitle: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
              ListTile(
                leading: const Icon(Icons.link, color: Colors.orange),
                title: const Text('Add Link'),
                subtitle: const Text('Paste URL'),
                onTap: () => Navigator.pop(context, 'link'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Pick image from camera
  static Future<Map<String, dynamic>?> pickFromCamera(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        return {
          'bytes': bytes,
          'name': 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
          'size': bytes.length,
          'extension': 'jpg',
        };
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }

  /// Pick image from gallery
  static Future<Map<String, dynamic>?> pickFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        return {
          'bytes': bytes,
          'name': image.name,
          'size': bytes.length,
          'extension': image.name.split('.').last,
        };
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }

  /// Show dialog to add a link/URL
  static Future<Map<String, dynamic>?> addLink(BuildContext context) async {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController titleController = TextEditingController();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Link'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g., Lecture Video',
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL',
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final url = urlController.text.trim();
                final title = titleController.text.trim();
                
                if (url.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL is required'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Validate URL
                if (!Uri.tryParse(url)!.hasScheme) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid URL format'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context, {
                  'isLink': true,
                  'url': url,
                  'name': title.isEmpty ? url : title,
                  'extension': 'link',
                  'size': 0,
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

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

  /// Upload file to Firebase Storage or Firestore
  static Future<Map<String, String>?> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String folderPath,
    required BuildContext context,
    Function(double)? onProgress,
  }) async {
    if (useFirestore) {
      return _uploadToFirestore(
        fileBytes: fileBytes,
        fileName: fileName,
        folderPath: folderPath,
        context: context,
        onProgress: onProgress,
      );
    } else {
      return _uploadToStorage(
        fileBytes: fileBytes,
        fileName: fileName,
        folderPath: folderPath,
        context: context,
        onProgress: onProgress,
      );
    }
  }

  /// Upload file to Firestore as base64 (FREE alternative)
  static Future<Map<String, String>?> _uploadToFirestore({
    required Uint8List fileBytes,
    required String fileName,
    required String folderPath,
    required BuildContext context,
    Function(double)? onProgress,
  }) async {
    try {
      // Check file size (Firestore doc max 1MB)
      if (fileBytes.length > 1024 * 1024) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File too large for Firestore (max 1MB). Using chunked storage...'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return _uploadLargeFileToFirestore(
          fileBytes: fileBytes,
          fileName: fileName,
          folderPath: folderPath,
          context: context,
          onProgress: onProgress,
        );
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last;
      final uniqueId = '${timestamp}_${fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
      
      // Convert to base64
      final base64String = base64Encode(fileBytes);
      
      // Store in Firestore
      final docRef = FirebaseFirestore.instance
          .collection('file_storage')
          .doc(uniqueId);

      await docRef.set({
        'data': base64String,
        'fileName': fileName,
        'extension': extension,
        'size': fileBytes.length,
        'folderPath': folderPath,
        'contentType': _getContentType(extension),
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      onProgress?.call(1.0);

      return {
        'url': 'firestore://$uniqueId',
        'name': fileName,
        'path': 'file_storage/$uniqueId',
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

  /// Upload large files to Firestore in chunks
  static Future<Map<String, String>?> _uploadLargeFileToFirestore({
    required Uint8List fileBytes,
    required String fileName,
    required String folderPath,
    required BuildContext context,
    Function(double)? onProgress,
  }) async {
    try {
      const chunkSize = 900 * 1024; // 900KB chunks (safe under 1MB limit)
      final totalChunks = (fileBytes.length / chunkSize).ceil();
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last;
      final uniqueId = '${timestamp}_${fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')}';
      
      // Create metadata document
      await FirebaseFirestore.instance
          .collection('file_storage')
          .doc(uniqueId)
          .set({
        'fileName': fileName,
        'extension': extension,
        'size': fileBytes.length,
        'folderPath': folderPath,
        'contentType': _getContentType(extension),
        'isChunked': true,
        'totalChunks': totalChunks,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      // Upload chunks
      for (int i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        final end = (start + chunkSize > fileBytes.length) 
            ? fileBytes.length 
            : start + chunkSize;
        
        final chunk = fileBytes.sublist(start, end);
        final chunkBase64 = base64Encode(chunk);
        
        await FirebaseFirestore.instance
            .collection('file_storage')
            .doc(uniqueId)
            .collection('chunks')
            .doc('chunk_$i')
            .set({
          'data': chunkBase64,
          'index': i,
        });

        onProgress?.call((i + 1) / totalChunks);
      }

      return {
        'url': 'firestore://$uniqueId',
        'name': fileName,
        'path': 'file_storage/$uniqueId',
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

  /// Upload file to Firebase Storage (original method)
  static Future<Map<String, String>?> _uploadToStorage({
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

  /// Download file from Firestore
  static Future<Uint8List?> downloadFromFirestore(String fileId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('file_storage')
          .doc(fileId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      
      // Check if file is chunked
      if (data['isChunked'] == true) {
        final totalChunks = data['totalChunks'] as int;
        final chunks = <int, String>{};
        
        // Fetch all chunks
        for (int i = 0; i < totalChunks; i++) {
          final chunkDoc = await FirebaseFirestore.instance
              .collection('file_storage')
              .doc(fileId)
              .collection('chunks')
              .doc('chunk_$i')
              .get();
          
          if (chunkDoc.exists) {
            chunks[i] = chunkDoc.data()!['data'] as String;
          }
        }
        
        // Combine chunks
        final sortedChunks = chunks.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        
        final combinedBase64 = sortedChunks
            .map((e) => e.value)
            .join('');
        
        return base64Decode(combinedBase64);
      } else {
        // Single document
        final base64String = data['data'] as String;
        return base64Decode(base64String);
      }
    } catch (e) {
      debugPrint('Error downloading from Firestore: $e');
      return null;
    }
  }

  /// Delete file from Firebase Storage
  static Future<bool> deleteFile(String filePath) async {
    try {
      await FirebaseStorage.instance.ref(filePath).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
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
      case 'link':
        return Icons.link;
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
      case 'link':
        return const Color(0xFF9C27B0); // Purple for links
      default:
        return const Color(0xFF757575);
    }
  }
}
