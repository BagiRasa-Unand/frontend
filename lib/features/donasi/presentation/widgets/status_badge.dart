import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/food_listing.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.compact = false});

  final ListingStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      ListingStatus.tersedia => (
          label: 'Tersedia',
          color: AppColors.tealDeep,
          background: AppColors.tealSoft,
          icon: Icons.check_circle_outline,
        ),
      ListingStatus.segeraHabis => (
          label: 'Segera Habis',
          color: AppColors.amberDark,
          background: AppColors.amberSoft,
          icon: Icons.timer_outlined,
        ),
      ListingStatus.habisDiklaim => (
          label: 'Habis Diklaim',
          color: AppColors.textSecondary,
          background: AppColors.surfaceWarm,
          icon: Icons.done_all_rounded,
        ),
      ListingStatus.kadaluarsa => (
          label: 'Kadaluarsa',
          color: AppColors.textSecondary,
          background: AppColors.surfaceWarm,
          icon: Icons.event_busy_outlined,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            Icon(config.icon, size: compact ? 11 : 13, color: config.color),
          const SizedBox(width: 4),
            Text(config.label,
              style: AppTextStyles.badge.copyWith(
                color: config.color, fontSize: compact ? 10 : 11)),
        ],
      ),
    );
  }
}