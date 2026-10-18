import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../logic/map_controller.dart';

/// Floating top search card dan horizontally scrollable filter chips.
class MapSearchFilterBar extends StatelessWidget {
  const MapSearchFilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  final MapFilterType activeFilter;
  final ValueChanged<MapFilterType> onFilterChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Search Box Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r16),
              border: Border.all(color: AppColors.border, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.border,
                  blurRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari lokasi kantin atau makanan...',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.slate,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO(stub): advanced filter dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur ini belum tersedia'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: AppColors.brownMid,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 2. Horizontally Scrollable Filter Chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _FilterChip(
                label: 'Semua',
                icon: Icons.grid_view_rounded,
                selected: activeFilter == MapFilterType.semua,
                onTap: () => onFilterChanged(MapFilterType.semua),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Terdekat',
                icon: Icons.navigation_rounded,
                iconColor: AppColors.tealDeep,
                selected: activeFilter == MapFilterType.terdekat,
                onTap: () => onFilterChanged(MapFilterType.terdekat),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Segera Habis',
                dotColor: AppColors.amber,
                selected: activeFilter == MapFilterType.segeraHabis,
                onTap: () => onFilterChanged(MapFilterType.segeraHabis),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Makanan Berat',
                icon: Icons.lunch_dining_rounded,
                iconColor: AppColors.primary,
                selected: activeFilter == MapFilterType.makananBerat,
                onTap: () => onFilterChanged(MapFilterType.makananBerat),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'Snack',
                icon: Icons.bakery_dining_rounded,
                iconColor: AppColors.amber,
                selected: activeFilter == MapFilterType.snack,
                onTap: () => onFilterChanged(MapFilterType.snack),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.iconColor,
    this.dotColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? iconColor;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? AppColors.primary : AppColors.surface;
    final shadowColor = selected ? AppColors.primaryDark : AppColors.border;
    final textColor = selected ? AppColors.surface : AppColors.textPrimary;
    final effectiveIconColor = selected ? AppColors.surface : (iconColor ?? AppColors.textPrimary);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.r9999),
          border: selected ? null : Border.all(color: AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selected ? AppColors.surface : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: effectiveIconColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.chip.copyWith(
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
