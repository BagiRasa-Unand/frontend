import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../donasi/data/food_listing_repository.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../data/claim.dart';
import '../data/claim_repository.dart';
import '../logic/claim_tab_controller.dart';
import 'claim_history_screen.dart';
import 'widgets/claim_card.dart';
import 'widgets/incoming_claim_row.dart';

class ClaimTabScreen extends StatelessWidget {
  const ClaimTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClaimTabController>(
      create: (ctx) => ClaimTabController(
        claimRepo: ctx.read<ClaimRepository>(),
        foodRepo: ctx.read<FoodListingRepository>(),
        pickupRepo: ctx.read<PickupPointRepository>(),
      ),
      child: const _ClaimTabScreenBody(),
    );
  }
}

class _ClaimTabScreenBody extends StatelessWidget {
  const _ClaimTabScreenBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClaimTabController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Header ─────────────────────────────────────────────────
            _buildHeader(context),

            // ── Scrollable Body Content ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Notice Toast / Impact micro-banner
                    _buildImpactBanner(controller),
                    const SizedBox(height: 12),

                    // 2. Segmented Control Switcher
                    _buildSegmentedControl(controller),
                    const SizedBox(height: 12),

                    // 3. Status sync & Demo "Simulasikan Kosong"
                    _buildStatusAndSimulateRow(controller),
                    const SizedBox(height: 12),

                    // 4. Interactive Simulation Demo Chips (kShowDemoControls)
                    if (kShowDemoControls) ...[
                      _buildDemoControlsRow(context, controller),
                      const SizedBox(height: 12),
                    ],

