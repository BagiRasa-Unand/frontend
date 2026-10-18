import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/claim.dart';

class ClaimStatusBadge extends StatelessWidget {
  const ClaimStatusBadge({
    super.key,
    required this.status,
    this.isHistory = false,
  });

  final ClaimStatus status;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    if (isHistory) {
      return _buildHistoryBadge();
    }

    switch (status) {
      case ClaimStatus.diterima:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
            boxShadow: const [
              BoxShadow(
                color: AppColors.tealDark,
                blurRadius: 0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Diterima (Siap Diambil)',
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.surface,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      case ClaimStatus.menunggu:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.amber,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                size: 11,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                'Menunggu Persetujuan',
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      case ClaimStatus.antre:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.slate,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.format_list_bulleted_rounded,
                size: 11,
                color: AppColors.surface,
              ),
              const SizedBox(width: 4),
              Text(
                'Antre',
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.surface,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      case ClaimStatus.ditolak:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.close_rounded,
                size: 11,
                color: AppColors.surface,
              ),
              const SizedBox(width: 4),
              Text(
                'Ditolak',
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.surface,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      case ClaimStatus.dibatalkan:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.textSecondary,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.block_rounded,
                size: 11,
                color: AppColors.surface,
              ),
              const SizedBox(width: 4),
              Text(
                'Dibatalkan',
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.surface,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildHistoryBadge() {
    switch (status) {
      case ClaimStatus.diterima:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF7CF6ED),
            borderRadius: BorderRadius.circular(AppRadius.r9999),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0B817B),
                blurRadius: 0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 11,
                color: Color(0xFF00504C),
              ),
              const SizedBox(width: 4),
              Text(
                'Diterima',
                style: AppTextStyles.badge.copyWith(
                  color: const Color(0xFF00504C),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      case ClaimStatus.ditolak:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFDAD6),
            borderRadius: BorderRadius.circular(AppRadius.r9999),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFB93338),
                blurRadius: 0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cancel_outlined,
                size: 11,
                color: Color(0xFF93000A),
              ),
              const SizedBox(width: 4),
              Text(
                'Ditolak',
                style: AppTextStyles.badge.copyWith(
                  color: const Color(0xFF93000A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      case ClaimStatus.dibatalkan:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFEBE1DA),
            borderRadius: BorderRadius.circular(AppRadius.r9999),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF8A94A6),
                blurRadius: 0,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.remove_circle_outline_rounded,
                size: 11,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                'Dibatalkan',
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      case ClaimStatus.menunggu:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.amber,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.hourglass_top_rounded,
                size: 11,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                'Menunggu',
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      case ClaimStatus.antre:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.slate,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.format_list_bulleted_rounded,
                size: 11,
                color: AppColors.surface,
              ),
              const SizedBox(width: 4),
              Text(
                'Antre',
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.surface,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
    }
  }
}

