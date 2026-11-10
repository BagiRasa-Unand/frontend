import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../data/location_platform.dart';
import '../data/map_listing.dart';
import '../data/pickup_point_repository.dart';
import '../data/route_service.dart';
import '../logic/route_controller.dart';
import 'location_gate_view.dart';
import 'widgets/map_marker_pin.dart';
import 'widgets/map_user_location_marker.dart';
import 'widgets/route_bottom_card.dart';
import 'widgets/route_countdown_banner.dart';

/// Screen "Rute & Estimasi - BagiRasa" (Module C).
///
/// Displays real-time or estimated route guidance to a food rescue pickup point.
class RouteScreen extends StatefulWidget {
  const RouteScreen({
    super.key,
    required this.pickupPointId,
    this.pickupDeadline,
    this.listingName,
    this.routeService,
    this.locationPlatform,
  });

  final String pickupPointId;
  final DateTime? pickupDeadline;
  final String? listingName;
  final RouteService? routeService;
  final LocationPlatform? locationPlatform;

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final MapController _mapController = MapController();
  late final RouteController _controller;
  late final LatLng _destination;
  late final String _pickupPointName;
  String? _pickupPointAddress;

  @override
  void initState() {
    super.initState();
    final repo = context.read<PickupPointRepository>();
    final point = repo.getById(widget.pickupPointId);

    if (point != null) {
      _destination = LatLng(point.latitude, point.longitude);
      _pickupPointName = point.name;
      _pickupPointAddress = point.address;
    } else {
      _destination = const LatLng(-0.9140, 100.4590);
      _pickupPointName = 'Titik Pengambilan';
      _pickupPointAddress = null;
    }

    _controller = RouteController(
      routeService: widget.routeService ?? RouteService(),
      locationPlatform: widget.locationPlatform ?? const GeolocatorLocationPlatform(),
      destination: _destination,
      pickupPointName: _pickupPointName,
      pickupDeadline: widget.pickupDeadline,
      onArrived: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kamu telah sampai di titik pengambilan!'),
              backgroundColor: AppColors.tealDeep,
              duration: Duration(seconds: 4),
            ),
          );
        }
      },
    );

    // Initial check for user location per requirements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestUserLocation();
    });
  }

  Future<void> _requestUserLocation() async {
    final result = await ensureLocation(context, allowManual: true);
    if (!mounted) return;

    if (!result.cancelled && result.position != null) {
      _controller.setInitialLocation(result.position);
      _fitRouteBounds(result.position!, _destination);
    } else {
      _controller.setInitialLocation(null);
      _mapController.move(_destination, 16.5);
    }
  }

  void _fitRouteBounds(LatLng p1, LatLng p2) {
    final bounds = LatLngBounds.fromPoints([p1, p2]);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(40, 140, 40, 320),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final currentPos = _controller.currentPosition;
          final routeResult = _controller.routeResult;
          final isEstimate = routeResult?.isEstimate ?? true;

          return Stack(
            children: [
              // ── Layer 0: Map Canvas ───────────────────────────────────────
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _destination,
                  initialZoom: 16.5,
                  minZoom: 13.0,
                  maxZoom: 18.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.bagirasa.unand',
                  ),

                  // ── Route Line (Casing + Indigo Polyline) ─────────────────
                  if (routeResult != null && routeResult.points.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        // White halo casing underneath
                        Polyline(
                          points: routeResult.points,
                          strokeWidth: isEstimate ? 6.0 : 8.0,
                          color: AppColors.surface,
                        ),
                        // Main route polyline
                        Polyline(
                          points: routeResult.points,
                          strokeWidth: isEstimate ? 3.0 : 5.0,
                          color: AppColors.indigo,
                          pattern: isEstimate
                              ? StrokePattern.dashed(segments: const [10, 8])
                              : const StrokePattern.solid(),
                        ),
                      ],
                    ),

                  // ── Destination Marker Pin ─────────────────────────────────
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _destination,
                        width: 140,
                        height: 110,
                        alignment: Alignment.topCenter,
                        child: MapMarkerPin(
                          title: _pickupPointName,
                          portionCount: 5,
                          status: MapListingStatus.tersedia,
                          onTap: () {},
                          isSelected: true,
                        ),
                      ),
                      // ── User Location Marker Pin ───────────────────────────
                      if (currentPos != null)
                        Marker(
                          point: currentPos,
                          width: 160,
                          height: 95,
                          alignment: Alignment.center,
                          child: const MapUserLocationMarker(),
                        ),
                    ],
                  ),
                ],
              ),

              // ── Layer 1: Top Navigation Bar ───────────────────────────────
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 4,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(AppRadius.r12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Rute & Estimasi',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Map attribution & tactical buttons
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (currentPos != null) {
                                _fitRouteBounds(currentPos, _destination);
                              } else {
                                _mapController.move(_destination, 16.5);
                              }
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.surface,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.my_location_rounded,
                                  color: AppColors.primaryDeep,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Layer 2: Top Countdown Banner (if pickupDeadline != null) ──
              if (_controller.countdownController != null)
                Positioned(
                  left: 20,
                  right: 20,
                  top: 72,
                  child: SafeArea(
                    child: RouteCountdownBanner(
                      controller: _controller.countdownController!,
                    ),
                  ),
                ),

              // ── Layer 3: OSRM & OSM Map Attribution Pill ──────────────────
              Positioned(
                left: 16,
                bottom: 324,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(AppRadius.r4),
                  ),
                  child: Text(
                    '© OpenStreetMap contributors • Rute oleh OSRM',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              // ── Layer 4: Bottom Floating Navigation Guidance Card ──────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: RouteBottomCard(
                  controller: _controller,
                  pickupPointName: _pickupPointName,
                  listingName: widget.listingName,
                  address: _pickupPointAddress,
                  onRequestLocation: _requestUserLocation,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