                    // 5. Tab Content: "Klaim Saya" vs "Permintaan Masuk"
                    if (controller.selectedSegment == 0)
                      _buildMyClaimsList(context, controller)
                    else
                      _buildIncomingClaimsList(context, controller),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tab Klaim',
            style: AppTextStyles.modalTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ClaimHistoryScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Riwayat',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primaryDeep,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDeep,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Impact Micro-Banner
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildImpactBanner(ClaimTabController controller) {
    final count = controller.mySavedPortions > 0 ? controller.mySavedPortions : 4;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xB2FFE9DB), // rgba(255, 233, 219, 0.7)
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark,
                  blurRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              size: 16,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
                children: [
                  const TextSpan(text: 'Kamu sudah menyelamatkan '),
                  TextSpan(
                    text: '$count porsi',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const TextSpan(text: ' makanan minggu ini!'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.celebration_rounded,
            size: 18,
            color: AppColors.primaryDeep,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Segmented Control Switcher
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSegmentedControl(ClaimTabController controller) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x99EBE1DA), // rgba(235, 225, 218, 0.6)
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: Row(
        children: [
          // Segment 0: Klaim Saya
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setSegment(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: controller.selectedSegment == 0
                      ? AppColors.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  boxShadow: controller.selectedSegment == 0
                      ? const [
                          BoxShadow(
                            color: AppColors.border,
                            blurRadius: 0,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 15,
                      color: controller.selectedSegment == 0
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Klaim Saya',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.button.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: controller.selectedSegment == 0
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Segment 1: Permintaan Masuk (only if kIsDonor)
          if (kIsDonor)
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setSegment(1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: controller.selectedSegment == 1
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                    boxShadow: controller.selectedSegment == 1
                        ? const [
                            BoxShadow(
                              color: AppColors.border,
                              blurRadius: 0,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 15,
                        color: controller.selectedSegment == 1
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Permintaan Masuk',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.button.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: controller.selectedSegment == 1
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (controller.incomingPendingCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.r9999),
                          ),
                          child: Text(
                            '${controller.incomingPendingCount}',
                            style: AppTextStyles.badge.copyWith(
                              fontSize: 10,
                              color: AppColors.surface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Status Sync Row & Simulasikan Kosong
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildStatusAndSimulateRow(ClaimTabController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.tealDeep,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Status sinkron real-time',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.badge.copyWith(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => controller.toggleSimulateEmpty(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: controller.simulateEmpty
                  ? AppColors.primarySoft
                  : AppColors.creamSoft,
              borderRadius: BorderRadius.circular(AppRadius.r9999),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.border,
                  blurRadius: 0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              controller.simulateEmpty ? 'Reset Tampilan' : 'Simulasikan Kosong',
              style: AppTextStyles.badge.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDeep,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Simulation Controls for Prototype Review (kShowDemoControls)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDemoControlsRow(
    BuildContext context,
    ClaimTabController controller,
  ) {
    final chips = <Widget>[];

    if (controller.selectedSegment == 0) {
      // In Klaim Saya: chips for each menunggu claim
      final menungguClaims = controller.myClaims
          .where((c) => c.status == ClaimStatus.menunggu)
          .toList();

      for (final claim in menungguClaims) {
        final listing = controller.getListing(claim.listingId);
        if (listing != null) {
          chips.add(
            ActionChip(
              label: Text('Simulasikan: Terima (#${claim.seq})'),
              backgroundColor: AppColors.tealSoft,
              side: const BorderSide(color: AppColors.teal),
              labelStyle: AppTextStyles.caption.copyWith(
                color: AppColors.tealDeep,
                fontWeight: FontWeight.w700,
              ),
              onPressed: () => controller.simulateAccept(
                context,
                claim.id,
                listing.donorId,
              ),
            ),
          );
          chips.add(
            ActionChip(
              label: Text('Simulasikan: Tolak (#${claim.seq})'),
              backgroundColor: AppColors.dangerSoft,
              side: const BorderSide(color: AppColors.danger),
              labelStyle: AppTextStyles.caption.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
              onPressed: () => controller.simulateReject(
                context,
                claim.id,
                listing.donorId,
              ),
            ),
          );
        }
      }
    } else {
      // In Permintaan Masuk
      chips.add(
        ActionChip(
          label: const Text('+ Klaim masuk (1 porsi)'),
          backgroundColor: AppColors.creamSoft,
          side: const BorderSide(color: AppColors.primary),
          labelStyle: AppTextStyles.caption.copyWith(
            color: AppColors.primaryDeep,
            fontWeight: FontWeight.w700,
          ),
          onPressed: () => controller.simulateIncomingClaim(context, fullStock: false),
        ),
      );
      chips.add(
        ActionChip(
          label: const Text('+ Klaim masuk (stok penuh)'),
          backgroundColor: AppColors.primarySoft,
          side: const BorderSide(color: AppColors.primary),
          labelStyle: AppTextStyles.caption.copyWith(
            color: AppColors.primaryDeep,
            fontWeight: FontWeight.w700,
          ),
          onPressed: () => controller.simulateIncomingClaim(context, fullStock: true),
        ),
      );
    }

    // Always offer "Picu pengingat"
    chips.add(
      ActionChip(
        label: const Text('Picu pengingat'),
        backgroundColor: AppColors.amberSoft,
        side: const BorderSide(color: AppColors.amber),
        labelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.warningText,
          fontWeight: FontWeight.w700,
        ),
        onPressed: () => controller.triggerReminder(context),
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips
            .map((c) => Padding(padding: const EdgeInsets.only(right: 8), child: c))
            .toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 0: Klaim Saya List
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMyClaimsList(BuildContext context, ClaimTabController controller) {
    final claims = controller.myClaims;

    if (claims.isEmpty) {
      return _buildEmptyState(
        title: 'Belum Ada Klaim Aktif',
        subtitle:
            'Kamu belum memiliki klaim yang sedang berjalan. Jelajahi menu surplus makanan untuk mulai berbagi dan menyelamatkan makanan!',
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: claims.length,
      itemBuilder: (ctx, i) {
        final claim = claims[i];
        final listing = controller.getListing(claim.listingId);
        if (listing == null) return const SizedBox.shrink();

        final pickupPoint = controller.getPickupPoint(listing.pickupPointId);
        final queuePos = controller.getQueuePosition(claim.id);

        return ClaimCard(
          claim: claim,
          listing: listing,
          pickupPoint: pickupPoint,
          queuePosition: queuePos,
          now: controller.now,
          onCancel: () => controller.cancelClaim(context, claim.id),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tab 1: Permintaan Masuk List
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildIncomingClaimsList(
    BuildContext context,
    ClaimTabController controller,
  ) {
    final grouped = controller.groupedIncomingClaims;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: Text('Perlu diputuskan (${controller.incomingPendingCount})'),
                selected: controller.incomingFilterIndex == 0,
                selectedColor: AppColors.primarySoft,
                checkmarkColor: AppColors.primary,
                labelStyle: AppTextStyles.chip.copyWith(
                  color: controller.incomingFilterIndex == 0
                      ? AppColors.primaryDeep
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => controller.setIncomingFilter(0),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Sudah diputuskan'),
                selected: controller.incomingFilterIndex == 1,
                selectedColor: AppColors.primarySoft,
                checkmarkColor: AppColors.primary,
                labelStyle: AppTextStyles.chip.copyWith(
                  color: controller.incomingFilterIndex == 1
                      ? AppColors.primaryDeep
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
                onSelected: (_) => controller.setIncomingFilter(1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (grouped.isEmpty)
          _buildEmptyState(
            title: 'Tidak Ada Permintaan',
            subtitle: controller.incomingFilterIndex == 0
                ? 'Belum ada permintaan klaim yang memerlukan keputusan darimu saat ini.'
                : 'Belum ada riwayat permintaan yang telah diputuskan.',
          )
        else
          ...grouped.entries.map((entry) {
            final listingId = entry.key;
            final claimList = entry.value;
            final listing = controller.getListing(listingId);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r16),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.border,
                    blurRadius: 0,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Listing Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          listing?.name ?? 'Donasi Makanan',
                          style: AppTextStyles.heading.copyWith(fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.r9999),
                        ),
                        child: Text(
                          'Sisa ${listing?.quantityRemaining ?? 0} porsi',
                          style: AppTextStyles.badge.copyWith(
                            fontSize: 11,
                            color: AppColors.primaryDeep,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: AppColors.border),

                  // Claim rows
                  ...claimList.map(
                    (c) => IncomingClaimRow(
                      claim: c,
                      queuePosition: controller.getQueuePosition(c.id),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Empty State with Rasi Mascot
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEmptyState({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
            title,
            style: AppTextStyles.heading.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

