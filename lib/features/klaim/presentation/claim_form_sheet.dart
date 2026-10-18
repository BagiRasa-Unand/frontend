import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../donasi/data/food_listing.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../data/claim.dart';
import '../data/claim_repository.dart';
import '../logic/claim_form_controller.dart';
import 'claim_detail_screen.dart';

/// Menampilkan bottom sheet "Form Klaim" untuk sebuah [FoodListing].
Future<void> showClaimSheet(BuildContext context, FoodListing listing) {
  final claimRepo = context.read<ClaimRepository>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x661F1B17),
    builder: (sheetContext) => ChangeNotifierProvider(
      create: (_) => ClaimFormController(
        listing: listing,
        claimRepository: claimRepo,
      ),
      child: ClaimFormSheet(listing: listing),
    ),
  );
}

/// Widget bottom sheet Form Klaim sesuai desain Figma BagiRasa.
class ClaimFormSheet extends StatelessWidget {
  const ClaimFormSheet({super.key, required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClaimFormController>();
    final pickupPointRepo = context.read<PickupPointRepository>();
    final pickupPoint = pickupPointRepo.getById(listing.pickupPointId);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadius.r28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x2E1F1B17),
                  blurRadius: 30,
                  offset: Offset(0, -8),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _DragHandle(),
                  if (kShowDemoControls) ...[
                    _VariantSwitcherBar(controller: controller),
                    const SizedBox(height: 12),
                  ],
                  const _ModalHeader(),
                  const SizedBox(height: 16),
                  _MiniListingCard(
                    listing: listing,
                    pickupPointName: pickupPoint?.name ?? 'Lokasi Pengambilan',
                  ),
                  const SizedBox(height: 16),
                  _QuantityStepperSection(controller: controller),
                  const SizedBox(height: 16),
                  _WarningCalloutCard(controller: controller),
                  const SizedBox(height: 16),
                  const _MascotTipPill(),
                  const SizedBox(height: 20),
                  _ActionButtons(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Handle seret di bagian atas bottom sheet.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          width: 40,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.dragHandle,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
          ),
        ),
      ),
    );
  }
}

/// Switcher demo interaktif untuk preview ketiga varian.
class _VariantSwitcherBar extends StatelessWidget {
  const _VariantSwitcherBar({required this.controller});

