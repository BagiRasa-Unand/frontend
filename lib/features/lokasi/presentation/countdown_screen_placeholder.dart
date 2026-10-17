import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';

// TODO(next-task): Replace this placeholder with the full Countdown Screen implementation.
class CountdownScreenPlaceholder extends StatelessWidget {
  const CountdownScreenPlaceholder({
    super.key,
    required this.pickupDeadline,
    required this.listingName,
    this.pickupPointName = '',
  });

  final DateTime pickupDeadline;
  final String listingName;
  final String pickupPointName;

  @override
  Widget build(BuildContext context) {
    final formattedTime =
        '${pickupDeadline.hour.toString().padLeft(2, '0')}:${pickupDeadline.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Hitung Mundur Pengambilan',
          style: AppTextStyles.heading,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  listingName,
                  style: AppTextStyles.cardTitle,
                  textAlign: TextAlign.center,
                ),
                if (pickupPointName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    pickupPointName,
                    style: AppTextStyles.cardSubtitle,
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.r9999),
                  ),
                  child: Text(
                    'Batas Waktu: $formattedTime WIB',
                    style: AppTextStyles.badge.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '// TODO(next-task): Layar hitung mundur lengkap akan diimplementasikan pada tugas berikutnya.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
