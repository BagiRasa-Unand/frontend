import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../logic/countdown_controller.dart';

/// Top Urgency Countdown Banner displayed when an active claim or deadline exists.
class RouteCountdownBanner extends StatelessWidget {
  const RouteCountdownBanner({
    super.key,
    required this.controller,
  });

  final CountdownController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final progress = controller.progress;
        final formatted = controller.formattedTimer;

        // Choose bar color based on level
        final barColor = switch (controller.level) {
          CountdownLevel.normal => AppColors.teal,
          CountdownLevel.warning => AppColors.amber,
          CountdownLevel.critical => AppColors.danger,
          CountdownLevel.expired => AppColors.slate,
        };

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 6,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Row: Title & Timer Badge ───────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_rounded,
                        color: AppColors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Sisa Waktu',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppRadius.r9999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      formatted,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Animated Urgency Progress Bar (Thick: 12px) ────────────────
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(AppRadius.r9999),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(AppRadius.r9999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // ── Bottom Subtitle / Microcopy ────────────────────────────────
              Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.primaryDeep,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Ambil tepat waktu agar makanan tetap hangat & higienis.',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        height: 14 / 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

