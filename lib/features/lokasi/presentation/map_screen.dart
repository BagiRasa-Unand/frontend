import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/pickup_point_repository.dart';
import '../data/map_listing.dart';
import '../logic/map_controller.dart';
import 'countdown_screen.dart';
import 'widgets/map_top_header.dart';
import 'widgets/map_search_filter_bar.dart';
import 'widgets/map_marker_pin.dart';
import 'widgets/map_user_location_marker.dart';
import 'widgets/map_gps_floating_button.dart';
import 'widgets/map_rescue_bottom_sheet.dart';

/// Layar "Peta Utama" (Module C) menampilkan peta kampus dengan pin titik penyelamatan makanan aktif.
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => MapNotifier(ctx.read<PickupPointRepository>()),
      child: const _MapScreenBody(),
    );
  }
}

class _MapScreenBody extends StatelessWidget {
  const _MapScreenBody();

  // TODO(stub): dummy fixed user GPS coordinate shown in Figma design
  static const LatLng _kDummyUserLocation =
      LatLng(kCampusCenterLat - 0.0002, kCampusCenterLng + 0.0004);

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<MapNotifier>();
    final activePoints = notifier.activePickupPoints;
    final listings = notifier.filteredListings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Layer 0: Real Full-Screen FlutterMap ────────────────────────────
          FlutterMap(
            mapController: notifier.mapController,
            options: const MapOptions(
              initialCenter: kCampusCenter,
              initialZoom: 16.5,
              minZoom: 14.0,
              maxZoom: 18.5,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.bagirasa.unand',
              ),

              // Ground labels for campus buildings
              MarkerLayer(
                markers: [
                  _buildBuildingLabel(
                    'PERPUS PUSAT',
                    const LatLng(kCampusCenterLat + 0.0017, kCampusCenterLng - 0.0014),
                  ),
                  _buildBuildingLabel(
                    'FAKULTAS MIPA',
                    const LatLng(kCampusCenterLat + 0.0003, kCampusCenterLng - 0.0018),
                  ),
                  _buildBuildingLabel(
                    'GEDUNG REKTORAT',
                    const LatLng(kCampusCenterLat - 0.0002, kCampusCenterLng + 0.0016),
                  ),
                ],
              ),

              // User Location Marker
              const MarkerLayer(
                markers: [
                  Marker(
                    point: _kDummyUserLocation,
                    width: 160,
                    height: 95,
                    alignment: Alignment.center,
                    child: MapUserLocationMarker(),
                  ),
                ],
              ),

              // Active Pickup Point Pins
              MarkerLayer(
                markers: activePoints.map((point) {
                  final status = notifier.statusForPickupPoint(point.id) ??
                      MapListingStatus.tersedia;
                  final portions = notifier.portionCountForPickupPoint(point.id);
                  final isSelected = notifier.filteredListings.any(
                    (l) =>
                        l.pickupPointId == point.id &&
                        l.id == notifier.selectedListingId,
                  );

                  return Marker(
                    point: LatLng(point.latitude, point.longitude),
                    width: 140,
                    height: 110,
                    alignment: Alignment.topCenter,
                    child: MapMarkerPin(
                      title: point.name,
                      portionCount: portions,
                      status: status,
                      isSelected: isSelected,
                      onTap: () {
                        notifier.selectPickupPoint(point.id);
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── Layer 1: Floating Header & Search Bar ──────────────────────────
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MapTopHeader(),
                const SizedBox(height: 8),
                MapSearchFilterBar(
                  activeFilter: notifier.activeFilter,
                  onFilterChanged: (filter) => notifier.setFilter(filter),
                  onSearchChanged: (query) => notifier.setSearchQuery(query),
                ),
              ],
            ),
          ),

          // ── Layer 2: Floating GPS Action Button ─────────────────────────────
          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).size.height * 0.38,
            child: MapGpsFloatingButton(
              onCenter: () {
                notifier.mapController.move(_kDummyUserLocation, 17.0);
              },
            ),
          ),

          // ── Layer 3: Draggable Bottom Sheet with Rescue Listings ───────────
          MapRescueBottomSheet(
            listings: listings,
            selectedListingId: notifier.selectedListingId,
            onSelectListing: (id) => notifier.selectListing(id),
            onCardTap: (listing) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CountdownScreen(
                    pickupDeadline: listing.pickupDeadline,
                    listingName: listing.name,
                    pickupPointName: listing.pickupPointName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Marker _buildBuildingLabel(String name, LatLng point) {
    return Marker(
      point: point,
      width: 110,
      height: 24,
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(AppRadius.r4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          name,
          style: AppTextStyles.pinBadge.copyWith(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ),
    );
  }
}
