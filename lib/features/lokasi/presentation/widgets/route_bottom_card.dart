import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../data/route_service.dart';
import '../../logic/route_controller.dart';

/// Bottom Floating Navigation Guidance Card matching the BagiRasa spec.
class RouteBottomCard extends StatelessWidget {
  const RouteBottomCard({
    super.key,
    required this.controller,
    required this.pickupPointName,
    this.listingName,
    this.address,
    required this.onRequestLocation,
  });

  final RouteController controller;
  final String pickupPointName;
  final String? listingName;
  final String? address;
  final VoidCallback onRequestLocation;

  String _formatDistance(double? meters) {
    if (meters == null) return '--';
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '--';
    final minutes = duration.inMinutes;
    if (minutes < 1) {
      return '< 1 mnt';
    }
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remMinutes = minutes % 60;
      return '${hours}j ${remMinutes}m';
    }
    return '$minutes mnt';
  }

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final isEstimate = controller.routeResult?.isEstimate ?? true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.r24),
          topRight: Radius.circular(AppRadius.r24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 15,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Destination Title Row ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITIK PENGAMBILAN',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.55,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pickupPointName,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 20,
                        height: 25 / 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      listingName ?? address ?? 'Titik Resmi Penyaluran Kampus',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.r16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Body content according to state ────────────────────────────────
          if (state == RouteViewState.needsLocation) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceWarm,
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_off_rounded, color: AppColors.primaryDeep, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Lokasi kamu belum tersedia untuk menghitung rute.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ChunkyButton(
              label: 'Coba lagi',
              onTap: onRequestLocation,
              variant: ChunkyButtonVariant.primary,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.surface, size: 18),
            ),
          ] else if (state == RouteViewState.loading) ...[
            Container(
              height: 110,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Menghitung rute terbaik...',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ] else ...[
            // ── Distance & Estimated Time Metric Cards ───────────────────────
            Row(
              children: [
                // Jarak Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.creamSoft,
                      borderRadius: BorderRadius.circular(AppRadius.r16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.r12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.straighten_rounded,
                              size: 18,
                              color: AppColors.tealDeep,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'JARAK ESTIMASI',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                _formatDistance(controller.remainingDistanceMeters),
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 18,
                                  height: 24 / 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (isEstimate)
                                Text(
                                  'Perkiraan garis lurus',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDeep,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Waktu Tempuh Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.creamSoft,
                      borderRadius: BorderRadius.circular(AppRadius.r16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.r12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: AppColors.indigo,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WAKTU TEMPUH',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                _formatDuration(controller.estimatedDuration),
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 18,
                                  height: 24 / 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (isEstimate)
                                Text(
                                  'Perkiraan garis lurus',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDeep,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Travel Mode Chunky Switch ─────────────────────────────────────
            Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceWarm,
                borderRadius: BorderRadius.circular(AppRadius.r16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeTab(
                      label: 'Jalan Kaki',
                      icon: Icons.directions_walk_rounded,
                      isActive: controller.mode == TravelMode.walking,
                      onTap: () => controller.toggleMode(TravelMode.walking),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildModeTab(
                      label: 'Motor',
                      icon: Icons.two_wheeler_rounded,
                      isActive: controller.mode == TravelMode.motor,
                      onTap: () => controller.toggleMode(TravelMode.motor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Primary Action Button ─────────────────────────────────────────
            ChunkyButton(
              label: controller.isFollowing ? 'BERHENTI' : 'MULAI MENUJU LOKASI',
              onTap: controller.isFollowing
                  ? () => controller.stopFollowing()
                  : () => controller.startFollowing(),
              variant: controller.isFollowing
                  ? ChunkyButtonVariant.danger
                  : ChunkyButtonVariant.primary,
              icon: Icon(
                controller.isFollowing
                    ? Icons.stop_rounded
                    : Icons.navigation_rounded,
                color: AppColors.surface,
                size: 18,
              ),
            ),
          ],
          const SizedBox(height: 10),

          // ── Secondary Quick Assistance Links ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Menghubungkan ke kontak pengelola stan...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.call_rounded, size: 14, color: AppColors.primaryDeep),
                    const SizedBox(width: 4),
                    Text(
                      'Hubungi Pendonor',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: CircleAvatar(
                  radius: 2,
                  backgroundColor: AppColors.border,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tautan lokasi disalin ke papan klip.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.share_location_rounded, size: 14, color: AppColors.tealDeep),
                    const SizedBox(width: 4),
                    Text(
                      'Bagikan Lokasi',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.tealDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: isActive ? AppColors.indigo : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.surface : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.nunitoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isActive ? AppColors.surface : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

