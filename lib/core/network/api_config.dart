import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static String? _customHost;

  /// Override host secara runtime jika ingin menghubungkan ke IP LAN HP tertentu (misal: http://192.168.1.5:5000)
  static void setCustomHost(String host) {
    _customHost = host;
  }

  /// Host server tanpa path '/api/v1' (contoh: http://10.0.2.2:5000 atau http://localhost:5000)
  static String get host {
    if (_customHost != null && _customHost!.isNotEmpty) {
      return _customHost!;
    }
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    try {
      if (Platform.isAndroid) {
        // Android Emulator menggunakan 10.0.2.2 untuk mengakses localhost komputer/host
        return 'http://10.0.2.2:5000';
      }
    } catch (_) {}
    return 'http://localhost:5000';
  }

  /// Base URL API Backend BagiRasa
  static String get baseUrl => '$host/api/v1';

  /// Helper untuk mengubah relative URL gambar (misal: /uploads/donations/foto.jpg) menjadi URL lengkap
  static String? resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('assets/')) {
      return url;
    }
    if (url.startsWith('/')) {
      return '$host$url';
    }
    return '$host/$url';
  }

  static const Duration timeout = Duration(seconds: 6);
}
