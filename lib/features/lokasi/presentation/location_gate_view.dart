import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/chunky_button.dart';
import '../data/location_service.dart';
import '../logic/location_gate_controller.dart';
import 'manual_location_picker_screen.dart';

/// Result object returned by location resolution workflows.
class LocationGateResult {
  const LocationGateResult({
    this.position,
    this.isManual = false,
    this.cancelled = false,
  });

  final LatLng? position;
  final bool isManual;
  final bool cancelled;

  factory LocationGateResult.success(LatLng position, {bool isManual = false}) {
    return LocationGateResult(
      position: position,
      isManual: isManual,
      cancelled: false,
    );
  }

  factory LocationGateResult.cancelled() {
    return const LocationGateResult(
      position: null,
      isManual: false,
      cancelled: true,
    );
  }
}

/// Guard function that checks location readiness before executing location-dependent actions.
///
/// If location status is already [LocationStatus.granted] and a position is successfully
/// obtained, it returns immediately without displaying any UI.
/// Otherwise, it opens the [LocationGateScreen].
Future<LocationGateResult> ensureLocation(
  BuildContext context, {
  bool allowManual = false,
}) async {
  final service = context.read<LocationService>();
  final status = await service.checkStatus();

  if (status == LocationStatus.granted) {
    final position = await service.getCurrentLatLng();
    if (position != null) {
      return LocationGateResult.success(position);
    }
  }

  if (!context.mounted) {
    return LocationGateResult.cancelled();
  }

  final result = await Navigator.of(context).push<LocationGateResult>(
    MaterialPageRoute(
      builder: (_) => LocationGateScreen(allowManual: allowManual),
    ),
  );

  return result ?? LocationGateResult.cancelled();
}

/// Full screen container hosting the [LocationGateView], matching the Figma layout.
class LocationGateScreen extends StatefulWidget {
  const LocationGateScreen({
    super.key,
    this.allowManual = false,
    this.initialStatus,
  });

  final bool allowManual;
  final LocationStatus? initialStatus;

  @override
  State<LocationGateScreen> createState() => _LocationGateScreenState();
}

class _LocationGateScreenState extends State<LocationGateScreen> {
  late final LocationGateController _controller;

