import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'pickup_point.dart';

/// Koordinat pusat kampus (Universitas Andalas, Padang).
/// Tim dapat mengubah nilai ini sesuai lokasi kampus masing-masing.
const double kCampusCenterLat = -0.9140;
const double kCampusCenterLng = 100.4590;
const LatLng kCampusCenter = LatLng(kCampusCenterLat, kCampusCenterLng);

/// In-memory repository for [PickupPoint].
///
/// Implements [ChangeNotifier] so Provider consumers rebuild automatically
/// when data changes.
class PickupPointRepository extends ChangeNotifier {
  PickupPointRepository() {
    _items = _seed();
  }

  late List<PickupPoint> _items;

  // ── Public API ─────────────────────────────────────────────────────────────

  List<PickupPoint> getAll() => List.unmodifiable(_items);

  PickupPoint? getById(String id) {
    try {
      return _items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void add(PickupPoint point) {
    _items.add(point);
    notifyListeners();
  }

  void update(PickupPoint updated) {
    final idx = _items.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _items[idx] = updated;
      notifyListeners();
    }
  }

  void delete(String id) {
    _items.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ── Seed data (names/addresses from screenshot) ────────────────────────────

  List<PickupPoint> _seed() {
    return [
      PickupPoint(
        id: 'pp-001',
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
        id: 'pp-002',
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
        id: 'pp-006',
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
        id: 'pp-003',
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
        id: 'pp-004',
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
        id: 'pp-005',
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
