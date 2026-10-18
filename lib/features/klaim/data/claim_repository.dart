import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../../core/app_session.dart';
import '../../donasi/data/food_listing.dart';
import '../../donasi/data/food_listing_repository.dart';
import 'claim.dart';

class ClaimRepository extends ChangeNotifier {
  ClaimRepository({
    required this.foodRepo,
    DateTime Function()? clock,
  })  : _clock = clock ?? DateTime.now {
    foodRepo.addListener(_onFoodRepoChanged);
  }

  final FoodListingRepository foodRepo;
  final DateTime Function() _clock;
  final List<Claim> _claims = [];

  void Function(ClaimEvent)? onEvent;

  int _nextSeq = 1;
  bool _suspendReconcile = false;
  Timer? _ticker;

  DateTime _now() => _clock();

  void _onFoodRepoChanged() {
    if (!_suspendReconcile) {
      reconcile();
    }
  }

  void _emit(ClaimEventType type, Claim claim) {
    onEvent?.call(ClaimEvent(type: type, claim: claim));
  }

  void _updateClaim(Claim claim) {
    final index = _claims.indexWhere((c) => c.id == claim.id);
    if (index != -1) {
      _claims[index] = claim;
    }
  }

  // --- Queries ---

  Claim? getById(String claimId) {
    for (final claim in _claims) {
      if (claim.id == claimId) return claim;
    }
    return null;
  }

  List<Claim> getByClaimant(String userId) {
    final list = _claims.where((c) => c.claimantId == userId).toList()
      ..sort((a, b) {
        final dateComp = b.createdAt.compareTo(a.createdAt);
        if (dateComp != 0) return dateComp;
        return b.seq.compareTo(a.seq);
      });
    return List.unmodifiable(list);
  }

  List<Claim> getIncomingFor(String donorId) {
    final list = _claims.where((c) {
      final listing = foodRepo.getById(c.listingId);
      return listing != null && listing.donorId == donorId;
    }).toList()
      ..sort((a, b) {
        final dateComp = b.createdAt.compareTo(a.createdAt);
        if (dateComp != 0) return dateComp;
        return b.seq.compareTo(a.seq);
      });
    return List.unmodifiable(list);
  }