  @override
  void initState() {
    super.initState();
    final service = context.read<LocationService>();
    _controller = LocationGateController(
      service: service,
      onResolved: (position) {
        if (mounted) {
          Navigator.of(context).pop(LocationGateResult.success(position));
        }
      },
      onShowHint: (message) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );

    // Initial evaluation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.checkStatus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (Height: 64px) ───────────────────────────────────────
            _buildHeader(context),

            // ── Main Content Area ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 350),
                    child: LocationGateView(
                      controller: _controller,
                      allowManual: widget.allowManual,
                      onResult: (result) {
                        Navigator.of(context).pop(result);
                      },
                      onCancel: () {
                        Navigator.of(context).pop(LocationGateResult.cancelled());
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWarm,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(LocationGateResult.cancelled()),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Izin Lokasi & GPS',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primaryDeep,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.gps_fixed_rounded,
                    color: AppColors.surface,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reusable view presenting the mascot, mode switcher segment, explanation cards,
/// and action buttons for location and GPS permission gates.
class LocationGateView extends StatelessWidget {
  const LocationGateView({
    super.key,
    required this.controller,
    this.allowManual = false,
    this.onResult,
    this.onCancel,
  });

  final LocationGateController controller;
  final bool allowManual;
  final ValueChanged<LocationGateResult>? onResult;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Mode Switcher Pill Segment ──────────────────────────────────
            _buildModeSwitcher(),
            const SizedBox(height: 16),

            // ── Interactive Mascot Frame ────────────────────────────────────
            _buildMascotFrame(),
            const SizedBox(height: 16),

            // ── Content Card (Details & Benefits) ───────────────────────────
            _buildContentCard(),
            const SizedBox(height: 20),

            // ── Action Buttons ──────────────────────────────────────────────
            _buildActionButtons(context),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegmentButton(
              title: 'Izin Lokasi',
              icon: Icons.location_on_rounded,
              isSelected: controller.selectedSegment == 0,
              onTap: () => controller.selectSegment(0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSegmentButton(
              title: 'Status GPS',
              icon: Icons.gps_fixed_rounded,
              isSelected: controller.selectedSegment == 1,
              onTap: () => controller.selectSegment(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.r8),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.border,
                    blurRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.primaryDeep : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.nunitoSans(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primaryDeep : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotFrame() {
    final (badgeText, badgeIcon) = switch (controller.gateState) {
      LocationGateState.permissionNeeded => (
          'Akses Lokasi Dibutuhkan',
          Icons.near_me_rounded
        ),
      LocationGateState.permissionDeniedForever => (
          'Izin Lokasi Diblokir',
          Icons.lock_outline_rounded
        ),
      LocationGateState.gpsOff => (
          'Layanan GPS Nonaktif',
          Icons.gps_off_rounded
        ),
    };

    return Container(
      height: 238,
      padding: const EdgeInsets.all(16),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Backdrop Ring
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 176,
              height: 176,
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Cyan Soft Glow
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: AppColors.cyanBright.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Mascot and Sub-badge column
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: Image.asset(
                  'assets/images/rasi_worried.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cyanBright,
                  borderRadius: BorderRadius.circular(AppRadius.r9999),
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
                    Icon(
                      badgeIcon,
                      size: 13,
                      color: AppColors.cyanDeepText,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      badgeText,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 11,
                        height: 14 / 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.22,
                        color: AppColors.cyanDeepText,
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

  Widget _buildContentCard() {
    final (title, explanation, icon) = switch (controller.gateState) {
      LocationGateState.permissionNeeded => (
          'Kenapa Butuh Lokasimu?',
          'BagiRasa butuh lokasimu untuk menemukan kantin terdekat, menghitung waktu tempuh jalan kaki, dan memastikan makanan masih hangat saat kamu tiba.',
          Icons.near_me_rounded,
        ),
      LocationGateState.permissionDeniedForever => (
          'Izin Lokasi Diperlukan',
          'Izin lokasi dinonaktifkan secara permanen di tingkat sistem. Buka Pengaturan aplikasi untuk mengaktifkannya secara manual.',
          Icons.settings_rounded,
        ),
      LocationGateState.gpsOff => (
          'GPS Perangkat Mati',
          'Layanan GPS di perangkatmu sedang nonaktif. Aktifkan GPS agar BagiRasa dapat menemukan kantin terdekat dan rute jalan kaki secara akurat.',
          Icons.gps_off_rounded,
        ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with rounded icon badge
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Explanatory paragraph
          Text(
            explanation,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // Benefits List
          _buildBenefitItem(
            icon: Icons.storefront_rounded,
            iconBgColor: AppColors.cyanBadge,
            iconColor: AppColors.cyanBadgeText,
            title: 'Kantin Terdekat',
            subtitle: 'Temukan makanan surplus yang paling dekat dengan posisimu saat ini.',
          ),
          const SizedBox(height: 8),
          _buildBenefitItem(
            icon: Icons.directions_walk_rounded,
            iconBgColor: AppColors.primarySoft,
            iconColor: AppColors.primary,
            title: 'Estimasi Waktu Tempuh',
            subtitle: 'Hitung jarak dan rute jalan kaki akurat menuju titik pengambilan makanan.',
          ),
          const SizedBox(height: 8),
          _buildBenefitItem(
            icon: Icons.timer_rounded,
            iconBgColor: AppColors.indigoSoft,
            iconColor: AppColors.indigoDeepText,
            title: 'Makanan Masih Hangat',
            subtitle: 'Pastikan kamu tiba sebelum batas waktu pengambilan berakhir.',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 14, color: iconColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final (primaryLabel, primaryIcon) = switch (controller.gateState) {
      LocationGateState.permissionNeeded => (
          'IZINKAN',
          Icons.near_me_rounded
        ),
      LocationGateState.permissionDeniedForever => (
          'BUKA PENGATURAN',
          Icons.settings_rounded
        ),
      LocationGateState.gpsOff => (
          'AKTIFKAN GPS',
          Icons.gps_fixed_rounded
        ),
    };

    return Column(
      children: [
        // Primary Chunky Button
        ChunkyButton(
          label: primaryLabel,
          onTap: controller.isLoading ? null : () => controller.handlePrimaryAction(),
          variant: ChunkyButtonVariant.primary,
          icon: Icon(primaryIcon, color: AppColors.surface, size: 18),
        ),
        const SizedBox(height: 8),

        // Secondary Button: Nanti Saja
        GestureDetector(
          onTap: onCancel,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r12),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.border,
                  blurRadius: 0,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Nanti Saja',
                style: GoogleFonts.nunitoSans(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),

        // Optional Manual Location Picker Link
        if (allowManual) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final pickedPoint = await Navigator.of(context).push<LatLng>(
                MaterialPageRoute(
                  builder: (_) => const ManualLocationPickerScreen(),
                ),
              );
              if (pickedPoint != null) {
                onResult?.call(
                  LocationGateResult.success(pickedPoint, isManual: true),
                );
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Pilih lokasi manual',
                style: GoogleFonts.nunitoSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDeep,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
