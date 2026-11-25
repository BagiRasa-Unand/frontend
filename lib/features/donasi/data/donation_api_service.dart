import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../core/network/api_config.dart';
import 'food_listing.dart';

class DonationApiService {
  DonationApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// 1. GET /api/v1/donations (Daftar donasi aktif dari PostgreSQL)
  Future<List<FoodListing>?> getDonations({
    String? categoryId,
    String? pickupPointId,
    bool? isHalal,
    bool? isUrgent,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (pickupPointId != null) queryParams['pickupPointId'] = pickupPointId;
      if (isHalal != null) queryParams['isHalal'] = isHalal.toString();
      if (isUrgent != null) queryParams['isUrgent'] = isUrgent.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('${ApiConfig.baseUrl}/donations').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      debugPrint('📡 [FE ➔ BE] Memuat daftar donasi dari: $uri');
      final res = await _client.get(uri).timeout(ApiConfig.timeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] is List) {
          final list = decoded['data'] as List<dynamic>;
          final listings = list
              .map((item) => FoodListing.fromJson(item as Map<String, dynamic>))
              .toList();
          debugPrint('✅ [BE ➔ FE] Sukses memuat ${listings.length} donasi makanan dari database backend.');
          return listings;
        }
      } else {
        debugPrint('⚠️ [BE Error] getDonations status ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      debugPrint('⚠️ [Network Error] Gagal memuat donasi dari backend: $e');
    }
    return null;
  }

  /// 2. POST /api/v1/donations (Buat Donasi Baru + Upload Foto Multipart)
  Future<FoodListing?> createDonation(FoodListing listing, {String? imagePath}) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/donations');
      debugPrint('🚀 [FE ➔ BE] Mengirim listing donasi baru ke: $uri...');

      int categoryId = 1;
      switch (listing.foodType) {
        case FoodType.makananBerat:
          categoryId = 1;
          break;
        case FoodType.camilan:
          categoryId = 2;
          break;
        case FoodType.lainnya:
          categoryId = 3;
          break;
        case FoodType.minuman:
          categoryId = 5;
          break;
      }

      String cleanPath = imagePath ?? '';
      if (cleanPath.startsWith('file://')) {
        try {
          cleanPath = Uri.parse(cleanPath).toFilePath();
        } catch (_) {}
      }

      // Kasus A: Upload file fisik lokal (Android / iOS / Desktop)
      final isLocalFile = cleanPath.isNotEmpty &&
          !kIsWeb &&
          !cleanPath.startsWith('http') &&
          !cleanPath.startsWith('assets') &&
          !cleanPath.startsWith('data:image/') &&
          File(cleanPath).existsSync();

      // Kasus B: Upload Base64 (Flutter Web)
      final isBase64 = cleanPath.startsWith('data:image/');

      if (isLocalFile || isBase64) {
        final request = http.MultipartRequest('POST', uri);
        request.fields['title'] = listing.name;
        request.fields['description'] = listing.description;
        request.fields['categoryId'] = categoryId.toString();
        request.fields['pickupPointId'] = listing.pickupPointId;
        request.fields['totalPortions'] = listing.quantityTotal.toString();
        request.fields['pickupStartAt'] = listing.createdAt.toIso8601String();
        request.fields['pickupEndAt'] = listing.expiresAt.toIso8601String();
        request.fields['expiresAt'] = listing.expiresAt.toIso8601String();
        request.fields['isHalal'] = 'true';

        if (isLocalFile) {
          final ext = cleanPath.split('.').last.toLowerCase();
          final subType = (ext == 'png' || ext == 'webp') ? ext : 'jpeg';
          final file = await http.MultipartFile.fromPath(
            'photos',
            cleanPath,
            contentType: MediaType('image', subType),
          );
          request.files.add(file);
        } else if (isBase64) {
          final separator = cleanPath.indexOf(',');
          if (separator > 0) {
            String subType = 'jpeg';
            final header = cleanPath.substring(0, separator);
            if (header.contains('png')) subType = 'png';
            if (header.contains('webp')) subType = 'webp';

            final bytes = base64Decode(cleanPath.substring(separator + 1));
            final file = http.MultipartFile.fromBytes(
              'photos',
              bytes,
              filename: 'upload.$subType',
              contentType: MediaType('image', subType),
            );
            request.files.add(file);
          }
        }

        final streamed = await request.send().timeout(const Duration(seconds: 15));
        final res = await http.Response.fromStream(streamed);

        if (res.statusCode == 201 || res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded['data'] != null) {
            debugPrint('✅ [BE ➔ FE] Donasi + foto berhasil tersimpan di database & server backend!');
            return FoodListing.fromJson(decoded['data'] as Map<String, dynamic>);
          }
        } else {
          debugPrint('⚠️ [BE Error] createDonation multipart status ${res.statusCode}: ${res.body}');
        }
      } else {
        // Fallback JSON request biasa jika tanpa file gambar
        final res = await _client.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(listing.toJson()),
        ).timeout(ApiConfig.timeout);

        if (res.statusCode == 201 || res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          if (decoded['data'] != null) {
            debugPrint('✅ [BE ➔ FE] Donasi berhasil tersimpan di database backend!');
            return FoodListing.fromJson(decoded['data'] as Map<String, dynamic>);
          }
        } else {
          debugPrint('⚠️ [BE Error] createDonation json status ${res.statusCode}: ${res.body}');
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Network Error] Gagal simpan donasi ke backend: $e');
    }
    return null;
  }

  /// 3. PUT /api/v1/donations/:id (Perbarui Donasi)
  Future<FoodListing?> updateDonation(FoodListing listing) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/donations/${listing.id}');
      final res = await _client.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(listing.toJson()),
      ).timeout(ApiConfig.timeout);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null) {
          return FoodListing.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Network Error] Gagal update donasi ke backend: $e');
    }
    return null;
  }

  /// 4. PATCH /api/v1/donations/:id/cancel (Batalkan Donasi)
  Future<bool> cancelDonation(String id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/donations/$id/cancel');
      final res = await _client.patch(uri).timeout(ApiConfig.timeout);
      return res.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [Network Error] Gagal cancel donasi ke backend: $e');
      return false;
    }
  }

  /// 5. GET /api/v1/donations/stats (Statistik Penyelamatan Makanan)
  Future<DonorStats?> getStats() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/donations/stats');
      final res = await _client.get(uri).timeout(ApiConfig.timeout);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final data = decoded['data'];
        if (data != null) {
          return DonorStats(
            totalSaved: data['savedPortions'] as int? ?? 0,
            totalListings: data['totalListings'] as int? ?? 0,
            expiredCount: data['expiredDonations'] as int? ?? 0,
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Network Error] Gagal load stats dari backend: $e');
    }
    return null;
  }
}
