import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable Metric Card untuk menampilkan statistik ringkas.
class MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String valueText;
  final String labelText;

  const MetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.valueText,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.paddingCardHorizontal),
        decoration: BoxDecoration(
          color: AppColors.cardBgWarm,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(
            color: const Color.fromRGBO(0, 0, 0, 0.03),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon Circle Overlay
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.gapMd),
            
            // Text values
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    valueText,
                    style: AppTextStyles.metricValue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    labelText,
                    style: AppTextStyles.metricLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
