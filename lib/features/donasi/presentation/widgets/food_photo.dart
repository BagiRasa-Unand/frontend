import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../core/network/api_config.dart';

Widget buildFoodPhoto(
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  if (path.isEmpty) return _invalidPhoto();

  // 1. Asset path lokal (assets/...)
  if (path.startsWith('assets/')) {
    return Image.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => _invalidPhoto(),
    );
  }

  // 2. Full HTTP / HTTPS network URL
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => _invalidPhoto(),
    );
  }

  // 3. Relative backend path (contoh: /uploads/donations/... atau uploads/donations/...)
  if (path.startsWith('/uploads') || path.startsWith('uploads/')) {
    final fullUrl = ApiConfig.resolveImageUrl(path);
    if (fullUrl != null) {
      return Image.network(
        fullUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _invalidPhoto(),
      );
    }
  }

  // 4. Base64 Data URL (data:image/...)
  if (path.startsWith('data:image/')) {
    final separator = path.indexOf(',');
    if (separator > 0) {
      try {
        return Image.memory(
          base64Decode(path.substring(separator + 1)),
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, _, _) => _invalidPhoto(),
        );
      } catch (_) {
        return _invalidPhoto();
      }
    }
  }

  // 5. File URI (file://...)
  if (path.startsWith('file://')) {
    try {
      final file = File.fromUri(Uri.parse(path));
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (_, _, _) => _invalidPhoto(),
        );
      }
    } catch (_) {}
  }

  // 6. Flutter Web Network Fallback
  if (kIsWeb) {
    return Image.network(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => _invalidPhoto(),
    );
  }

  // 7. Regular Local File
  try {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _invalidPhoto(),
      );
    }
  } catch (_) {}

  return _invalidPhoto();
}

Widget _invalidPhoto() {
  return const ColoredBox(
    color: Color(0xFFF2E8DF),
    child: Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
  );
}
