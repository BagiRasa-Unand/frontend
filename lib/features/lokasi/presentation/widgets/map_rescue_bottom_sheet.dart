import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/map_listing.dart';

/// Draggable scrollable bottom sheet menampilkan daftar makanan yang dapat diselamatkan (Module C).
class MapRescueBottomSheet extends StatelessWidget {
  const MapRescueBottomSheet({
    super.key,
    required this.listings,
    required this.selectedListingId,
    required this.onSelectListing,
    required this.onCardTap,
  });

  final List<MapListing> listings;
  final String? selectedListingId;
  final ValueChanged<String> onSelectListing;
  final ValueChanged<MapListing> onCardTap;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.36,
      minChildSize: 0.14,
      maxChildSize: 0.72,
      snap: true,
      snapSizes: const [0.14, 0.36, 0.72],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.r28),
            ),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            children: [
              // 1. Drag Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.handle,
                    borderRadius: BorderRadius.circular(AppRadius.r9999),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Sheet Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.hub_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Titik Penyelamatan',
                          style: AppTextStyles.heading.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.45,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tealSoft,
                        borderRadius: BorderRadius.circular(AppRadius.r9999),
                        border: Border.all(
                          color: AppColors.tealDeep.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${listings.length} Lokasi Aktif',
                        style: AppTextStyles.chip.copyWith(
                          color: AppColors.tealDeep,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 3. Compact Listing Cards List
              Expanded(
                child: listings.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: listings.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = listings[index];
                          final isSelected = item.id == selectedListingId;
                          return _ListingCard(
                            listing: item,
                            isSelected: isSelected,
                            onTap: () {
                              onSelectListing(item.id);
                              onCardTap(item);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/rasi_empty.png',
            width: 72,
            height: 72,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.slate,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada makanan aktif',
            style: AppTextStyles.heading.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            'Coba ubah kata kunci atau filter pencarian.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.isSelected,
    required this.onTap,
  });

  final MapListing listing;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUrgent = listing.status == MapListingStatus.segeraHabis;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.primaryDark : AppColors.border,
              blurRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Photo Thumbnail with tag badge
            _buildThumbnail(isUrgent),

            const SizedBox(width: 12),

            // Right: Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name
                  Text(
                    listing.name,
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Location & Distance
                  Text(
                    '${listing.pickupPointName} • ${listing.distanceText}',
                    style: AppTextStyles.cardSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Horizontal divider
                  Container(
                    height: 1,
                    color: AppColors.border.withValues(alpha: 0.6),
                  ),

                  const SizedBox(height: 6),

                  // Bottom info row: Badges + Rute Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Badges
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _buildPortionBadge(isUrgent),
                            _buildTimeBadge(),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Rute Chunky Button (STUB)
                      _RouteChunkyButton(pickupPointName: listing.pickupPointName),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(bool isUrgent) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.r14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Illustration / Food Icon
          Icon(
            listing.categoryKey == 'snack'
                ? Icons.bakery_dining_rounded
                : Icons.lunch_dining_rounded,
            size: 36,
            color: isUrgent ? AppColors.amber : AppColors.primary,
          ),

          // Tag overlay in corner
          if (listing.discountTag != null)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                ),
                child: Text(
                  listing.discountTag!,
                  style: AppTextStyles.photoTag.copyWith(
                    color: listing.discountTag!.startsWith('-')
                        ? AppColors.primary
                        : AppColors.tealDeep,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPortionBadge(bool isUrgent) {
    final bgColor = isUrgent ? AppColors.amberSoft : AppColors.tealSoft;
    final dotColor = isUrgent ? AppColors.amber : AppColors.tealDeep;
    final textColor = isUrgent ? AppColors.amberDark : AppColors.tealDeep;
    final label = isUrgent
        ? 'Sisa ${listing.portionCount} porsi'
        : 'Tersedia ${listing.portionCount} porsi';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.pinBadge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.hourglass_top_rounded,
          size: 12,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 2),
        Text(
          listing.timeLeft,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _RouteChunkyButton extends StatefulWidget {
  const _RouteChunkyButton({required this.pickupPointName});

  final String pickupPointName;

  @override
  State<_RouteChunkyButton> createState() => _RouteChunkyButtonState();
}

class _RouteChunkyButtonState extends State<_RouteChunkyButton> {
  bool _pressed = false;

  void _handleTap() {
    // Sesuai STUB POLICY: tampilkan SnackBar
    // TODO(stub): navigation route to pickup point
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini belum tersedia'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double edge = 3;
    final double yOffset = _pressed ? edge : 0;

    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: edge),
        transform: Matrix4.translationValues(0, yOffset, 0),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.gpsIndigo,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          boxShadow: _pressed
              ? const []
              : const [
                  BoxShadow(
                    color: AppColors.indigoDark,
                    blurRadius: 0,
                    offset: Offset(0, edge),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_rounded,
              size: 13,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              'Rute',
              style: AppTextStyles.miniButton,
            ),
          ],
        ),
      ),
    );
  }
}
