import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/app_session.dart';
import '../../donasi/data/food_listing.dart';
import '../../donasi/data/food_listing_repository.dart';
import '../../lokasi/data/pickup_point.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../data/claim.dart';
import '../data/claim_repository.dart';

class ClaimTabController extends ChangeNotifier {
  ClaimTabController({
    required this.claimRepo,
    required this.foodRepo,
    required this.pickupRepo,
  }) {
    claimRepo.addListener(_onRepoChanged);
    foodRepo.addListener(_onRepoChanged);
    pickupRepo.addListener(_onRepoChanged);

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

  int _selectedSegment = 0;
  bool _simulateEmpty = false;
  int _incomingFilterIndex = 0; // 0: Perlu diputuskan, 1: Sudah diputuskan

  DateTime get now => _now;
  int get selectedSegment => _selectedSegment;
  bool get simulateEmpty => _simulateEmpty;
  int get incomingFilterIndex => _incomingFilterIndex;

  void _onRepoChanged() {
    notifyListeners();
  }

  void setSegment(int index) {
    if (_selectedSegment == index) return;
    _selectedSegment = index;
    notifyListeners();
  }

  void toggleSimulateEmpty() {
    _simulateEmpty = !_simulateEmpty;
    notifyListeners();
  }

  void setIncomingFilter(int index) {
    if (_incomingFilterIndex == index) return;
    _incomingFilterIndex = index;
    notifyListeners();
  }

  // --- Data Accessors ---

  FoodListing? getListing(String listingId) => foodRepo.getById(listingId);

  PickupPoint? getPickupPoint(String pointId) => pickupRepo.getById(pointId);

  int? getQueuePosition(String claimId) => claimRepo.queuePosition(claimId);

  int get mySavedPortions => claimRepo.totalAcceptedQuantity(kCurrentUserId);

  int get incomingPendingCount {
    return claimRepo.getIncomingFor(kCurrentUserId).where((c) {
      return c.status == ClaimStatus.menunggu || c.status == ClaimStatus.antre;
    }).length;
  }

  List<Claim> get myClaims {
    if (_simulateEmpty) return const [];

    final raw = claimRepo.getByClaimant(kCurrentUserId);
    return raw.where((c) {
      if (c.status != ClaimStatus.menunggu &&
          c.status != ClaimStatus.antre &&
          c.status != ClaimStatus.diterima) {
        return false;
      }
      final listing = foodRepo.getById(c.listingId);
      if (listing == null) return false;
      return listing.expiresAt.isAfter(_now);
    }).toList();
  }

  List<Claim> get incomingClaims {
    if (_simulateEmpty) return const [];

    final raw = claimRepo.getIncomingFor(kCurrentUserId);
    if (_incomingFilterIndex == 0) {
      // Perlu diputuskan: menunggu & antre
      return raw.where((c) {
        return c.status == ClaimStatus.menunggu || c.status == ClaimStatus.antre;
      }).toList();
    } else {
      // Sudah diputuskan: diterima, ditolak, dibatalkan
      return raw.where((c) {
        return c.status == ClaimStatus.diterima ||
            c.status == ClaimStatus.ditolak ||
            c.status == ClaimStatus.dibatalkan;
      }).toList();
    }
  }

  Map<String, List<Claim>> get groupedIncomingClaims {
    final map = <String, List<Claim>>{};
    for (final claim in incomingClaims) {
      map.putIfAbsent(claim.listingId, () => []).add(claim);
    }
    return map;
  }

  // --- Actions ---

  void cancelClaim(BuildContext context, String claimId) {
    final result = claimRepo.cancelClaim(claimId, actorId: kCurrentUserId);
    if (!result.ok && result.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // --- Demo Actions (only if kShowDemoControls) ---

  void simulateAccept(BuildContext context, String claimId, String donorId) {
    final result = claimRepo.acceptClaim(claimId, actorId: donorId);
    if (!result.ok && result.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!), backgroundColor: Colors.red),
      );
    }
  }

  void simulateReject(BuildContext context, String claimId, String donorId) {
    final result = claimRepo.rejectClaim(
      claimId,
      actorId: donorId,
      reason: 'Ditolak via simulasi demo',
    );
    if (!result.ok && result.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!), backgroundColor: Colors.red),
      );
    }
  }

  void simulateIncomingClaim(BuildContext context, {required bool fullStock}) {
    // Submit a claim from dummy claimant 'Dewi' on one of current user's listings
    final myListings = foodRepo.getByDonor(kCurrentUserId).where((l) {
      return l.quantityRemaining > 0 && l.expiresAt.isAfter(_now);
    }).toList();

    if (myListings.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada donasi aktif milikmu yang bersisa.'),
          ),
        );
      }
      return;
    }

    final targetListing = myListings.first;
    final qty = fullStock ? targetListing.quantityRemaining : 1;

    final result = claimRepo.submitClaim(
      listing: targetListing,
      claimantId: 'dummy-dewi',
      claimantName: 'Dewi',
      quantity: qty,
    );

    if (!result.ok && result.error != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!), backgroundColor: Colors.red),
      );
    }
  }

  void triggerReminder(BuildContext context) {
    claimRepo.processReminders(leadOverride: const Duration(days: 30));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemicu pengingat 30 hari telah diproses.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    claimRepo.removeListener(_onRepoChanged);
    foodRepo.removeListener(_onRepoChanged);
    pickupRepo.removeListener(_onRepoChanged);
    super.dispose();
  }
}

