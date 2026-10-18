import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/chunky_button.dart';

Future<ImageSource?> showPhotoSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlay,
    builder: (_) => const _PhotoSourceSheet(),
  );
}

class _PhotoSourceSheet extends StatelessWidget {
  const _PhotoSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r28)),
          boxShadow: [
            BoxShadow(
              color: AppColors.sheetShadow,
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Tambah foto makanan', style: AppTextStyles.modalTitle),
                  ),
                  Semantics(
                    button: true,
                    label: 'Tutup pilih sumber foto',
                    child: IconButton(
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primarySoft,
                        foregroundColor: AppColors.primaryDark,
                        minimumSize: const Size(48, 48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Pilih foto yang jelas dan menggugah selera untuk menarik minat penyelamat makanan.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _PhotoOptionCard(
              source: ImageSource.camera,
              icon: Icons.camera_alt_rounded,
              iconColor: AppColors.primary,
              iconBackground: AppColors.primarySoft,
              title: 'Ambil dengan kamera',
              subtitle: 'Buka kamera langsung untuk foto',
              badge: 'Cepat',
              badgeIcon: Icons.bolt_rounded,
              badgeColor: AppColors.bannerShadow,
              badgeTextColor: AppColors.brownDeep,
            ),
            const SizedBox(height: 12),
            _PhotoOptionCard(
              source: ImageSource.gallery,
              icon: Icons.photo_library_rounded,
              iconColor: AppColors.tealDeep,
              iconBackground: AppColors.teal,
              title: 'Pilih dari galeri',
              subtitle: 'Upload foto dari album ponsel',
              badge: 'Album',
              badgeIcon: null,
              badgeColor: AppColors.surfaceWarm,
              badgeTextColor: AppColors.brownMid,
            ),
            const SizedBox(height: 16),
            const _RasiTipCard(),
            const SizedBox(height: 16),
            ChunkyButton(
              label: 'BATAL',
              onTap: () => Navigator.of(context).pop(),
              variant: ChunkyButtonVariant.neutral,
              edge: 4,
              height: 50,
              borderRadius: AppRadius.r16,
              textColor: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(
          width: 40,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.handle,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
          ),
        ),
      ),
    );
  }
}

class _PhotoOptionCard extends StatelessWidget {
  const _PhotoOptionCard({
    required this.source,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeIcon,
    required this.badgeColor,
    required this.badgeTextColor,
  });

  final ImageSource source;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String badge;
  final IconData? badgeIcon;
  final Color badgeColor;
  final Color badgeTextColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        child: InkWell(
          onTap: () => Navigator.of(context).pop(source),
          borderRadius: BorderRadius.circular(AppRadius.r20),
          splashColor: iconBackground.withValues(alpha: 0.35),
          highlightColor: iconBackground.withValues(alpha: 0.18),
          child: Container(
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.r20),
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
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(AppRadius.r16),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.35),
                        blurRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 24, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600)),
                      Text(subtitle, maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(AppRadius.r9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badgeIcon != null) ...[
                        Icon(badgeIcon, size: 13, color: badgeTextColor),
                        const SizedBox(width: 2),
                      ],
                      Text(badge, style: AppTextStyles.badge.copyWith(
                          color: badgeTextColor)),
                    ],
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

class _RasiTipCard extends StatelessWidget {
  const _RasiTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: const [
          BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.reward.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: AppColors.amber,
                        blurRadius: 0, offset: Offset(0, 2)),
                  ],
                ),
                child: Image.asset('assets/images/rasi_worried.png'),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppColors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      size: 9, color: AppColors.brownDeep),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tips dari Rasi', style: AppTextStyles.badge.copyWith(
                    color: AppColors.brownMid)),
                const SizedBox(height: 2),
                Text(
                  'Pastikan pencahayaan cukup terang dan porsi makanan terlihat jelas agar cepat diselamatkan sahabat kampus!',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
