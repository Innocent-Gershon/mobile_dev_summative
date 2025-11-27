import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class PdfHelper {
  static Future<Map<String, dynamic>?> pickPdf(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final file = result.files.single;
        final String base64String = base64Encode(file.bytes!);
        
        return {
          'base64': base64String,
          'name': file.name,
          'size': file.size,
        };
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }
}