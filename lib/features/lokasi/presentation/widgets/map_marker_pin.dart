import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/map_listing.dart';

/// Pin marker tactile chunky untuk titik pengambilan makanan pada peta.
class MapMarkerPin extends StatelessWidget {
  const MapMarkerPin({
    super.key,
    required this.title,
    required this.portionCount,
    required this.status,
    required this.onTap,
    this.isSelected = false,
  });

  final String title;
  final int portionCount;
  final MapListingStatus status;
  final VoidCallback onTap;
  final bool isSelected;

  bool get _isUrgent => status == MapListingStatus.segeraHabis;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Top Badge Pill
          _buildBadgePill(),
          const SizedBox(height: 4),

          // 2. Chunky Tactile Marker Body with Pointer Triangle
          _buildMarkerBody(),
          const SizedBox(height: 4),

          // 3. Bottom Label Pill
          _buildLabelPill(),
        ],
      ),
    );
  }

  Widget _buildBadgePill() {
    if (_isUrgent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.amber,
          borderRadius: BorderRadius.circular(AppRadius.r9999),
          boxShadow: const [
            BoxShadow(
              color: AppColors.amberDark,
              blurRadius: 0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_outlined,
              size: 11,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              'TERSISA $portionCount',
              style: AppTextStyles.pinBadge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
        border: Border.all(color: AppColors.border, width: 1.5),
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
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.tealDeep,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$portionCount PORSI',
            style: AppTextStyles.pinBadge.copyWith(
              color: AppColors.tealDeep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerBody() {
    final bgColor = _isUrgent ? AppColors.amber : AppColors.tealDeep;
    final shadowColor = _isUrgent ? AppColors.amberDark : AppColors.tealDark;
    final iconColor = _isUrgent ? AppColors.textPrimary : AppColors.surface;
    final iconData = _isUrgent
        ? Icons.timer_rounded
        : (title.toLowerCase().contains('rektorat')
            ? Icons.bakery_dining_rounded
            : Icons.restaurant_rounded);

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Pointer triangle at bottom
          Positioned(
            bottom: -3,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: const Border(
                    bottom: BorderSide(color: Colors.white, width: 2),
                    right: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          ),

          // Main 44x44 Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.r16),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                iconData,
                color: iconColor,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.r6),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Nunito Sans',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          height: 14 / 11,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
