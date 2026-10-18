import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Marker lokasi GPS pengguna saat ini (Module C).
class MapUserLocationMarker extends StatelessWidget {
  const MapUserLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Concentric Halos & Indigo Dot
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Halo 1
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.gpsHaloOuter,
                  shape: BoxShape.circle,
                ),
              ),

              // Outer Halo 2
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.gpsHaloInner,
                  shape: BoxShape.circle,
                ),
              ),

              // Directional Pointer Arrow (Subtle beam pointing up)
              Positioned(
                top: 8,
                child: CustomPaint(
                  size: const Size(10, 8),
                  painter: _DirectionBeamPainter(),
                ),
              ),

              // Solid Dot Core with White Ring
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.gpsIndigo,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.indigoDark, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.white,
                      spreadRadius: 3,
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // User Label Pill: "LOKASI KAMU"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(AppRadius.r9999),
            border: Border.all(
              color: AppColors.indigo.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 2,
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
                  color: AppColors.gpsIndigo,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'LOKASI KAMU',
                style: AppTextStyles.pinBadge.copyWith(
                  color: AppColors.gpsIndigo,
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DirectionBeamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gpsIndigo
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
