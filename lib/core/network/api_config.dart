import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Base URL API Backend BagiRasa
  /// - Android Emulator: 10.0.2.2 (alias loopback host laptop)
  /// - Windows Desktop / Web: localhost:5000
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api/v1';
      }
    } catch (_) {}
    return 'http://localhost:5000/api/v1';
  }

  static const Duration timeout = Duration(seconds: 5);
}
