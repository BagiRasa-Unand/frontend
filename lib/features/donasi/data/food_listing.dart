import 'dart:convert';
import '../../../core/network/api_config.dart';

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

  factory FoodListing.fromJson(Map<String, dynamic> json) {
    FoodType parseFoodType(dynamic catId, dynamic catName) {
      final name = catName?.toString().toLowerCase() ?? '';
      if (name.contains('roti') || name.contains('kue') || name.contains('camilan') || catId == 2) {
        return FoodType.camilan;
      }
      if (name.contains('minuman') || name.contains('drink') || catId == 5) {
        return FoodType.minuman;
      }
      if (name.contains('mentah') || name.contains('buah') || name.contains('sayur') || catId == 3 || catId == 4) {
        return FoodType.lainnya;
      }
      return FoodType.makananBerat;
    }

    final createdAtRaw = json['createdAt'] ?? json['created_at'];
    final expiresAtRaw = json['expiresAt'] ?? json['expires_at'] ?? json['pickupEndAt'];

    String? photoUrl = json['photoPath']?.toString() ?? json['photo_path']?.toString();
    if (photoUrl == null || photoUrl.isEmpty) {
      if (json['photos'] is List && (json['photos'] as List).isNotEmpty) {
        final firstPhoto = (json['photos'] as List).first;
        if (firstPhoto is Map) {
          photoUrl = firstPhoto['photoUrl']?.toString() ?? firstPhoto['photo_url']?.toString();
        }
      } else if (json['photos'] is String) {
        try {
          final parsed = jsonDecode(json['photos']);
          if (parsed is List && parsed.isNotEmpty) {
            photoUrl = parsed.first['photoUrl']?.toString() ?? parsed.first['photo_url']?.toString();
          }
        } catch (_) {}
      }
    }
    final resolvedPhoto = ApiConfig.resolveImageUrl(photoUrl);

    return FoodListing(
      id: json['id']?.toString() ?? '',
      donorId: json['donorId']?.toString() ?? json['donor_id']?.toString() ?? '',
      donorName: json['donorName']?.toString() ?? json['donor_name']?.toString() ?? 'Donatur',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      foodType: parseFoodType(json['categoryId'] ?? json['category_id'], json['categoryName']),
      description: json['description']?.toString() ?? '',
      quantityTotal: json['quantityTotal'] as int? ?? json['total_portions'] as int? ?? 1,
      quantityRemaining: json['quantityRemaining'] as int? ?? json['remaining_portions'] as int? ?? 0,
      unit: json['unit']?.toString() ?? 'porsi',
      photoPath: resolvedPhoto,
      pickupPointId: json['pickupPointId']?.toString() ?? json['pickup_point_id']?.toString() ?? '',
      createdAt: createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: expiresAtRaw != null
          ? DateTime.tryParse(expiresAtRaw.toString()) ?? DateTime.now().add(const Duration(hours: 3))
          : DateTime.now().add(const Duration(hours: 3)),
    );
  }

  Map<String, dynamic> toJson() {
    int categoryId = 1;
    switch (foodType) {
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

    return {
      'id': id,
      'title': name,
      'description': description,
      'categoryId': categoryId,
      'pickupPointId': pickupPointId,
      'totalPortions': quantityTotal,
      'remainingPortions': quantityRemaining,
      'pickupStartAt': createdAt.toIso8601String(),
      'pickupEndAt': expiresAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
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
