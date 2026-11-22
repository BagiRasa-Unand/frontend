import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/api_config.dart';
import 'app_notification.dart';

class NotificationApiService {
  NotificationApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// 1. GET /api/v1/notifications (Daftar notifikasi pengguna aktif dari backend)
  Future<List<AppNotification>?> getNotifications() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/notifications');
      debugPrint('📡 [FE ➔ BE] Memuat riwayat notifikasi dari: $url');
      final res = await _client.get(url).timeout(ApiConfig.timeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] is List) {
          final list = decoded['data'] as List<dynamic>;
          final notifs = list
              .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
              .toList();
          debugPrint('✅ [BE ➔ FE] Sukses memuat ${notifs.length} notifikasi dari database.');
          return notifs;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Network Error] Gagal memuat notifikasi dari backend: $e');
    }
    return null;
  }

  /// 2. PATCH /api/v1/notifications/:id/read (Tandai telah dibaca)
  Future<bool> markAsRead(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/notifications/$id/read');
      final res = await _client.patch(url).timeout(ApiConfig.timeout);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [Network Error] Gagal tandai baca notifikasi: $e');
      return false;
    }
  }
}
