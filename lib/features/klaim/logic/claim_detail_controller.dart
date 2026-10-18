import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../donasi/data/food_listing.dart';
import '../../donasi/data/food_listing_repository.dart';
import '../../lokasi/data/pickup_point.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../data/claim.dart';
import '../data/claim_repository.dart';

/// Controller untuk mengelola state dan data layar Detail Klaim (Module B).
class ClaimDetailController extends ChangeNotifier {
  ClaimDetailController({
    required this.claimId,
    required this.claimRepository,
    required this.foodRepository,
    required this.pickupPointRepository,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _now = _clock();
    claimRepository.addListener(_onRepositoryChanged);
    foodRepository.addListener(_onRepositoryChanged);

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _now = _clock();
      notifyListeners();
    });
  }

  final String claimId;
  final ClaimRepository claimRepository;
  final FoodListingRepository foodRepository;
  final PickupPointRepository pickupPointRepository;
  final DateTime Function() _clock;

  Timer? _timer;
  late DateTime _now;
  ClaimStatus? _simulatedStatus;

  DateTime get now => _now;
  ClaimStatus? get simulatedStatus => _simulatedStatus;

  /// Membaca claim saat ini berdasarkan id langsung dari [ClaimRepository].
  Claim? get claim => claimRepository.getById(claimId);

  /// Membaca data listing terkait dari [FoodListingRepository].
  FoodListing? get listing {
    final c = claim;
    if (c == null) return null;
    return foodRepository.getById(c.listingId);
  }

  /// Membaca data titik temu terkait dari [PickupPointRepository].
  PickupPoint? get pickupPoint {
    final l = listing;
    if (l == null) return null;
    return pickupPointRepository.getById(l.pickupPointId);
  }

  /// Posisi antrean (1-based) jika status klaim adalah antre.
  int? get queuePosition {
    final c = claim;
    if (c == null) return null;
    return claimRepository.queuePosition(c.id);
  }

  /// Status klaim yang efektif ditampilkan (mendukung override simulasi saat demo).
  ClaimStatus get effectiveStatus =>
      _simulatedStatus ?? (claim?.status ?? ClaimStatus.menunggu);

  /// Sisa waktu sebelum listing kedaluwarsa.
  Duration get timeLeft =>
      listing != null ? listing!.timeLeftAt(_now) : Duration.zero;

  /// Estimasi penghematan jejak karbon berdasarkan porsi klaim.
  double get carbonSavedKg => (claim?.quantity ?? 1) * 1.4;

  /// Mengubah status simulasi untuk keperluan demo kontrol.
  void setSimulatedStatus(ClaimStatus? status) {
    if (_simulatedStatus == status) {
      _simulatedStatus = null;
    } else {
      _simulatedStatus = status;
    }
    notifyListeners();
  }

  void _onRepositoryChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    claimRepository.removeListener(_onRepositoryChanged);
    foodRepository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}

