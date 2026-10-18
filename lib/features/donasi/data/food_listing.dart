enum ListingStatus { tersedia, segeraHabis, habisDiklaim, kadaluarsa }

enum FoodType { makananBerat, camilan, minuman, lainnya }

class FoodListing {
  const FoodListing({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.name,
    required this.foodType,
    required this.description,
    required this.quantityTotal,
    required this.quantityRemaining,
    this.unit = 'porsi',
    this.photoPath,
    required this.pickupPointId,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String donorId;
  final String donorName;
  final String name;
  final FoodType foodType;
  final String description;
  final int quantityTotal;
  final int quantityRemaining;
  final String unit;
  final String? photoPath;
  final String pickupPointId;
  final DateTime createdAt;
  final DateTime expiresAt;

  int get claimedQuantity => quantityTotal - quantityRemaining;

  ListingStatus statusAt(DateTime now) {
    if (quantityRemaining <= 0) return ListingStatus.habisDiklaim;
    if (!now.isBefore(expiresAt)) return ListingStatus.kadaluarsa;

    final remaining = expiresAt.difference(now);
    final isTimeCritical = remaining <= const Duration(minutes: 30);
    final isStockCritical = quantityRemaining * 5 <= quantityTotal;
    if (isTimeCritical || isStockCritical) {
      return ListingStatus.segeraHabis;
    }
    return ListingStatus.tersedia;
  }

  Duration timeLeftAt(DateTime now) {
    final remaining = expiresAt.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  FoodListing copyWith({
    String? id,
    String? donorId,
    String? donorName,
    String? name,
    FoodType? foodType,
    String? description,
    int? quantityTotal,
    int? quantityRemaining,
    String? unit,
    String? photoPath,
    String? pickupPointId,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return FoodListing(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      name: name ?? this.name,
      foodType: foodType ?? this.foodType,
      description: description ?? this.description,
      quantityTotal: quantityTotal ?? this.quantityTotal,
      quantityRemaining: quantityRemaining ?? this.quantityRemaining,
      unit: unit ?? this.unit,
      photoPath: photoPath ?? this.photoPath,
      pickupPointId: pickupPointId ?? this.pickupPointId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class DonorStats {
  const DonorStats({
    required this.totalSaved,
    required this.totalListings,
    required this.expiredCount,
  });

  final int totalSaved;
  final int totalListings;
  final int expiredCount;
}