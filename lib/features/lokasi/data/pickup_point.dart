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

  factory PickupPoint.fromJson(Map<String, dynamic> json) {
    double parseCoordinate(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    PickupPointStatus parseStatus(dynamic st, dynamic isActive) {
      if (isActive == false) return PickupPointStatus.nonAktif;
      final s = st?.toString().toLowerCase();
      if (s == 'tutup') return PickupPointStatus.tutup;
      if (s == 'nonaktif' || s == 'non_aktif') return PickupPointStatus.nonAktif;
      return PickupPointStatus.aktif;
    }

    return PickupPoint(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: parseCoordinate(json['latitude']),
      longitude: parseCoordinate(json['longitude']),
      openTime: json['openTime']?.toString() ?? json['openHour']?.toString() ?? '08:00',
      closeTime: json['closeTime']?.toString() ?? json['closeHour']?.toString() ?? '20:00',
      note: json['note']?.toString() ?? json['picName']?.toString() ?? '',
      photoPath: json['photoPath']?.toString() ?? json['photoUrl']?.toString(),
      activeListingCount: (json['activeListingCount'] as num?)?.toInt() ?? 0,
      status: parseStatus(json['status'], json['isActive']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'openTime': openTime,
      'closeTime': closeTime,
      'note': note,
      'photoPath': photoPath,
      'status': status.name,
      'isActive': status == PickupPointStatus.aktif,
      'activeListingCount': activeListingCount,
    };
  }
}
