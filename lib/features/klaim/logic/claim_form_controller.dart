import 'package:flutter/foundation.dart';

import '../../../core/app_session.dart';
import '../../donasi/data/food_listing.dart';
import '../data/claim.dart';
import '../data/claim_repository.dart';

/// Variant tampilan callout pada bottom sheet Form Klaim.
enum ClaimFormVariant {
  normal,  // Varian A: Stok Tersedia / Menunggu Persetujuan Stan
  queue,   // Varian B: Masuk Antrean
  blocked, // Varian C: Terkunci karena klaim aktif sudah ada
}

/// Controller untuk form klaim makanan (Module B).
class ClaimFormController extends ChangeNotifier {
  ClaimFormController({
    required this.listing,
    required this.claimRepository,
    int initialQuantity = 1,
  }) : _quantity = initialQuantity.clamp(
          1,
          listing.quantityRemaining > 0 ? listing.quantityRemaining : 1,
        );

  final FoodListing listing;
  final ClaimRepository claimRepository;

  int _quantity;
  bool _isSubmitting = false;
  ClaimFormVariant? _previewVariant;

  int get quantity => _quantity;
  bool get isSubmitting => _isSubmitting;
  ClaimFormVariant? get previewVariant => _previewVariant;

  int get minQuantity => 1;
  int get maxQuantity =>
      listing.quantityRemaining > 0 ? listing.quantityRemaining : 1;

  /// Setiap porsi menghemat sekitar 1.4 kg jejak karbon CO2.
  double get carbonSavedKg => _quantity * 1.4;

  /// Mengetahui apakah pengguna saat ini sudah memiliki klaim aktif di listing ini.
  bool get hasActiveClaim =>
      claimRepository.activeClaimOf(kCurrentUserId, listing.id) != null;

  /// Jumlah klaim yang sedang dalam status antre untuk listing ini.
  int get queuedClaimsCount => claimRepository
      .getForListing(listing.id)
      .where((c) => c.status == ClaimStatus.antre)
      .length;

  /// Posisi antrean untuk klaim baru jika masuk antre.
  int get queuePositionForNewClaim => queuedClaimsCount + 1;

  /// Varian yang dihitung secara dinamis sesuai spesifikasi:
  /// - Jika activeClaimOf(kCurrentUserId, listing.id) ada -> blocked (Varian C)
  /// - Jika ada klaim antre atau quantity > availableToRequest -> queue (Varian B)
  /// - Selain itu -> normal (Varian A)
  ClaimFormVariant get computedVariant {
    if (hasActiveClaim) {
      return ClaimFormVariant.blocked;
    }
    final inRepo = claimRepository.foodRepo.getById(listing.id);
    final available = inRepo != null
        ? claimRepository.availableToRequest(listing.id)
        : (listing.quantityRemaining - claimRepository.reservedFor(listing.id));
    if (queuedClaimsCount > 0 || _quantity > available) {
      return ClaimFormVariant.queue;
    }
    return ClaimFormVariant.normal;
  }

  /// Varian aktif (mengutamakan preview override untuk keperluan demo jika dipilih).
  ClaimFormVariant get variant => _previewVariant ?? computedVariant;

  bool get canIncrement =>
      _quantity < maxQuantity &&
      variant != ClaimFormVariant.blocked &&
      !_isSubmitting;

  bool get canDecrement =>
      _quantity > minQuantity &&
      variant != ClaimFormVariant.blocked &&
      !_isSubmitting;

  void increment() {
    if (canIncrement) {
      _quantity++;
      notifyListeners();
    }
  }

  void decrement() {
    if (canDecrement) {
      _quantity--;
      notifyListeners();
    }
  }

  void setPreviewVariant(ClaimFormVariant? variant) {
    if (_previewVariant == variant) {
      _previewVariant = null;
    } else {
      _previewVariant = variant;
    }
    notifyListeners();
  }

  /// Mengajukan klaim ke ClaimRepository.
  Future<ClaimResult> submitClaim({
    required String claimantId,
    required String claimantName,
  }) async {
    if (_isSubmitting) {
      return ClaimResult.failure('Sedang memproses permintaan...');
    }
    _isSubmitting = true;
    notifyListeners();

    try {
      final result = claimRepository.submitClaim(
        listing: listing,
        claimantId: claimantId,
        claimantName: claimantName,
        quantity: _quantity,
      );
      return result;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
