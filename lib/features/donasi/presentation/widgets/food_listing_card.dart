import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/food_listing.dart';
import 'status_badge.dart';

class FoodListingCard extends StatelessWidget {
  const FoodListingCard({
    super.key,
    required this.listing,
    required this.pickupPointName,
    required this.now,
    required this.onTap,
  });

  final FoodListing listing;
  final String pickupPointName;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = listing.statusAt(now);
    final muted = status == ListingStatus.habisDiklaim ||
        status == ListingStatus.kadaluarsa;
    final accent = switch (status) {
      ListingStatus.tersedia => AppColors.tealDeep,
      ListingStatus.segeraHabis => AppColors.amber,
      ListingStatus.habisDiklaim => AppColors.slate,
      ListingStatus.kadaluarsa => AppColors.danger,
    };

    return Opacity(
      opacity: muted ? 0.72 : 1,
      child: Card(
        margin: EdgeInsets.zero,
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r20),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.r20),
            boxShadow: [
              BoxShadow(
                color: status == ListingStatus.kadaluarsa
                    ? AppColors.dangerSoft
                    : AppColors.border,
                blurRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.r16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ListingPhoto(path: listing.photoPath, status: status),
                const SizedBox(width: 12),
                Expanded(
                  child: _ListingDetails(
                    listing: listing,
                    pickupPointName: pickupPointName,
                    status: status,
                    accent: accent,
                    now: now,
                    onTap: onTap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListingPhoto extends StatelessWidget {
  const _ListingPhoto({required this.path, required this.status});

  final String? path;
  final ListingStatus status;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r16),
      child: SizedBox(
        width: 112,
        height: 112,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (path == null)
              Container(
                color: AppColors.surfaceWarm,
                child: Icon(
                  Icons.restaurant_rounded,
                  size: 38,
                  color: status == ListingStatus.kadaluarsa
                      ? AppColors.danger
                      : AppColors.primary,
                ),
              )
            else
              Image.asset(path!, fit: BoxFit.cover),
            Positioned(
              left: 8,
              top: 8,
              child: StatusBadge(status: status, compact: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingDetails extends StatelessWidget {
  const _ListingDetails({
    required this.listing,
    required this.pickupPointName,
    required this.status,
    required this.accent,
    required this.now,
    required this.onTap,
  });

  final FoodListing listing;
  final String pickupPointName;
  final ListingStatus status;
  final Color accent;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyles.cardTitle.copyWith(
      fontSize: 18,
      height: 24 / 18,
      color: status == ListingStatus.habisDiklaim
          ? AppColors.slate
          : status == ListingStatus.kadaluarsa
              ? AppColors.brownMid
              : AppColors.textPrimary,
      decoration: status == ListingStatus.habisDiklaim
          ? TextDecoration.lineThrough
          : null,
    );
    final progress = listing.quantityTotal == 0
        ? 0.0
        : (listing.quantityRemaining / listing.quantityTotal)
            .clamp(0.0, 1.0)
            .toDouble();
    final isClosed = status == ListingStatus.habisDiklaim ||
        status == ListingStatus.kadaluarsa;

    return SizedBox(
      height: 112,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(listing.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: titleStyle),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.storefront_outlined, size: 14, color: accent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(pickupPointName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${listing.quantityRemaining} dari ${listing.quantityTotal} ${listing.unit}',
                style: AppTextStyles.badge.copyWith(color: accent),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule_outlined, size: 13, color: accent),
                  const SizedBox(width: 2),
                  Text(_timeLeftText(listing.timeLeftAt(now)),
                      style: AppTextStyles.badge.copyWith(color: accent)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r9999),
            child: SizedBox(
              height: 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                      color: status == ListingStatus.kadaluarsa
                          ? AppColors.dangerSoft
                          : AppColors.surfaceWarm),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: isClosed && progress == 0 ? 1 : progress,
                    child: Container(color: accent),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isClosed
                      ? status == ListingStatus.kadaluarsa
                          ? 'Batas pengambilan usai'
                          : 'Selesai diambil'
                      : 'Rp0 (Donasi Canteen)',
                  style: AppTextStyles.badge.copyWith(
                      color: isClosed
                          ? AppColors.textSecondary
                          : AppColors.primaryDeep),
                ),
              ),
              _ActionButton(
                label: isClosed ? 'Tutup' : 'Klaim',
                enabled: !isClosed,
                onTap: onTap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeLeftText(Duration duration) {
    if (duration == Duration.zero) return 'Waktu habis';
    if (duration.inHours > 0) {
      return 'Sisa ${duration.inHours}j ${duration.inMinutes % 60}m';
    }
    return 'Sisa ${duration.inMinutes}m';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          boxShadow: enabled
              ? const [
                  BoxShadow(
                    color: AppColors.primaryDark,
                    blurRadius: 0,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: AppTextStyles.badge.copyWith(
                    color: enabled ? AppColors.surface : AppColors.slate)),
            if (enabled) ...[
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded,
                  size: 14, color: AppColors.surface),
            ],
          ],
        ),
      ),
    );
  }
}
