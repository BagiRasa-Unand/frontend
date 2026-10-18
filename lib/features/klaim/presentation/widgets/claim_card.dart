import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../donasi/data/food_listing.dart';
import '../../../lokasi/data/pickup_point.dart';
import '../../../lokasi/presentation/countdown_screen.dart';
import '../../data/claim.dart';
import '../claim_detail_screen.dart';
import 'claim_status_badge.dart';

class ClaimCard extends StatelessWidget {
  const ClaimCard({
    super.key,
    required this.claim,
    required this.listing,
    this.pickupPoint,
    this.queuePosition,
    required this.now,
    this.onCancel,
    this.isHistory = false,
  });

  final Claim claim;
  final FoodListing listing;
  final PickupPoint? pickupPoint;
  final int? queuePosition;
  final DateTime now;
  final VoidCallback? onCancel;
  final bool isHistory;

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatHistoryDate(DateTime date, DateTime now) {
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Hari ini, ${_pad(date.hour)}:${_pad(date.minute)} WIB';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Kemarin, ${_pad(date.hour)}:${_pad(date.minute)} WIB';
    }
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final monthStr = (date.month >= 1 && date.month <= 12) ? months[date.month] : '';
    return '${date.day} $monthStr, ${_pad(date.hour)}:${_pad(date.minute)} WIB';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _formattedClaimCode(String id) {
    final digits = id.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '#BR-8821';
    final num = int.tryParse(digits) ?? 8821;
    // Map to realistic 4-digit code
    final code = (8800 + (num % 200)).toString();
    return '#BR-$code';
  }

  @override
  Widget build(BuildContext context) {
    if (isHistory) {
      return _buildHistoryCard(context);
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClaimDetailScreen(claimId: claim.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r20),
          boxShadow: const [
            BoxShadow(
              color: AppColors.border,
              blurRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Header Row with Photo & Info ───────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 80x80 Image with quantity overlay
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.r14),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: AppColors.toggleInactive,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (listing.photoPath != null &&
                            listing.photoPath!.isNotEmpty)
                          Image.asset(
                            listing.photoPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildFallbackPhoto(),
                          )
                        else
                          _buildFallbackPhoto(),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.overlay,
                              borderRadius: BorderRadius.circular(AppRadius.r6),
                            ),
                            child: Text(
                              '${claim.quantity} ${listing.unit}',
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.surface,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Listing Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ClaimStatusBadge(status: claim.status),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              _formattedClaimCode(claim.id),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.badge.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.name,
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 18,
                          height: 24 / 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            size: 14,
                            color: AppColors.primaryDeep,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pickupPoint?.name ?? 'Kantin Rektorat Stand 08',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Status-specific Action / Urgency Bar ────────────────────────
            if (claim.status == ClaimStatus.diterima) ...[
              _buildDiterimaBar(context),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '250m dari lokasimu',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ] else if (claim.status == ClaimStatus.menunggu) ...[
              _buildMenungguBar(),
            ] else if (claim.status == ClaimStatus.antre) ...[
              _buildAntreBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackPhoto() {
    return Container(
      color: AppColors.surfaceWarm,
      child: const Center(
        child: Icon(
          Icons.fastfood_rounded,
          size: 32,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDiterimaBar(BuildContext context) {
    final diff = listing.expiresAt.difference(now);
    final minutesLeft = diff.inMinutes;
    final timeStr = _formatTime(listing.expiresAt);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                  child: const Icon(
                    Icons.alarm_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ambil sebelum $timeStr WIB',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.badge.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            minutesLeft > 0
                                ? 'Sisa $minutesLeft menit'
                                : 'Waktu habis',
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // "KODE KLAIM" / "LIHAT WAKTU" action button
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CountdownScreen(
                    pickupDeadline: listing.expiresAt,
                    listingName: listing.name,
                    pickupPointName: pickupPoint?.name ?? 'Kantin Kampus',
                    merchantName: listing.donorName,
                    orderCode: _formattedClaimCode(claim.id),
                    voucherCode: claim.id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(4, '0'),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppRadius.r12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.r12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryDark,
                    blurRadius: 0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'KODE KLAIM',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.qr_code_2_rounded,
                    size: 14,
                    color: AppColors.surface,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenungguBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.pending_outlined,
            size: 18,
            color: AppColors.amber,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Menunggu konfirmasi pemilik stan (maks. 15 mnt)',
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCancel,
            child: Text(
              'Batal',
              style: AppTextStyles.badge.copyWith(
                color: AppColors.danger,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAntreBar() {
    final pos = queuePosition ?? 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: AppColors.border,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$pos',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Antrean ke-$pos ● Otomatis diterima jika ada sisa stok',
              style: AppTextStyles.caption.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onCancel,
            child: Text(
              'Batal',
              style: AppTextStyles.badge.copyWith(
                color: AppColors.danger,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ClaimDetailScreen(claimId: claim.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.border,
              blurRadius: 0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with photo and details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceWarm,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (listing.photoPath != null && listing.photoPath!.isNotEmpty)
                          Image.asset(
                            listing.photoPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildFallbackPhoto(),
                          )
                        else
                          _buildFallbackPhoto(),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xBF1F1B17), // rgba(31, 27, 23, 0.75)
                              borderRadius: BorderRadius.circular(AppRadius.r6),
                            ),
                            child: Text(
                              '${claim.quantity} Porsi',
                              style: GoogleFonts.nunitoSans(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              listing.name,
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 18,
                                height: 24 / 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          ClaimStatusBadge(
                            status: claim.status,
                            isHistory: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.storefront_outlined,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pickupPoint?.name ?? 'Kantin Kampus',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatHistoryDate(claim.createdAt, now),
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: claim.status == ClaimStatus.diterima
                                  ? AppColors.primarySoft
                                  : AppColors.surfaceWarm,
                              borderRadius: BorderRadius.circular(AppRadius.r6),
                            ),
                            child: Text(
                              _formattedClaimCode(claim.id),
                              style: AppTextStyles.badge.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: claim.status == ClaimStatus.diterima
                                    ? AppColors.primaryDeep
                                    : AppColors.slate,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Ditolak alert box
            if (claim.status == ClaimStatus.ditolak) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x66FFDAD6), // rgba(255, 218, 214, 0.4)
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            height: 16 / 12,
                            color: const Color(0xFF594238),
                          ),
                          children: [
                            const TextSpan(
                              text: 'Alasan: ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(
                              text: claim.rejectReason ?? 'Stok habis diambil rombongan seminar kampus.',
                              style: const TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Dibatalkan alert box
            if (claim.status == ClaimStatus.dibatalkan) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.creamSoft,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        claim.cancelReason != null
                            ? 'Dibatalkan oleh mahasiswa (${claim.cancelReason})'
                            : 'Dibatalkan oleh mahasiswa (jadwal praktikum mendadak).',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Menunggu bar if relevant
            if (claim.status == ClaimStatus.menunggu) ...[
              const SizedBox(height: 8),
              _buildMenungguBar(),
            ],

            // Antre bar if relevant
            if (claim.status == ClaimStatus.antre) ...[
              const SizedBox(height: 8),
              _buildAntreBar(),
            ],
          ],
        ),
      ),
    );
  }
}

