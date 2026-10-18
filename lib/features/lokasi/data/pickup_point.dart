/// Status operasional sebuah titik pengambilan makanan.
enum PickupPointStatus { aktif, tutup, nonAktif }

/// Model data untuk satu titik pengambilan makanan.
class PickupPoint {
  const PickupPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.openTime,
    required this.closeTime,
    this.note = '',
    this.photoPath,
    this.activeListingCount = 0,
    this.status = PickupPointStatus.aktif,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  /// Format "HH:mm", contoh: "08:00"
  final String openTime;

  /// Format "HH:mm", contoh: "17:00"
  final String closeTime;

  final String note;

  /// Relative asset path atau null.
  final String? photoPath;

  final int activeListingCount;
  final PickupPointStatus status;

  PickupPoint copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? openTime,
    String? closeTime,
    String? note,
    String? photoPath,
    int? activeListingCount,
    PickupPointStatus? status,
  }) {
    return PickupPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
      activeListingCount: activeListingCount ?? this.activeListingCount,
      status: status ?? this.status,
    );
  }
}
