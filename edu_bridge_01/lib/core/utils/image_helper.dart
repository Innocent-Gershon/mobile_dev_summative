import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageHelper {

  static Widget buildImageFromBase64(String? base64String, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    if (base64String == null || base64String.isEmpty) {
      return placeholder ?? const Icon(Icons.image, size: 50, color: Colors.grey);
    }
    
    try {
      final Uint8List bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return placeholder ?? const Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
      );
    } catch (e) {
      return placeholder ?? const Icon(Icons.broken_image, size: 50, color: Colors.grey);
    }
  }
}