import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/app_session.dart';
import '../../donasi/data/food_listing.dart';
import '../../donasi/data/food_listing_repository.dart';
import '../../lokasi/data/pickup_point.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../data/claim.dart';
import '../data/claim_repository.dart';

enum ClaimHistoryFilter { semua, diterima, ditolak, dibatalkan }

class ClaimHistoryController extends ChangeNotifier {
  ClaimHistoryController({
    required this.claimRepo,
    required this.foodRepo,
    required this.pickupRepo,
  }) {
    claimRepo.addListener(_onRepositoryChanged);
    foodRepo.addListener(_onRepositoryChanged);
    pickupRepo.addListener(_onRepositoryChanged);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  final ClaimRepository claimRepo;
  final FoodListingRepository foodRepo;
  final PickupPointRepository pickupRepo;

  Timer? _timer;
  DateTime _now = DateTime.now();
  ClaimHistoryFilter _filter = ClaimHistoryFilter.semua;
  bool _showEmptyPreview = false;

  DateTime get now => _now;
  ClaimHistoryFilter get filter => _filter;
  bool get showEmptyPreview => _showEmptyPreview;

  int get totalSaved => claimRepo.totalAcceptedQuantity(kCurrentUserId);

  int get level {
    if (totalSaved < 6) return 1;
    if (totalSaved < 11) return 2;
    if (totalSaved < 21) return 3;
    return 3 + ((totalSaved - 20) ~/ 10);
  }

  int get nextLevelTarget {
    if (totalSaved < 6) return 6;
    if (totalSaved < 11) return 11;
    if (totalSaved < 21) return 20;
    return 20 + ((level - 2) * 10);
  }

  int get remainingToNextLevel {
    final target = nextLevelTarget;
    final rem = target - totalSaved;
    return rem > 0 ? rem : 1;
  }

  double get carbonSavedKg => totalSaved * 0.4;

  List<Claim> get allClaims => claimRepo.getByClaimant(kCurrentUserId);

  List<Claim> get claims {
    if (_showEmptyPreview) return const [];
    final all = allClaims;
    return switch (_filter) {
      ClaimHistoryFilter.semua => all,
      ClaimHistoryFilter.diterima =>
        all.where((c) => c.status == ClaimStatus.diterima).toList(),
      ClaimHistoryFilter.ditolak =>
        all.where((c) => c.status == ClaimStatus.ditolak).toList(),
      ClaimHistoryFilter.dibatalkan =>
        all.where((c) => c.status == ClaimStatus.dibatalkan).toList(),
    };
  }

  int countFor(ClaimHistoryFilter f) {
    final all = allClaims;
    return switch (f) {
      ClaimHistoryFilter.semua => all.length,
      ClaimHistoryFilter.diterima =>
        all.where((c) => c.status == ClaimStatus.diterima).length,
      ClaimHistoryFilter.ditolak =>
        all.where((c) => c.status == ClaimStatus.ditolak).length,
      ClaimHistoryFilter.dibatalkan =>
        all.where((c) => c.status == ClaimStatus.dibatalkan).length,
    };
  }

  void setFilter(ClaimHistoryFilter f) {
    if (_filter != f) {
      _filter = f;
      notifyListeners();
    }
  }

  void setShowEmptyPreview(bool value) {
    if (_showEmptyPreview != value) {
      _showEmptyPreview = value;
      notifyListeners();
    }
  }

  FoodListing? getListing(String id) => foodRepo.getById(id);
  PickupPoint? getPickupPoint(String id) => pickupRepo.getById(id);
  int? getQueuePosition(String claimId) => claimRepo.queuePosition(claimId);

  void _onRepositoryChanged() => notifyListeners();

  @override
  void dispose() {
    _timer?.cancel();
    claimRepo.removeListener(_onRepositoryChanged);
    foodRepo.removeListener(_onRepositoryChanged);
    pickupRepo.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}

