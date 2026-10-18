import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../donasi/data/food_listing.dart';
import '../../donasi/data/food_listing_repository.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../data/claim_repository.dart';
import '../logic/claim_history_controller.dart';
import 'widgets/claim_card.dart';

class ClaimHistoryScreen extends StatelessWidget {
  const ClaimHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClaimHistoryController(
        claimRepo: context.read<ClaimRepository>(),
        foodRepo: context.read<FoodListingRepository>(),
        pickupRepo: context.read<PickupPointRepository>(),
      ),
      child: const _ClaimHistoryBody(),
    );
  }
}

class _ClaimHistoryBody extends StatelessWidget {
  const _ClaimHistoryBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClaimHistoryController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _HistoryHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // View Switcher (Daftar Riwayat vs Pratinjau Kosong)
                  _ViewSwitcher(controller: controller),
                  const SizedBox(height: 16),

                  // Reward Gamification Summary Card
                  _RewardSummaryCard(controller: controller),
                  const SizedBox(height: 16),

                  // Filter Chips Row
                  _FilterChipsRow(controller: controller),
                  const SizedBox(height: 16),

                  // Cards List or Empty State
                  if (controller.showEmptyPreview || controller.claims.isEmpty)
                    const _EmptyClaimHistory()
                  else
                    ...controller.claims.map((claim) {
                      final listing = controller.getListing(claim.listingId) ??
                          FoodListing(
                            id: claim.listingId,
                            donorId: 'unknown',
                            donorName: 'Pemilik Stan',
                            name: 'Makanan Surplus',
                            foodType: FoodType.makananBerat,
                            description: '',
                            quantityTotal: claim.quantity,
                            quantityRemaining: 0,
                            pickupPointId: 'pp-001',
                            createdAt: claim.createdAt,
                            expiresAt: claim.createdAt.add(const Duration(hours: 2)),
                          );

                      final pickupPoint = controller.getPickupPoint(listing.pickupPointId);
                      final queuePos = controller.getQueuePosition(claim.id);

                      return ClaimCard(
                        claim: claim,
                        listing: listing,
                        pickupPoint: pickupPoint,
                        queuePosition: queuePos,
                        now: controller.now,
                        isHistory: true,
                      );
                    }),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header (Back button, overline, title, user avatar)
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: AppColors.background.withValues(alpha: 0.96),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.border,
                    blurRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BAGIRASA',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.55,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Riwayat Klaim',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryDeep,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 16,
              color: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive View Switcher (Daftar Riwayat vs Pratinjau Kosong)
// ─────────────────────────────────────────────────────────────────────────────
class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({required this.controller});

  final ClaimHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final isEmptyPreview = controller.showEmptyPreview;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tab 1: Daftar Riwayat
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setShowEmptyPreview(false),
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: !isEmptyPreview ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  boxShadow: !isEmptyPreview
                      ? const [
                          BoxShadow(
                            color: AppColors.border,
                            blurRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 14,
                      color: !isEmptyPreview
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Daftar Riwayat',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: !isEmptyPreview
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab 2: Pratinjau Kosong
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setShowEmptyPreview(true),
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: isEmptyPreview ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  boxShadow: isEmptyPreview
                      ? const [
                          BoxShadow(
                            color: AppColors.border,
                            blurRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_satisfied_rounded,
                      size: 14,
                      color: isEmptyPreview
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pratinjau Kosong',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isEmptyPreview
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reward Gamification Summary Card
// ─────────────────────────────────────────────────────────────────────────────
class _RewardSummaryCard extends StatelessWidget {
  const _RewardSummaryCard({required this.controller});

  final ClaimHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final totalSaved = controller.totalSaved;
    final level = controller.level;
    final carbonKg = controller.carbonSavedKg.toStringAsFixed(1);
    final remainingPorsi = controller.remainingToNextLevel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.reward.withValues(alpha: 0.3),
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
          // Top Row: Metric & Level badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.r16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.primaryDark,
                          blurRadius: 0,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.volunteer_activism_rounded,
                      size: 22,
                      color: AppColors.surface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$totalSaved',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.64,
                              color: AppColors.textPrimary,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Porsi',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total porsi pangan terselamatkan',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.r9999),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      blurRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Lv. $level',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.22,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Middle: Carbon saving banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.eco_rounded,
                  size: 16,
                  color: Color(0xFF43A047),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        const TextSpan(text: 'Menghemat '),
                        TextSpan(
                          text: '~$carbonKg kg emisi karbon ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: 'dari makanan terbuang!'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Bottom status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Penyelamat Pangan Aktif',
                style: GoogleFonts.nunitoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.22,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$remainingPorsi porsi lagi ke Lv. ${level + 1}!',
                style: GoogleFonts.nunitoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.22,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Chips Row
// ─────────────────────────────────────────────────────────────────────────────
class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({required this.controller});

  final ClaimHistoryController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Semua',
            filter: ClaimHistoryFilter.semua,
            badgeColor: controller.filter == ClaimHistoryFilter.semua
                ? Colors.white.withValues(alpha: 0.2)
                : AppColors.surfaceWarm,
            badgeTextColor: controller.filter == ClaimHistoryFilter.semua
                ? Colors.white
                : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Diterima',
            filter: ClaimHistoryFilter.diterima,
            badgeColor: controller.filter == ClaimHistoryFilter.diterima
                ? Colors.white.withValues(alpha: 0.2)
                : const Color(0x8079F3EA), // rgba(121, 243, 234, 0.5)
            badgeTextColor: controller.filter == ClaimHistoryFilter.diterima
                ? Colors.white
                : const Color(0xFF006A65),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Ditolak',
            filter: ClaimHistoryFilter.ditolak,
            badgeColor: controller.filter == ClaimHistoryFilter.ditolak
                ? Colors.white.withValues(alpha: 0.2)
                : AppColors.dangerSoft,
            badgeTextColor: controller.filter == ClaimHistoryFilter.ditolak
                ? Colors.white
                : AppColors.error,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Dibatalkan',
            filter: ClaimHistoryFilter.dibatalkan,
            badgeColor: controller.filter == ClaimHistoryFilter.dibatalkan
                ? Colors.white.withValues(alpha: 0.2)
                : AppColors.surfaceWarm,
            badgeTextColor: controller.filter == ClaimHistoryFilter.dibatalkan
                ? Colors.white
                : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required ClaimHistoryFilter filter,
    required Color badgeColor,
    required Color badgeTextColor,
  }) {
    final isSelected = controller.filter == filter;
    final count = controller.countFor(filter);

    return GestureDetector(
      onTap: () => controller.setFilter(filter),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r9999),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.primaryDark : AppColors.border,
              blurRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(AppRadius.r9999),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.nunitoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.22,
                  color: badgeTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State with Rasi Mascot
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyClaimHistory extends StatelessWidget {
  const _EmptyClaimHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/rasi_empty.png',
            height: 140,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.slate,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Riwayat Klaim',
            style: AppTextStyles.heading.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Semua makanan surplus yang pernah kamu klaim akan tercatat rapi di sini.',
            style: AppTextStyles.caption.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

