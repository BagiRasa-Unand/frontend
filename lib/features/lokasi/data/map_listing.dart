// TODO(integrate): replace with Module A FoodListing

/// Status ketersediaan listing makanan pada peta.
enum MapListingStatus {
  tersedia,
  segeraHabis,
}

/// Model data listing makanan aktif yang ditampilkan pada peta (Module C).
class MapListing {
  const MapListing({
    required this.id,
    required this.name,
    required this.pickupPointId,
    required this.pickupPointName,
    required this.categoryLabel,
    required this.distanceText,
    required this.timeLeft,
    required this.pickupDeadline,
    required this.status,
    this.portionCount = 1,
    this.discountTag,
    this.photoAsset,
    this.distanceMeters = 500,
    this.categoryKey = 'makanan_berat',
  });

  final String id;
  final String name;
  final String pickupPointId;
  final String pickupPointName;
  final String categoryLabel;

  /// Jarak estimasi dari dummy data (bukan hasil kalkulasi GPS realtime).
  final String distanceText;

  /// Teks waktu tersisa, contoh: "s.d 15.30"
  final String timeLeft;

  /// Deadline pengambilan makanan untuk countdown screen.
  final DateTime pickupDeadline;

  final MapListingStatus status;
  final int portionCount;
  final String? discountTag;
  final String? photoAsset;
  final int distanceMeters;
  final String categoryKey;
}

/// Data dummy listing aktif yang dicocokkan dengan screenshot Figma.
List<MapListing> seedMapListings() {
  final now = DateTime.now();
  final deadline1 = DateTime(now.year, now.month, now.day, 15, 30);
  final deadline2 = DateTime(now.year, now.month, now.day, 17, 0);
  final deadline3 = DateTime(now.year, now.month, now.day, 14, 0);

  return [
    MapListing(
      id: 'list-001',
      name: 'Nasi Ayam Bakar Rempah',
      pickupPointId: 'pp-001',
      pickupPointName: 'Kantin Teknik Sisfo',
      categoryLabel: 'Makanan Berat',
      categoryKey: 'makanan_berat',
      distanceText: '250 m',
      distanceMeters: 250,
      timeLeft: 's.d 15.30',
      pickupDeadline: deadline1.isBefore(now)
          ? now.add(const Duration(hours: 3))
          : deadline1,
      status: MapListingStatus.segeraHabis,
      portionCount: 2,
      discountTag: '-70%',
    ),
    MapListing(
      id: 'list-002',
      name: 'Paket Pastel & Lemper Ceria',
      pickupPointId: 'pp-002',
      pickupPointName: 'Kantin Rektorat',
      categoryLabel: 'Snack',
      categoryKey: 'snack',
      distanceText: '450 m',
      distanceMeters: 450,
      timeLeft: 's.d 17.00',
      pickupDeadline: deadline2.isBefore(now)
          ? now.add(const Duration(hours: 5))
          : deadline2,
      status: MapListingStatus.tersedia,
      portionCount: 6,
      discountTag: 'Snack',
    ),
    MapListing(
      id: 'list-003',
      name: 'Nasi Kotak Ayam Sambal Ijo',
      pickupPointId: 'pp-006',
      pickupPointName: 'Kantin Asrama Putra',
      categoryLabel: 'Makanan Berat',
      categoryKey: 'makanan_berat',
      distanceText: '600 m',
      distanceMeters: 600,
      timeLeft: 's.d 14.00',
      pickupDeadline: deadline3.isBefore(now)
          ? now.add(const Duration(hours: 2))
          : deadline3,
      status: MapListingStatus.segeraHabis,
      portionCount: 2,
      discountTag: '-50%',
    ),
  ];
}