  List<Claim> getForListing(String listingId) {
    final list = _claims.where((c) => c.listingId == listingId).toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));
    return List.unmodifiable(list);
  }

  int reservedFor(String listingId) {
    return _claims
        .where((c) => c.listingId == listingId && c.status == ClaimStatus.menunggu)
        .fold(0, (sum, c) => sum + c.quantity);
  }

  int availableToRequest(String listingId) {
    final listing = foodRepo.getById(listingId);
    if (listing == null) return 0;
    final available = listing.quantityRemaining - reservedFor(listingId);
    return available > 0 ? available : 0;
  }

  int? queuePosition(String claimId) {
    final claim = getById(claimId);
    if (claim == null || claim.status != ClaimStatus.antre) {
      return null;
    }
    final queued = _claims
        .where((c) => c.listingId == claim.listingId && c.status == ClaimStatus.antre)
        .toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));
    final index = queued.indexWhere((c) => c.id == claimId);
    if (index == -1) return null;
    return index + 1;
  }

  Claim? activeClaimOf(String userId, String listingId) {
    for (final claim in _claims.reversed) {
      if (claim.claimantId == userId && claim.listingId == listingId) {
        if (claim.status == ClaimStatus.menunggu ||
            claim.status == ClaimStatus.antre) {
          return claim;
        }
      }
    }
    return null;
  }

  int totalAcceptedQuantity(String userId) {
    return _claims
        .where((c) => c.claimantId == userId && c.status == ClaimStatus.diterima)
        .fold(0, (sum, c) => sum + c.quantity);
  }

  // --- Commands ---

  ClaimResult submitClaim({
    required FoodListing listing,
    required String claimantId,
    required String claimantName,
    required int quantity,
  }) {
    final currentListing = foodRepo.getById(listing.id) ?? listing;
    final now = _now();

    if (quantity <= 0) {
      return ClaimResult.failure('Jumlah porsi harus lebih dari 0');
    }

    if (claimantId == currentListing.donorId) {
      return ClaimResult.failure('Pemilik donasi tidak dapat mengklaim makanannya sendiri');
    }

    if (quantity > currentListing.quantityRemaining) {
      return ClaimResult.failure('Jumlah pesanan melebihi sisa porsi yang tersedia');
    }

    final listingStatus = currentListing.statusAt(now);
    if (listingStatus == ListingStatus.kadaluarsa ||
        listingStatus == ListingStatus.habisDiklaim) {
      return ClaimResult.failure('Makanan sudah tidak tersedia atau telah kadaluarsa');
    }

    if (activeClaimOf(claimantId, currentListing.id) != null) {
      return ClaimResult.failure('Anda sudah memiliki klaim aktif untuk makanan ini');
    }

    final hasQueue = _claims.any(
      (c) => c.listingId == currentListing.id && c.status == ClaimStatus.antre,
    );
    final available = availableToRequest(currentListing.id);

    final ClaimStatus claimStatus;
    if (!hasQueue && quantity <= available) {
      claimStatus = ClaimStatus.menunggu;
    } else {
      claimStatus = ClaimStatus.antre;
    }

    final seq = _nextSeq++;
    final claim = Claim(
      id: 'claim-$seq',
      listingId: currentListing.id,
      claimantId: claimantId,
      claimantName: claimantName,
      quantity: quantity,
      status: claimStatus,
      seq: seq,
      createdAt: now,
    );

    _claims.add(claim);
    _emit(ClaimEventType.submitted, claim);
    notifyListeners();

    return ClaimResult.success(claim);
  }

  ClaimResult acceptClaim(String claimId, {String? actorId}) {
    final claim = getById(claimId);
    if (claim == null) {
      return ClaimResult.failure('Klaim tidak ditemukan');
    }

    if (claim.status != ClaimStatus.menunggu) {
      return ClaimResult.failure('Hanya klaim berstatus menunggu yang dapat diterima');
    }

    final listing = foodRepo.getById(claim.listingId);
    if (listing == null) {
      return ClaimResult.failure('Listing makanan tidak ditemukan');
    }

    if (actorId == null || actorId != listing.donorId) {
      return ClaimResult.failure('Hanya pemilik donasi yang dapat menerima klaim');
    }

    _suspendReconcile = true;
    bool decreased = false;
    try {
      decreased = foodRepo.decreaseStock(claim.listingId, claim.quantity);
    } finally {
      _suspendReconcile = false;
    }

    if (!decreased) {
      return ClaimResult.failure('Gagal menerima klaim: stok tidak mencukupi');
    }

    final accepted = claim.copyWith(
      status: ClaimStatus.diterima,
      decidedAt: _now(),
    );
    _updateClaim(accepted);
    _emit(ClaimEventType.accepted, accepted);
    notifyListeners();

    reconcile();

    return ClaimResult.success(accepted);
  }

  ClaimResult rejectClaim(String claimId, {String? actorId, String? reason}) {
    final claim = getById(claimId);
    if (claim == null) {
      return ClaimResult.failure('Klaim tidak ditemukan');
    }

    if (claim.status != ClaimStatus.menunggu) {
      return ClaimResult.failure('Hanya klaim berstatus menunggu yang dapat ditolak');
    }

    final listing = foodRepo.getById(claim.listingId);
    if (listing == null) {
      return ClaimResult.failure('Listing makanan tidak ditemukan');
    }

    if (actorId == null || actorId != listing.donorId) {
      return ClaimResult.failure('Hanya pemilik donasi yang dapat menolak klaim');
    }

    final rejected = claim.copyWith(
      status: ClaimStatus.ditolak,
      decidedAt: _now(),
      rejectReason: reason,
    );
    _updateClaim(rejected);

    promoteQueue(claim.listingId);
    _emit(ClaimEventType.rejected, rejected);
    notifyListeners();

    return ClaimResult.success(rejected);
  }

  ClaimResult cancelClaim(String claimId, {String? actorId}) {
    final claim = getById(claimId);
    if (claim == null) {
      return ClaimResult.failure('Klaim tidak ditemukan');
    }

    if (claim.status != ClaimStatus.menunggu && claim.status != ClaimStatus.antre) {
      return ClaimResult.failure('Klaim yang sudah diproses tidak dapat dibatalkan');
    }

    if (actorId == null || actorId != claim.claimantId) {
      return ClaimResult.failure('Hanya pemohon yang dapat membatalkan klaim');
    }

    final cancelled = claim.copyWith(
      status: ClaimStatus.dibatalkan,
      decidedAt: _now(),
      cancelReason: 'Dibatalkan oleh pemohon',
    );
    _updateClaim(cancelled);

    promoteQueue(claim.listingId);
    _emit(ClaimEventType.cancelled, cancelled);
    notifyListeners();

    return ClaimResult.success(cancelled);
  }

  // --- Internal & Lifecycle ---

  void promoteQueue(String listingId) {
    final listing = foodRepo.getById(listingId);
    if (listing == null) return;

    while (true) {
      final queued = _claims
          .where((c) => c.listingId == listingId && c.status == ClaimStatus.antre)
          .toList()
        ..sort((a, b) => a.seq.compareTo(b.seq));

      if (queued.isEmpty) break;

      final head = queued.first;

      if (head.quantity > listing.quantityRemaining) {
        final autoCancelled = head.copyWith(
          status: ClaimStatus.dibatalkan,
          decidedAt: _now(),
          cancelReason: 'Stok tidak lagi mencukupi',
        );
        _updateClaim(autoCancelled);
        _emit(ClaimEventType.autoCancelled, autoCancelled);
        notifyListeners();
        continue;
      }

      final available = availableToRequest(listingId);
      if (head.quantity <= available) {
        final promoted = head.copyWith(
          status: ClaimStatus.menunggu,
        );
        _updateClaim(promoted);
        _emit(ClaimEventType.promoted, promoted);
        notifyListeners();
        continue;
      }

      // Stop at first misfit
      break;
    }
  }

  void reconcile() {
    final now = _now();
    var changed = false;

    final pendingClaims = _claims
        .where((c) => c.status == ClaimStatus.menunggu || c.status == ClaimStatus.antre)
        .toList();

    for (final claim in pendingClaims) {
      final listing = foodRepo.getById(claim.listingId);
      String? cancelReason;

      if (listing == null) {
        cancelReason = 'Listing sudah dihapus';
      } else {
        final status = listing.statusAt(now);
        if (status == ListingStatus.kadaluarsa) {
          cancelReason = 'Waktu pengambilan sudah habis';
        } else if (status == ListingStatus.habisDiklaim) {
          cancelReason = 'Makanan sudah habis diklaim';
        }
      }

      if (cancelReason != null) {
        final autoCancelled = claim.copyWith(
          status: ClaimStatus.dibatalkan,
          decidedAt: now,
          cancelReason: cancelReason,
        );
        _updateClaim(autoCancelled);
        _emit(ClaimEventType.autoCancelled, autoCancelled);
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  void processReminders({
    Duration lead = const Duration(minutes: 30),
    Duration? leadOverride,
  }) {
    final now = _now();
    final threshold = leadOverride ?? lead;
    var changed = false;

    final acceptedClaims = _claims
        .where((c) => c.status == ClaimStatus.diterima && !c.reminderSent)
        .toList();

    for (final claim in acceptedClaims) {
      final listing = foodRepo.getById(claim.listingId);
      if (listing != null &&
          now.isBefore(listing.expiresAt) &&
          listing.expiresAt.difference(now) <= threshold) {
        final updated = claim.copyWith(reminderSent: true);
        _updateClaim(updated);
        _emit(ClaimEventType.reminderDue, updated);
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  void tick() {
    reconcile();
    processReminders();
  }

  void startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => tick());
  }

  void seedDemoData() {
    final now = _now();

    // (1) on another donor's listing with stock >= 4, kCurrentUserId submits qty 2 -> menunggu
    final l1 = foodRepo.getAll().cast<FoodListing?>().firstWhere(
          (l) =>
              l != null &&
              l.donorId != kCurrentUserId &&
              l.quantityRemaining >= 4 &&
              l.statusAt(now) != ListingStatus.kadaluarsa,
          orElse: () => null,
        );
    if (l1 == null) {
      debugPrint('Skipping seedDemoData step 1: no suitable listing found');
    } else {
      submitClaim(
        listing: l1,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 2,
      );
    }

    // (2) on another listing, kCurrentUserId submits qty 1 and it is accepted with the donor as actor
    final l2 = foodRepo.getAll().cast<FoodListing?>().firstWhere(
          (l) =>
              l != null &&
              l.donorId != kCurrentUserId &&
              l.id != l1?.id &&
              l.quantityRemaining >= 1 &&
              l.statusAt(now) != ListingStatus.kadaluarsa,
          orElse: () => null,
        );
    if (l2 == null) {
      debugPrint('Skipping seedDemoData step 2: no suitable listing found');
    } else {
      final res2 = submitClaim(
        listing: l2,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 1,
      );
      if (res2.ok && res2.claim != null) {
        acceptClaim(res2.claim!.id, actorId: l2.donorId);
      }
    }

    // (3) on another listing, kCurrentUserId submits qty 1 and it is rejected by the donor
    final l3 = foodRepo.getAll().cast<FoodListing?>().firstWhere(
          (l) =>
              l != null &&
              l.donorId != kCurrentUserId &&
              l.id != l1?.id &&
              activeClaimOf(kCurrentUserId, l.id) == null &&
              l.quantityRemaining >= 1 &&
              l.statusAt(now) != ListingStatus.kadaluarsa,
          orElse: () => null,
        );
    if (l3 == null) {
      debugPrint('Skipping seedDemoData step 3: no suitable listing found');
    } else {
      final res3 = submitClaim(
        listing: l3,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 1,
      );
      if (res3.ok && res3.claim != null) {
        rejectClaim(
          res3.claim!.id,
          actorId: l3.donorId,
          reason: 'Porsi sudah dialokasikan untuk kegiatan lain',
        );
      }
    }

    // (4) on a listing from another donor, dummy claimant 'Rudi' submits qty = remaining, then kCurrentUserId submits qty 1 -> antre
    final l4 = foodRepo.getAll().cast<FoodListing?>().firstWhere(
          (l) =>
              l != null &&
              l.donorId != kCurrentUserId &&
              l.id != l1?.id &&
              activeClaimOf(kCurrentUserId, l.id) == null &&
              l.quantityRemaining >= 1 &&
              l.statusAt(now) != ListingStatus.kadaluarsa,
          orElse: () => null,
        );
    if (l4 == null) {
      debugPrint('Skipping seedDemoData step 4: no suitable listing found');
    } else {
      final freshL4 = foodRepo.getById(l4.id) ?? l4;
      submitClaim(
        listing: freshL4,
        claimantId: 'user-rudi',
        claimantName: 'Rudi',
        quantity: freshL4.quantityRemaining,
      );
      submitClaim(
        listing: freshL4,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 1,
      );
    }

    // (5) on a listing owned by kCurrentUserId with stock >= 6: dummy 'Budi' qty 3 -> menunggu, dummy 'Sari' qty 2 -> menunggu, dummy 'Andi' qty 3 -> antre
    final l5 = foodRepo.getAll().cast<FoodListing?>().firstWhere(
          (l) =>
              l != null &&
              l.donorId == kCurrentUserId &&
              l.quantityRemaining >= 6 &&
              l.statusAt(now) != ListingStatus.kadaluarsa,
          orElse: () => null,
        );
    if (l5 == null) {
      debugPrint('Skipping seedDemoData step 5: no suitable listing found');
    } else {
      if (l5.quantityRemaining > 6) {
        final excess = l5.quantityRemaining - 6;
        final preClaim = submitClaim(
          listing: l5,
          claimantId: 'user-alokasi-awal',
          claimantName: 'Penyaluran Komunitas',
          quantity: excess,
        );
        if (preClaim.ok && preClaim.claim != null) {
          acceptClaim(preClaim.claim!.id, actorId: l5.donorId);
        }
      }
      final freshL5 = foodRepo.getById(l5.id) ?? l5;
      submitClaim(
        listing: freshL5,
        claimantId: 'user-budi',
        claimantName: 'Budi',
        quantity: 3,
      );
      submitClaim(
        listing: freshL5,
        claimantId: 'user-sari',
        claimantName: 'Sari',
        quantity: 2,
      );
      submitClaim(
        listing: freshL5,
        claimantId: 'user-andi',
        claimantName: 'Andi',
        quantity: 3,
      );
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    foodRepo.removeListener(_onFoodRepoChanged);
    super.dispose();
  }
}
