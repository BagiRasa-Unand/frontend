import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../../core/network/api_config.dart';
import 'pickup_point.dart';

/// Koordinat pusat kampus (Universitas Andalas, Padang).
/// Tim dapat mengubah nilai ini sesuai lokasi kampus masing-masing.
const double kCampusCenterLat = -0.9140;
const double kCampusCenterLng = 100.4590;
const LatLng kCampusCenter = LatLng(kCampusCenterLat, kCampusCenterLng);

/// Repository untuk [PickupPoint] yang terintegrasi langsung dengan
/// BagiRasa REST API (Modul C - Titik Pengambilan & Geospasial).
///
/// Mengimplementasikan [ChangeNotifier] dan caching lokal dengan fallback
/// otomatis agar aplikasi tetap responsif saat offline.
class PickupPointRepository extends ChangeNotifier {
  PickupPointRepository({String? customBaseUrl}) {
    if (customBaseUrl != null) {
      _baseUrl = customBaseUrl;
    }
    _items = _seed();
    // Sinkronisasi otomatis dari Backend REST API saat inisialisasi
    fetchFromApi();
  }

  /// Base URL API Backend BagiRasa
  static String get defaultBaseUrl => ApiConfig.baseUrl;

  String _baseUrl = ApiConfig.baseUrl;
  String get baseUrl => _baseUrl;
  set baseUrl(String url) {
    _baseUrl = url;
    notifyListeners();
  }

  late List<PickupPoint> _items;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Public API (Sinkron & Kompatibel dengan UI yang ada) ────────────────────

  List<PickupPoint> getAll() => List.unmodifiable(_items);

