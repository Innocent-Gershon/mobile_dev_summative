import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SimpleFilePicker {
  static Future<File?> pickFile(BuildContext context) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File upload from web browser is not supported in this demo. Please use mobile app.'),
          backgroundColor: Colors.orange,
        ),
      );
      return null;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File Selection'),
        content: const Text('In a real app, this would open your device\'s file picker. For demo purposes, we\'ll create a sample file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Select Sample File'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      try {
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/sample_document.pdf');
        await file.writeAsString('Sample PDF content for demonstration');
        return file;
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }
}