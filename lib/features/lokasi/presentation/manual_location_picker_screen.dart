import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/chunky_button.dart';

// TODO(design): Minimal manual location picker map screen is not specified in Figma design.

/// Fallback full-screen map picker allowing the user to pick coordinates manually.
class ManualLocationPickerScreen extends StatefulWidget {
  const ManualLocationPickerScreen({
    super.key,
    this.initialPosition,
  });

  final LatLng? initialPosition;

  static const LatLng _kDefaultCenter = LatLng(-0.9140, 100.4590);

  @override
  State<ManualLocationPickerScreen> createState() => _ManualLocationPickerScreenState();
}

class _ManualLocationPickerScreenState extends State<ManualLocationPickerScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedPoint;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final center = _selectedPoint ?? widget.initialPosition ?? ManualLocationPickerScreen._kDefaultCenter;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Map Canvas ─────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 16.5,
              onTap: (_, point) {
                setState(() {
                  _selectedPoint = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.bagirasa.unand',
              ),
              if (_selectedPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPoint!,
                      width: 140,
                      height: 72,
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.r8),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.border,
                                  blurRadius: 0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Lokasi Pilihan',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark,
                                  blurRadius: 0,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.location_on_rounded,
                                color: AppColors.surface,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ── Header Bar ─────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(null),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.r12),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.border,
                            blurRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.border,
                          blurRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Ketuk Peta untuk Memilih Lokasi',
                      style: AppTextStyles.chip.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Confirmation Button ────────────────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SafeArea(
              child: ChunkyButton(
                label: 'GUNAKAN LOKASI INI',
                onTap: _selectedPoint == null
                    ? null
                    : () => Navigator.of(context).pop(_selectedPoint),
                variant: ChunkyButtonVariant.primary,
                icon: const Icon(Icons.check_rounded, color: AppColors.surface, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