  PickupPoint? getById(String id) {
    try {
      return _items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Sinkronisasi titik lokasi dari backend PostgreSQL via REST API
  Future<void> fetchFromApi() async {
    _isLoading = true;
    _errorMessage = null;

    try {
      final uri = Uri.parse('$_baseUrl/locations/pickup-points');
      final res = await http.get(uri).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final List<dynamic> dataList = body['data'];
          if (dataList.isNotEmpty) {
            _items = dataList
                .map((item) => PickupPoint.fromJson(item as Map<String, dynamic>))
                .toList();
            _errorMessage = null;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      // Mode offline / server belum aktif: gunakan data seed lokal tanpa crash
      debugPrint('[PickupPointRepository] Info: Gagal terhubung ke backend API ($_baseUrl). Menggunakan data lokal. Err: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengambil titik lokasi terdekat menggunakan query spasial PostGIS ST_DWithin & ST_Distance
  Future<List<PickupPoint>> fetchNearby({
    required double lat,
    required double lng,
    double radiusMeters = 5000,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/locations/pickup-points/nearby?lat=$lat&lng=$lng&radius=$radiusMeters',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] is List) {
          final List<dynamic> list = body['data'];
          return list
              .map((item) => PickupPoint.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('[PickupPointRepository] Error fetchNearby: $e');
    }

    // Fallback: kembalikan semua item aktif yang ada
    return _items.where((p) => p.status == PickupPointStatus.aktif).toList();
  }

  /// Menambahkan titik lokasi baru (Optimistic UI + kirim POST ke backend)
  void add(PickupPoint point) {
    _items.add(point);
    notifyListeners();

    _syncAdd(point);
  }

  Future<void> _syncAdd(PickupPoint point) async {
    try {
      final uri = Uri.parse('$_baseUrl/locations/pickup-points');
      final payload = {
        'name': point.name,
        'address': point.address,
        'latitude': point.latitude,
        'longitude': point.longitude,
        'openTime': point.openTime,
        'closeTime': point.closeTime,
        'note': point.note,
        'picName': point.note,
      };

      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 201) {
        final body = jsonDecode(res.body);
        if (body['success'] == true && body['data'] != null) {
          final created = PickupPoint.fromJson(body['data']);
          final idx = _items.indexWhere((p) => p.id == point.id);
          if (idx != -1) {
            _items[idx] = created;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint('[PickupPointRepository] Sinkronisasi POST gagal: $e');
    }
  }

  /// Memperbarui titik lokasi (Optimistic UI + kirim PUT ke backend)
  void update(PickupPoint updated) {
    final idx = _items.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _items[idx] = updated;
      notifyListeners();

      _syncUpdate(updated);
    }
  }

  Future<void> _syncUpdate(PickupPoint point) async {
    try {
      final uri = Uri.parse('$_baseUrl/locations/pickup-points/${point.id}');
      final payload = {
        'name': point.name,
        'address': point.address,
        'latitude': point.latitude,
        'longitude': point.longitude,
        'openTime': point.openTime,
        'closeTime': point.closeTime,
        'note': point.note,
        'status': point.status.name,
        'isActive': point.status == PickupPointStatus.aktif,
      };

      await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[PickupPointRepository] Sinkronisasi PUT gagal: $e');
    }
  }

  /// Menghapus titik lokasi (Optimistic UI + kirim DELETE ke backend)
  void delete(String id) {
    _items.removeWhere((p) => p.id == id);
    notifyListeners();

    _syncDelete(id);
  }

  Future<void> _syncDelete(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/locations/pickup-points/$id');
      await http.delete(uri).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('[PickupPointRepository] Sinkronisasi DELETE gagal: $e');
    }
  }

  // ── Seed data fallback (agar aplikasi tidak blank saat offline) ────────────

  List<PickupPoint> _seed() {
    return [
      PickupPoint(
        id: 'b0000000-0000-0000-0000-000000000001',
        name: 'Posko PKM Unand (Pusat Kegiatan Mahasiswa)',
        address: 'Lantai 1 Gedung PKM Universitas Andalas, Limau Manis, Padang',
        latitude: -0.91450000,
        longitude: 100.46320000,
        openTime: '08:00',
        closeTime: '18:00',
        note: 'Rahmat PIC PKM (081211112222)',
        activeListingCount: 1,
        status: PickupPointStatus.aktif,
      ),
      PickupPoint(
        id: 'b0000000-0000-0000-0000-000000000002',
        name: 'Gedung Kuliah Bersama (GKB) E',
        address: 'Lobi Utama GKB E Kampus Unand Limau Manis',
        latitude: -0.91320000,
        longitude: 100.45890000,
        openTime: '09:00',
        closeTime: '17:00',
        note: 'Budi Satpam GKB (081233334444)',
        activeListingCount: 1,
        status: PickupPointStatus.aktif,
      ),
      PickupPoint(
        id: 'b0000000-0000-0000-0000-000000000003',
        name: 'Kantin Fakultas Teknologi Informasi (FTI)',
        address: 'Kantin Sebelah Timur Gedung B FTI Unand',
        latitude: -0.91580000,
        longitude: 100.46510000,
        openTime: '08:30',
        closeTime: '16:30',
        note: 'Ibu Ani Kantin (081255556666)',
        activeListingCount: 0,
        status: PickupPointStatus.aktif,
      ),
      PickupPoint(
        id: 'b0000000-0000-0000-0000-000000000004',
        name: 'Kantin Teknik Sisfo',
        address: 'Gedung Teknik Informasi, Lt. 1, Kampus Unand',
        latitude: kCampusCenterLat + 0.0007,
        longitude: kCampusCenterLng - 0.0003,
        openTime: '08:00',
        closeTime: '16:00',
        note: 'Tersedia setiap hari kerja.',
        activeListingCount: 5,
        status: PickupPointStatus.aktif,
      ),
      PickupPoint(
        id: 'b0000000-0000-0000-0000-000000000005',
        name: 'Kantin Rektorat',
        address: 'Gedung Rektorat, Lantai Dasar, Kampus Unand',
        latitude: kCampusCenterLat + 0.0005,
        longitude: kCampusCenterLng + 0.0012,
        openTime: '07:30',
        closeTime: '17:00',
        note: 'Selasar Gedung Rektorat.',
        activeListingCount: 8,
        status: PickupPointStatus.aktif,
      ),
      PickupPoint(
        id: 'b0000000-0000-0000-0000-000000000006',
        name: 'Kantin Asrama Putra',
        address: 'Gedung Asrama Putra Blok A, Kampus Unand',
        latitude: kCampusCenterLat - 0.0008,
        longitude: kCampusCenterLng - 0.0012,
        openTime: '07:00',
        closeTime: '15:00',
        note: 'Porsi terbatas menjelang sore.',
        activeListingCount: 2,
        status: PickupPointStatus.aktif,
      ),
      PickupPoint(
        id: 'b0000000-0000-0000-0000-000000000007',
        name: 'Kantin FEB Corner',
        address: 'Gedung Fakultas Ekonomi Bisnis, Selasar Timur',
        latitude: kCampusCenterLat + 0.0020,
        longitude: kCampusCenterLng - 0.0015,
        openTime: '09:00',
        closeTime: '17:00',
        note: '',
        activeListingCount: 1,
        status: PickupPointStatus.aktif,
      ),
      PickupPoint(
        id: 'b0000000-0000-0000-0000-000000000008',
        name: 'Kantin Faperta Barat',
        address: 'Gedung Pertanian, Pintu Barat, Kampus Unand',
        latitude: kCampusCenterLat - 0.0025,
        longitude: kCampusCenterLng - 0.0030,
        openTime: '08:00',
        closeTime: '15:00',
        note: 'Khusus hari Senin–Jumat.',
        activeListingCount: 2,
        status: PickupPointStatus.aktif,
      ),
      PickupPoint(
        id: 'b0000000-0000-0000-0000-000000000009',
        name: 'Stand BEM Pusat',
        address: 'Gedung PKM, Halaman Utama, Kampus Unand',
        latitude: kCampusCenterLat + 0.0005,
        longitude: kCampusCenterLng + 0.0040,
        openTime: '10:00',
        closeTime: '18:00',
        note: 'Aktif saat ada kegiatan BEM.',
        activeListingCount: 0,
        status: PickupPointStatus.nonAktif,
      ),
    ];
  }
}