  final ClaimFormController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.pillNeutral,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildVariantPill(
            label: 'Varian A (Stok Ada)',
            variant: ClaimFormVariant.normal,
          ),
          _buildVariantPill(
            label: 'Varian B (Antrean)',
            variant: ClaimFormVariant.queue,
          ),
          _buildVariantPill(
            label: 'Varian C (Terkunci)',
            variant: ClaimFormVariant.blocked,
          ),
        ],
      ),
    );
  }

  Widget _buildVariantPill({
    required String label,
    required ClaimFormVariant variant,
  }) {
    final isSelected = controller.variant == variant;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setPreviewVariant(variant),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.badge.copyWith(
              fontSize: 10,
              color: isSelected ? AppColors.surface : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Header dialog Form Klaim dengan judul dan badge "BagiRasa Rescue".
class _ModalHeader extends StatelessWidget {
  const _ModalHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lunch_dining_rounded,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Klaim Makanan',
            style: AppTextStyles.modalTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.rescueBadgeBg,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.eco_rounded,
                size: 11,
                color: AppColors.tealDeep,
              ),
              const SizedBox(width: 4),
              Text(
                'BagiRasa Rescue',
                style: AppTextStyles.badge.copyWith(
                  fontSize: 11,
                  color: AppColors.tealDeep,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kartu ringkasan makanan yang akan diklaim.
class _MiniListingCard extends StatelessWidget {
  const _MiniListingCard({
    required this.listing,
    required this.pickupPointName,
  });

  final FoodListing listing;
  final String pickupPointName;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final remainingTime = listing.timeLeftAt(now);
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes % 60;
    final timeText = hours > 0
        ? 'Sisa ${hours}j ${minutes}m'
        : 'Sisa $minutes menit';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto makanan dengan rating badge overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildPhoto(listing.photoPath),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppRadius.r9999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: AppColors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '4.9',
                            style: AppTextStyles.badge.copyWith(
                              fontSize: 10,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Informasi makanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.heading.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        pickupPointName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        timeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cyanBadge,
                        borderRadius: BorderRadius.circular(AppRadius.r9999),
                      ),
                      child: Text(
                        'Sisa stok ${listing.quantityRemaining} ${listing.unit}',
                        style: AppTextStyles.badge.copyWith(
                          fontSize: 10,
                          color: AppColors.cyanBadgeText,
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
    );
  }

  Widget _buildPhoto(String? path) {
    if (path != null && path.isNotEmpty) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Container(
      color: AppColors.surfaceWarm,
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 32,
          color: AppColors.slate,
        ),
      ),
    );
  }
}

/// Bagian pengatur jumlah porsi (stepper) dengan dampak jejak karbon.
class _QuantityStepperSection extends StatelessWidget {
  const _QuantityStepperSection({required this.controller});

  final ClaimFormController controller;

  @override
  Widget build(BuildContext context) {
    final maxPortionLabel = controller.listing.quantityRemaining >= 2
        ? 'Maks 2 porsi'
        : 'Maks ${controller.listing.quantityRemaining} porsi';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Baris judul stepper & badge batas
          Row(
            children: [
              Expanded(
                child: Text(
                  'Porsi yang ingin diselamatkan',
                  style: AppTextStyles.heading.copyWith(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.r9999),
                ),
                child: Text(
                  maxPortionLabel,
                  style: AppTextStyles.badge.copyWith(
                    fontSize: 11,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Baris kontrol porsi & estimasi hemat karbon
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Porsi santap mahasiswa',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.eco_rounded,
                          size: 14,
                          color: AppColors.tealDeep,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Hemat ${controller.carbonSavedKg.toStringAsFixed(1)} kg Jejak Karbon',
                            style: AppTextStyles.badge.copyWith(
                              fontSize: 12,
                              color: AppColors.tealDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Tombol kontrol stepper 3D
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepperButton(
                    icon: Icons.remove_rounded,
                    enabled: controller.canDecrement,
                    onTap: controller.decrement,
                  ),
                  Container(
                    width: 52,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${controller.quantity}',
                          style: AppTextStyles.stepperNumber,
                        ),
                        Text(
                          'porsi',
                          style: AppTextStyles.badge.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StepperButton(
                    icon: Icons.add_rounded,
                    enabled: controller.canIncrement,
                    onTap: controller.increment,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Maksimal 2 porsi agar santapan terbagi merata untuk mahasiswa lain.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol stepper 3D chunky.
class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.35,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.border,
                blurRadius: 0,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu callout peringatan status klaim (Varian A, B, atau C).
class _WarningCalloutCard extends StatelessWidget {
  const _WarningCalloutCard({required this.controller});

  final ClaimFormController controller;

  @override
  Widget build(BuildContext context) {
    final variant = controller.variant;

    switch (variant) {
      case ClaimFormVariant.normal:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.amberSoftBg,
            borderRadius: BorderRadius.circular(AppRadius.r16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.amberBorder,
                blurRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_active_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Menunggu Persetujuan Stan',
                      style: AppTextStyles.heading.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Klaimmu akan dikirim ke pendonor untuk disetujui. Harap bersiap mengambil di lokasi setelah diterima.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.brownMid,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case ClaimFormVariant.queue:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE5F4FF),
            borderRadius: BorderRadius.circular(AppRadius.r16),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFB3E5FC),
                blurRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0095FF),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: AppColors.surface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Antrean ke-${controller.queuePositionForNewClaim}',
                      style: AppTextStyles.heading.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stok saat ini sedang diproses oleh pemesan lain. Kamu akan otomatis dipromosikan jika ada stok yang tersedia.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.brownMid,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case ClaimFormVariant.blocked:
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(AppRadius.r16),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFFFCDD2),
                blurRadius: 0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_rounded,
                    size: 18,
                    color: AppColors.surface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Klaim Aktif Ditemukan',
                      style: AppTextStyles.heading.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kamu sudah memiliki klaim aktif untuk makanan ini. Pantau status klaimmu di tab Klaim.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.brownMid,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}

/// Pill pesan ramah maskot Rasi.
class _MascotTipPill extends StatelessWidget {
  const _MascotTipPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.r12),
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
            child: const Center(
              child: Icon(
                Icons.sentiment_very_satisfied_rounded,
                size: 20,
                color: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tips Rasi: Membawa wadah makan & tumbler sendiri bikin kampus lebih hijau! 🌱',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryDeep,
                fontSize: 12,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol aksi utama ("AJUKAN KLAIM" / "MENGERTI") dan tombol "BATAL".
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.controller});

  final ClaimFormController controller;

  Future<void> _handleAjukanKlaim(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final claimRepo = context.read<ClaimRepository>();

    final result = await controller.submitClaim(
      claimantId: kCurrentUserId,
      claimantName: kCurrentUserName,
    );

    if (!context.mounted) return;

    if (!result.ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(result.error ?? 'Gagal mengajukan klaim')),
      );
      return;
    }

    // Sukses: tutup sheet terlebih dahulu
    navigator.pop();

    final claim = result.claim!;
    final isQueued = claim.status == ClaimStatus.antre;
    final queuePos = claimRepo.queuePosition(claim.id);
    final snackBarMessage = isQueued
        ? 'Kamu masuk antrean ke-${queuePos ?? 1}'
        : 'Klaim diajukan';

    messenger.showSnackBar(
      SnackBar(content: Text(snackBarMessage)),
    );

    navigator.push(
      MaterialPageRoute(
        builder: (_) => ClaimDetailScreen(claimId: claim.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBlocked = controller.variant == ClaimFormVariant.blocked;

    if (isBlocked) {
      return ChunkyButton(
        label: 'MENGERTI',
        height: 48,
        onTap: () => Navigator.of(context).pop(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChunkyButton(
          label: 'AJUKAN KLAIM',
          height: 48,
          icon: const Icon(
            Icons.volunteer_activism_outlined,
            size: 18,
            color: AppColors.surface,
          ),
          onTap: () => _handleAjukanKlaim(context),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            height: 48,
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
            child: Center(
              child: Text(
                'BATAL',
                style: AppTextStyles.heading.copyWith(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
