import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../donasi/data/food_listing.dart';
import '../../donasi/data/food_listing_repository.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../data/claim.dart';
import '../data/claim_repository.dart';

/// Opsi keputusan atau tindakan pada klaim (Module B).
enum ClaimDecision { accept, reject, cancel }

/// Menampilkan bottom sheet konfirmasi keputusan atau pembatalan klaim.
///
/// Mendukung [ClaimDecision] atau nilai boolean (untuk kompatibilitas pemanggil lama).
Future<void> showClaimDecisionSheet(
  BuildContext context,
  Claim claim,
  dynamic decision,
) async {
  ClaimDecision initialDecision;
  if (decision is ClaimDecision) {
    initialDecision = decision;
  } else if (decision == true) {
    initialDecision = ClaimDecision.accept;
  } else if (decision == false) {
    initialDecision = ClaimDecision.reject;
  } else {
    initialDecision = ClaimDecision.accept;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlay, // rgba(31,27,23,0.5)
    builder: (_) => ClaimDecisionSheet(
      claim: claim,
      initialDecision: initialDecision,
    ),
  );
}

/// Widget Bottom Sheet Konfirmasi Keputusan Klaim dengan 3 varian:
/// 1. Terima (Accept)
/// 2. Tolak (Reject)
/// 3. Batalkan (Cancel)
class ClaimDecisionSheet extends StatefulWidget {
  const ClaimDecisionSheet({
    super.key,
    required this.claim,
    required this.initialDecision,
  });

  final Claim claim;
  final ClaimDecision initialDecision;

  @override
  State<ClaimDecisionSheet> createState() => _ClaimDecisionSheetState();
}

class _ClaimDecisionSheetState extends State<ClaimDecisionSheet> {
  late ClaimDecision _decision;
  String? _selectedReason;

