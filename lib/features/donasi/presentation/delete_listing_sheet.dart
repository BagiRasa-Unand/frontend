import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/chunky_button.dart';
import '../data/food_listing.dart';
import '../data/food_listing_repository.dart';

Future<void> showDeleteListingSheet(
  BuildContext context,
  FoodListing listing,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final repository = context.read<FoodListingRepository>();
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlay,
    builder: (_) => _DeleteListingSheet(listing: listing),
  );

  if (confirmed != true || !context.mounted) return;

  final deleted = repository.delete(listing.id);
  if (!deleted) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Listing tidak dapat dihapus')),
    );
    return;
  }

  Navigator.of(context).maybePop();
  messenger.showSnackBar(
    const SnackBar(content: Text('Listing dihapus')),
  );
}

class _DeleteListingSheet extends StatelessWidget {
  const _DeleteListingSheet({required this.listing});

  final FoodListing listing;

  bool get isBlocked => listing.claimedQuantity > 0;

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
                    const _SheetDragHandle(),
                    const SizedBox(height: 12),
                    const _MascotWorried(),
                    const SizedBox(height: 8),
                    Text(
                      isBlocked
                          ? 'Listing tidak dapat dihapus'
                          : 'Hapus listing ini?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.modalTitle,
                    ),
                    const SizedBox(height: 8),
                    _ListingPill(listing: listing),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        isBlocked
                            ? 'Listing ini sudah memiliki porsi yang diklaim mahasiswa dan tidak dapat dihapus dari riwayat donasi.'
                            : 'Listing yang dihapus tidak akan dapat dilihat atau diklaim kembali oleh mahasiswa lain di kampus.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 23 / 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _WarningCalloutCard(isBlocked: isBlocked),
                    const SizedBox(height: 16),
                    _ActionButtons(isBlocked: isBlocked),
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
        borderRadius: BorderRadius.circular(AppRadius.r9999),
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
            errorBuilder: (context, error, stackTrace) => Container(
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
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingPill extends StatelessWidget {
  const _ListingPill({required this.listing});

  final FoodListing listing;

  @override
  Widget build(BuildContext context) {
    final label = listing.claimedQuantity > 0
        ? '${listing.name} (${listing.claimedQuantity} ${listing.unit} sudah diklaim)'
        : '${listing.name} (${listing.quantityTotal} ${listing.unit})';
    return Container(
      constraints: const BoxConstraints(maxWidth: 318),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
        boxShadow: const [
          BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restaurant_outlined,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.highlightPill,
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningCalloutCard extends StatelessWidget {
  const _WarningCalloutCard({required this.isBlocked});

  final bool isBlocked;

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
              isBlocked
                  ? 'Listing dengan porsi yang sudah diklaim tidak dapat dihapus. Data klaim tetap tersimpan di riwayat mahasiswa.'
                  : 'Pastikan tidak ada mahasiswa yang sedang dalam perjalanan menuju kantin sebelum menghapus.',
              style: AppTextStyles.warningCallout,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.isBlocked});

  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    if (isBlocked) {
      return ChunkyButton(
        label: 'MENGERTI',
        variant: ChunkyButtonVariant.neutral,
        edge: 3,
        textColor: AppColors.textSecondary,
        icon: const Icon(Icons.check_rounded,
            size: 18, color: AppColors.textSecondary),
        onTap: () => Navigator.of(context).pop(false),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ChunkyButton(
          label: 'YA, HAPUS LISTING',
          variant: ChunkyButtonVariant.danger,
          edge: 4,
          icon: const Icon(Icons.delete_forever_rounded,
              size: 18, color: AppColors.surface),
          onTap: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: 8),
        ChunkyButton(
          label: 'BATAL, TETAP SIMPAN',
          variant: ChunkyButtonVariant.neutral,
          edge: 3,
          textColor: AppColors.textSecondary,
          icon: const Icon(Icons.close_rounded,
              size: 18, color: AppColors.textSecondary),
          onTap: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}
