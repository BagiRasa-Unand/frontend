import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/pickup_point.dart';
import '../data/pickup_point_repository.dart';
import '../logic/pickup_point_list_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/chunky_button.dart';

/// Shows "Konfirmasi Hapus Titik" bottom sheet and deletes [point] if confirmed.
Future<void> showDeletePickupPointSheet(
  BuildContext context,
  PickupPoint point,
) async {
  final messenger = ScaffoldMessenger.of(context);
  PickupPointListNotifier? notifier;
  try {
    notifier = context.read<PickupPointListNotifier>();
  } catch (_) {}
  PickupPointRepository? repo;
  try {
    repo = context.read<PickupPointRepository>();
  } catch (_) {}

  final bool? confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlay, // rgba(31, 27, 23, 0.5)
    builder: (_) => _DeletePickupPointSheet(point: point),
  );

  if (confirmed == true) {
    if (notifier != null) {
      notifier.delete(point.id);
    } else {
      repo?.delete(point.id);
    }
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Titik pengambilan dihapus'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _DeletePickupPointSheet extends StatelessWidget {
  const _DeletePickupPointSheet({required this.point});

  final PickupPoint point;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 448),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.r28),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.sheetShadow,
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      // ── Top Tactile Sheet Handle ─────────────────────────
                      const _SheetDragHandle(),
                      const SizedBox(height: 12),

                      // ── Mascot Rasi Worried ──────────────────────────────
                      const _MascotWorried(),
                      const SizedBox(height: 8),

                      // ── Modal Title ──────────────────────────────────────
                      Text(
                        'Hapus titik pengambilan?',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.modalTitle,
                      ),
                      const SizedBox(height: 8),

                      // ── Target Location Highlight Pill ───────────────────
                      _LocationPill(name: point.name),
                      const SizedBox(height: 8),

                      // ── Explanatory Warning Microcopy ────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Titik ini tidak akan bisa menerima donasi atau klaim makanan lagi. Seluruh data riwayat porsi terselamatkan di titik ini akan tetap tersimpan di arsip akunmu.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            height: 23 / 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Warning Callout Card ─────────────────────────────
                      const _WarningCalloutCard(),
                      const SizedBox(height: 16),

                      // ── Action Buttons Stack ─────────────────────────────
                      const _ActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }
}

class _SheetDragHandle extends StatelessWidget {
  const _SheetDragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(9999),
      ),
    );
  }
}

class _MascotWorried extends StatelessWidget {
  const _MascotWorried();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.ambientGlow,
            ),
          ),
          Image.asset(
            'assets/images/rasi_worried.png',
            width: 112,
            height: 112,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 112,
                height: 112,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySoft,
                ),
                child: const Icon(
                  Icons.sentiment_very_dissatisfied_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.storefront_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              style: AppTextStyles.highlightPill,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningCalloutCard extends StatelessWidget {
  const _WarningCalloutCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.warningBorder,
            blurRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: AppColors.warningText,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pastikan tidak ada mahasiswa yang sedang dalam perjalanan menuju titik ini!',
              style: AppTextStyles.warningCallout,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChunkyButton(
          label: 'YA, HAPUS TITIK',
          variant: ChunkyButtonVariant.danger,
          edge: 4,
          icon: const Icon(
            Icons.delete_forever_rounded,
            size: 18,
            color: AppColors.surface,
          ),
          onTap: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: 8),
        ChunkyButton(
          label: 'BATAL, TETAP SIMPAN',
          variant: ChunkyButtonVariant.neutral,
          edge: 3,
          textColor: AppColors.textSecondary,
          icon: const Icon(
            Icons.close_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          onTap: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
