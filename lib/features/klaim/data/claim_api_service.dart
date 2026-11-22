import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/network/api_config.dart';
import 'claim.dart';

class ClaimApiService {
  ClaimApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  ClaimStatus _parseStatus(String? raw) {
    switch (raw?.toUpperCase()) {
      case 'ANTRE':
        return ClaimStatus.antre;
      case 'MENUNGGU_PERSETUJUAN':
      case 'MENUNGGU':
        return ClaimStatus.menunggu;
      case 'MENUNGGU_PENGAMBILAN':
      case 'SELESAI':
        return ClaimStatus.diterima;
      case 'DITOLAK':
        return ClaimStatus.ditolak;
      case 'BATAL_KEDALUWARSA':
      case 'DIBATALKAN_PENGGUNA':
      case 'DIBATALKAN':
        return ClaimStatus.dibatalkan;
      default:
        return ClaimStatus.menunggu;
    }
  }

  Claim parseClaimFromJson(Map<String, dynamic> json, {int fallbackSeq = 1}) {
    final statusStr = json['status'] as String? ?? 'MENUNGGU_PENGAMBILAN';
    final createdAtStr = json['claimedAt'] ?? json['created_at'] ?? json['createdAt'];
    final decidedAtStr = json['decidedAt'] ?? json['decided_at'];

    return Claim(
      id: json['id']?.toString() ?? '',
      listingId: json['donationId']?.toString() ?? json['donation_id']?.toString() ?? '',
      claimantId: json['recipientId']?.toString() ?? json['recipient_id']?.toString() ?? '',
      claimantName: json['recipientName']?.toString() ?? json['recipient_name']?.toString() ?? 'Saya',
      quantity: json['quantity'] as int? ?? json['portion_count'] as int? ?? 1,
      status: _parseStatus(statusStr),
      seq: json['queueOrder'] as int? ?? fallbackSeq,
      createdAt: createdAtStr != null ? DateTime.tryParse(createdAtStr.toString()) ?? DateTime.now() : DateTime.now(),
      decidedAt: decidedAtStr != null ? DateTime.tryParse(decidedAtStr.toString()) : null,
      rejectReason: json['rejectReason']?.toString() ?? json['reject_reason']?.toString(),
    );
  }

  /// 1. POST /api/v1/claims (Ajukan Klaim Baru)
  Future<Claim?> createClaim({
    required String donationId,
    required int portionCount,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/claims');
      debugPrint('🚀 [FE ➔ BE] Mengirim pengajuan klaim ke $url (Donation: $donationId, Qty: $portionCount)...');
      final res = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'donationId': donationId,
          'portionCount': portionCount,
        }),
      ).timeout(ApiConfig.timeout);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null) {
          final claim = parseClaimFromJson(decoded['data'] as Map<String, dynamic>);
          debugPrint('✅ [BE ➔ FE] Berhasil! Klaim tersimpan di PostgreSQL backend (ID: ${claim.id}, Status: ${claim.status.name})');
          return claim;
        }
      } else {
        debugPrint('⚠️ [BE Error] createClaim status ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('⚠️ [Network Error] Gagal terhubung ke server backend: $e');
    }
    return null;
  }

  /// 2. GET /api/v1/claims/my-claims (Riwayat Klaim Saya)
  Future<List<Claim>?> getMyClaims() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/claims/my-claims');
      debugPrint('📡 [FE ➔ BE] Menghubungi backend untuk riwayat klaim: $url');
      final res = await _client.get(url).timeout(ApiConfig.timeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final list = decoded['data'] as List<dynamic>?;
        if (list != null) {
          final claims = list
              .map((item) => parseClaimFromJson(item as Map<String, dynamic>))
              .toList();
          debugPrint('✅ [BE ➔ FE] Terhubung ke Backend! Berhasil memuat ${claims.length} riwayat klaim dari database.');
          return claims;
        }
      } else {
        debugPrint('⚠️ [BE Error] getMyClaims status ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('⚠️ [Network Error] Backend belum terjangkau: $e');
    }
    return null;
  }

  /// 3. GET /api/v1/claims/incoming (Permintaan Masuk untuk Pendonor)
  Future<List<Claim>?> getIncomingClaims() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/claims/incoming');
      debugPrint('📡 [FE ➔ BE] Mengambil permintaan klaim masuk dari backend: $url');
      final res = await _client.get(url).timeout(ApiConfig.timeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final list = decoded['data'] as List<dynamic>?;
        if (list != null) {
          final claims = list
              .map((item) => parseClaimFromJson(item as Map<String, dynamic>))
              .toList();
          debugPrint('✅ [BE ➔ FE] Berhasil memuat ${claims.length} klaim masuk dari database backend.');
          return claims;
        }
      } else {
        debugPrint('⚠️ [BE Error] getIncomingClaims status ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('⚠️ [Network Error] Backend belum terjangkau: $e');
    }
    return null;
  }

  /// 4. PATCH /api/v1/claims/:id/decision (Terima atau Tolak Klaim)
  Future<Claim?> decideClaim({
    required String claimId,
    required String action, // 'ACCEPT' or 'REJECT'
    String? reason,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/claims/$claimId/decision');
      debugPrint('🚀 [FE ➔ BE] Mengirim keputusan $action untuk klaim $claimId ke backend...');
      final res = await _client.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': action,
          'reason': reason,
        }),
      ).timeout(ApiConfig.timeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null) {
          final claim = parseClaimFromJson(decoded['data'] as Map<String, dynamic>);
          debugPrint('✅ [BE ➔ FE] Keputusan $action berhasil disimpan di database backend!');
          return claim;
        }
      } else {
        debugPrint('⚠️ [BE Error] decideClaim status ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('⚠️ [Network Error] Gagal kirim keputusan ke backend: $e');
    }
    return null;
  }

  /// 5. PATCH /api/v1/claims/:id/cancel (Batalkan Klaim)
  Future<Claim?> cancelClaim({
    required String claimId,
    String? reason,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/claims/$claimId/cancel');
      debugPrint('🚀 [FE ➔ BE] Membatalkan klaim $claimId di backend...');
      final res = await _client.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reason': reason,
        }),
      ).timeout(ApiConfig.timeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null) {
          final claim = parseClaimFromJson(decoded['data'] as Map<String, dynamic>);
          debugPrint('✅ [BE ➔ FE] Pembatalan klaim berhasil dicatat di backend!');
          return claim;
        }
      } else {
        debugPrint('⚠️ [BE Error] cancelClaim status ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('⚠️ [Network Error] Gagal kirim pembatalan ke backend: $e');
    }
    return null;
  }

  /// 6. POST /api/v1/claims/verify (Verifikasi Pengambilan Fisik)
  Future<Claim?> verifyPickup({
    required String claimCode,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/claims/verify');
      final res = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'claimCode': claimCode,
        }),
      ).timeout(ApiConfig.timeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null) {
          return parseClaimFromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('⚠️ verifyPickup network error: $e');
    }
    return null;
  }
}