  static const List<String> _rejectReasons = [
    'Porsi sudah habis',
    'Stan tutup lebih awal',
    'Makanan tidak layak',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _decision = widget.initialDecision;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'M';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  void _onConfirm(
    BuildContext context,
    ClaimRepository claimRepo,
    Claim claim,
  ) {
    final ClaimResult result;
    final String successMessage;

    switch (_decision) {
      case ClaimDecision.accept:
        result = claimRepo.acceptClaim(claim.id, actorId: kCurrentUserId);
        successMessage = 'Klaim diterima';
        break;

      case ClaimDecision.reject:
        result = claimRepo.rejectClaim(
          claim.id,
          actorId: kCurrentUserId,
          reason: _selectedReason,
        );
        successMessage = 'Klaim ditolak';
        break;

      case ClaimDecision.cancel:
        result = claimRepo.cancelClaim(claim.id, actorId: kCurrentUserId);
        successMessage = 'Klaim dibatalkan';
        break;
    }

    if (!context.mounted) return;

    if (!result.ok) {
      // Pada kegagalan, tampilkan pesan error dan pertahankan sheet tetap terbuka
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Terjadi kesalahan memproses klaim'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Pada keberhasilan, tutup sheet dan tampilkan SnackBar sukses
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodRepo = context.watch<FoodListingRepository>();
    final pickupRepo = context.watch<PickupPointRepository>();
    final claimRepo = context.read<ClaimRepository>();

    final listing = foodRepo.getById(widget.claim.listingId);
    final pickupPoint =
        listing != null ? pickupRepo.getById(listing.pickupPointId) : null;

    final String listingTitle = listing?.name ?? 'Makanan Donasi';
    final String pickupTitle = pickupPoint?.name ?? 'Stan 04';
    final String subtitle = '$listingTitle • $pickupTitle';

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: MediaQuery.sizeOf(context).height * 0.95,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Interactive Variant Dev-Switcher Pills (Top of the Sheet)
            if (kShowDemoControls) ...[
              _buildDevSwitcher(),
              const SizedBox(height: 8),
            ],
            // Chunky Bottom Sheet Content Box
            Flexible(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.r28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x1F000000), // rgba(0, 0, 0, 0.12)
                      blurRadius: 24,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Drag Handle
                        Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(AppRadius.r9999),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Mascot Rasi
                        _buildMascot(_decision),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          _getTitle(_decision),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Subtitle
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Target Pill (Requester pill atau Food pill untuk Cancel)
                        _buildPill(_decision, widget.claim, listing),
                        const SizedBox(height: 16),
                        // Callout Box (Real numbers untuk accept)
                        _buildCallout(_decision, widget.claim, listing),
                        // Reason chips untuk varian Reject
                        if (_decision == ClaimDecision.reject) ...[
                          const SizedBox(height: 14),
                          _buildReasonSection(),
                        ],
                        const SizedBox(height: 20),
                        // Action Buttons
                        _buildActionButtons(context, claimRepo, widget.claim),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.r9999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000), // rgba(0, 0, 0, 0.15)
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSwitcherItem('1. Terima', ClaimDecision.accept),
            const SizedBox(width: 4),
            _buildSwitcherItem('2. Tolak', ClaimDecision.reject),
            const SizedBox(width: 4),
            _buildSwitcherItem('3. Batalkan', ClaimDecision.cancel),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitcherItem(String label, ClaimDecision decision) {
    final isSelected = _decision == decision;
    return GestureDetector(
      onTap: () => setState(() => _decision = decision),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.r9999),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.primaryDark,
                    blurRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.badge.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.surface : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMascot(ClaimDecision decision) {
    final String assetPath;
    switch (decision) {
      case ClaimDecision.accept:
        assetPath = 'assets/images/rasi_happy.png';
        break;
      case ClaimDecision.reject:
      case ClaimDecision.cancel:
        assetPath = 'assets/images/rasi_worried.png';
        break;
    }

    return Image.asset(
      assetPath,
      width: 96,
      height: 96,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // TODO: assets/images/rasi_happy.png belum ada di repo, gunakan rasi_empty.png sebagai fallback per Rule 6
        return Image.asset(
          'assets/images/rasi_empty.png',
          width: 96,
          height: 96,
          fit: BoxFit.contain,
        );
      },
    );
  }

  String _getTitle(ClaimDecision decision) {
    switch (decision) {
      case ClaimDecision.accept:
        return 'Terima klaim ini?';
      case ClaimDecision.reject:
        return 'Tolak klaim ini?';
      case ClaimDecision.cancel:
        return 'Batalkan klaim ini?';
    }
  }

  Widget _buildPill(
    ClaimDecision decision,
    Claim claim,
    FoodListing? listing,
  ) {
    if (decision == ClaimDecision.cancel) {
      // Varian Cancel: menampilkan nama makanan dan jumlah porsi
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadius.r9999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                size: 14,
                color: AppColors.surface,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                listing?.name ?? 'Makanan Donasi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '•',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.shopping_bag_outlined,
              size: 13,
              color: AppColors.primaryDeep,
            ),
            const SizedBox(width: 4),
            Text(
              '${claim.quantity} Porsi',
              style: AppTextStyles.badge.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDeep,
              ),
            ),
          ],
        ),
      );
    }

    // Varian Terima & Tolak: Target Student Pill
    final initials = _getInitials(claim.claimantName);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: AppTextStyles.badge.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              claim.claimantName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.heading.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '•',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.shopping_bag_outlined,
            size: 13,
            color: AppColors.primaryDeep,
          ),
          const SizedBox(width: 4),
          Text(
            '${claim.quantity} Porsi',
            style: AppTextStyles.badge.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDeep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallout(
    ClaimDecision decision,
    Claim claim,
    FoodListing? listing,
  ) {
    if (decision == ClaimDecision.accept) {
      final int remaining = listing?.quantityRemaining ?? 0;
      final int stockAfter = remaining - claim.quantity;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0x3379F3EA), // rgba(121, 243, 234, 0.2)
          borderRadius: BorderRadius.circular(AppRadius.r12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_rounded,
              size: 18,
              color: AppColors.tealDeep,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    height: 20 / 14,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    const TextSpan(text: 'Stok berkurang '),
                    TextSpan(
                      text: '${claim.quantity} porsi',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: '. Sisa stok setelah diterima: '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.cyanBadge,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$stockAfter porsi',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cyanBadgeText,
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(
                      text: '. Mahasiswa akan langsung menerima notifikasi pengambilan.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (decision == ClaimDecision.reject) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warningSoft,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          border: Border.all(color: AppColors.warningBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 18,
              color: AppColors.warningText,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Klaim yang ditolak tidak dapat diubah kembali. Mahasiswa dalam antrean berikutnya akan dipromosikan jika tersedia.',
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  height: 20 / 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Cancel variant
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: AppColors.warningBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.warningText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Porsi yang dibatalkan akan langsung dikembalikan ke stok stan atau dialihkan ke mahasiswa di antrean berikutnya.',
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                height: 20 / 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alasan Penolakan (opsional):',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _rejectReasons.map((reason) {
            final isSelected = _selectedReason == reason;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedReason = isSelected ? null : reason;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.warningSoft : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.r9999),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  reason,
                  style: AppTextStyles.badge.copyWith(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.primaryDeep : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ClaimRepository claimRepo,
    Claim claim,
  ) {
    final String primaryLabel;
    final Color primaryFill;
    final Color primaryShadow;
    final IconData primaryIcon;
    final String secondaryLabel;

    switch (_decision) {
      case ClaimDecision.accept:
        primaryLabel = 'YA, TERIMA KLAIM';
        primaryFill = AppColors.primary;
        primaryShadow = AppColors.primaryDark;
        primaryIcon = Icons.check_circle_outline_rounded;
        secondaryLabel = 'BATAL';
        break;

      case ClaimDecision.reject:
        primaryLabel = 'YA, TOLAK';
        primaryFill = AppColors.danger;
        primaryShadow = AppColors.dangerDark;
        primaryIcon = Icons.cancel_outlined;
        secondaryLabel = 'BATAL';
        break;

      case ClaimDecision.cancel:
        primaryLabel = 'YA, BATALKAN';
        primaryFill = AppColors.danger;
        primaryShadow = AppColors.dangerDark;
        primaryIcon = Icons.cancel_outlined;
        secondaryLabel = 'TETAP KLAIM';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChunkyButton(
          label: primaryLabel,
          height: 48,
          fillColor: primaryFill,
          shadowColor: primaryShadow,
          borderRadius: AppRadius.r12,
          icon: Icon(
            primaryIcon,
            color: AppColors.surface,
            size: 18,
          ),
          onTap: () => _onConfirm(context, claimRepo, claim),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neutralButton,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            alignment: Alignment.center,
            child: Text(
              secondaryLabel,
              style: AppTextStyles.heading.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.28,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
