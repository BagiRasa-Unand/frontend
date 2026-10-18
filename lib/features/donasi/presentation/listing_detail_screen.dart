import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../klaim/presentation/claim_form_sheet.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../data/food_listing.dart';
import '../data/food_listing_repository.dart';
import '../logic/listing_detail_controller.dart';
import 'delete_listing_sheet.dart';
import 'listing_form_screen.dart';
import 'widgets/status_badge.dart';

class ListingDetailScreen extends StatelessWidget {
  const ListingDetailScreen({
    super.key,
    required this.listingId,
    this.showOwnerActions = true,
  });

  final String listingId;
  final bool showOwnerActions;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ListingDetailController(
        listingId: listingId,
        listingRepository: context.read<FoodListingRepository>(),
        pickupPointRepository: context.read<PickupPointRepository>(),
      ),
      child: _ListingDetailBody(showOwnerActions: showOwnerActions),
    );
  }
}

class _ListingDetailBody extends StatelessWidget {
  const _ListingDetailBody({required this.showOwnerActions});

  final bool showOwnerActions;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ListingDetailController>();
    final listing = controller.listing;
    if (listing == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.of(context).maybePop();
      });
      return const Scaffold(backgroundColor: AppColors.background);
    }

    final point = controller.pickupPoint;
    final status = listing.statusAt(controller.now);
    final isOwner = showOwnerActions && listing.donorId == kCurrentUserId;
    final isClosed = status == ListingStatus.habisDiklaim ||
        status == ListingStatus.kadaluarsa;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _DetailHeader(
                onBack: () => Navigator.of(context).pop(),
                onShare: () => _showShareMessage(context),
              ),
            ),
            const SliverToBoxAdapter(child: _PreviewSwitcher()),
            SliverToBoxAdapter(
              child: _HeroPhoto(
                listing: listing,
                status: status,
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SummaryCard(
                    listing: listing,
                    status: status,
                    now: controller.now,
                  ),
                  const SizedBox(height: 16),
                  _PickupCard(point: point),
                  const SizedBox(height: 16),
                  _DescriptionCard(description: listing.description),
                  const SizedBox(height: 16),
                  const _CommunityCard(),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _DetailActionBar(
        isOwner: isOwner,
        isClosed: isClosed,
        onEdit: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ListingFormScreen(listing: listing)),
        ),
        onDelete: () => showDeleteListingSheet(context, listing),
        onClaim: () => _showClaimStub(context),
      ),
    );
  }

  void _showShareMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini belum tersedia')),
    );
  }

  void _showClaimStub(BuildContext context) {
    final listing = context.read<ListingDetailController>().listing;
    if (listing != null) {
      showClaimSheet(context, listing);
    }
  }

}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.onBack, required this.onShare});

  final VoidCallback onBack;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: AppColors.background.withValues(alpha: 0.96),
      child: Row(
        children: [
          IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_rounded)),
          const SizedBox(width: 4),
          Expanded(child: Text('Detail Listing', style: AppTextStyles.heading)),
          IconButton(
            onPressed: onShare,
            tooltip: 'Bagikan',
            icon: const Icon(Icons.share_outlined, color: AppColors.brownMid),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryDeep,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline_rounded,
                color: AppColors.surface, size: 17),
          ),
        ],
      ),
    );
  }
}

class _PreviewSwitcher extends StatelessWidget {
  const _PreviewSwitcher();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      color: AppColors.creamSoft,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('MODE PRATINJAU TAMPILAN', style: AppTextStyles.overline),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.r9999),
                ),
                child: Text('BagiRasa Dev', style: AppTextStyles.badge.copyWith(
                    fontSize: 10, color: AppColors.primaryDark)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 34,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Row(
              children: [
                _PreviewPill(label: 'Klaim (Aktif)', selected: true),
                _PreviewPill(label: 'Pemilik Stan'),
                _PreviewPill(label: 'Sudah Habis'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPill extends StatelessWidget {
  const _PreviewPill({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 26,
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.r8),
          boxShadow: selected
              ? const [BoxShadow(color: AppColors.border, blurRadius: 2)]
              : null,
        ),
        child: Center(child: Text(label, style: AppTextStyles.badge.copyWith(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary))),
      ),
    );
  }
}

class _HeroPhoto extends StatelessWidget {
  const _HeroPhoto({required this.listing, required this.status, required this.onBack});

  final FoodListing listing;
  final ListingStatus status;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 288,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _Photo(path: listing.photoPath),
          Positioned(
            left: 20,
            top: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppRadius.r9999),
                boxShadow: const [
                  BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 15, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('Kampus Utama', style: AppTextStyles.badge),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 16,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 3)),
                ],
              ),
              child: const Icon(Icons.bookmark_border_rounded,
                  color: AppColors.textSecondary),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 12,
            child: StatusBadge(status: status, compact: false),
          ),
          Positioned(
            right: 20,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppRadius.r9999),
                boxShadow: const [
                  BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_outlined,
                      size: 15, color: AppColors.tealDeep),
                  const SizedBox(width: 4),
                  Text('100% Layak Santap', style: AppTextStyles.badge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    if (path != null) {
      if (path!.startsWith('assets/')) {
        return Image.asset(path!, fit: BoxFit.cover);
      }
      return Image.file(File(path!), fit: BoxFit.cover);
    }
    // TODO: add a real food-photo fallback asset when the data layer provides one.
    return Container(
      color: AppColors.surfaceWarm,
      child: const Center(
        child: Icon(Icons.restaurant_rounded, size: 76, color: AppColors.primary),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.listing, required this.status, required this.now});

  final FoodListing listing;
  final ListingStatus status;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final progress = listing.quantityTotal == 0
        ? 0.0
        : (listing.quantityRemaining / listing.quantityTotal).clamp(0.0, 1.0).toDouble();
    final accent = status == ListingStatus.segeraHabis
        ? AppColors.amber
        : status == ListingStatus.kadaluarsa
            ? AppColors.danger
            : AppColors.primary;

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.schedule_outlined,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Diunggah 20 mnt lalu', style: AppTextStyles.badge.copyWith(
                      color: AppColors.textSecondary)),
                ],
              ),
              _Tag(label: _foodTypeLabel(listing.foodType)),
            ],
          ),
          const SizedBox(height: 4),
          Text(listing.name, style: AppTextStyles.modalTitle),
          const SizedBox(height: 12),
          Container(
            height: 56,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primaryDark,
                        blurRadius: 0, offset: Offset(0, 2))],
                  ),
                  child: const Icon(Icons.storefront_outlined,
                      color: AppColors.surface, size: 19),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(listing.donorName,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardTitle)),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified_outlined,
                              size: 14, color: AppColors.tealDeep),
                        ],
                      ),
                      Text('Donatur terverifikasi', style: AppTextStyles.caption),
                    ],
                  ),
                ),
                _Tag(label: 'Akun Terverifikasi', color: AppColors.tealDeep),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${listing.quantityRemaining} dari ${listing.quantityTotal} ${listing.unit} tersisa',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
              _Tag(label: _timeLeftText(listing.timeLeftAt(now)), color: accent),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r9999),
            child: SizedBox(
              height: 14,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: AppColors.surfaceWarm),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(color: accent),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('Batas akhir pengambilan makanan: ${_formatDeadline(listing.expiresAt)}',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }

  String _timeLeftText(Duration duration) {
    if (duration == Duration.zero) return 'Waktu habis';
    if (duration.inHours > 0) return 'Sisa ${duration.inHours}j ${duration.inMinutes % 60}m';
    return 'Sisa ${duration.inMinutes}m';
  }

  String _formatDeadline(DateTime value) {
    return 'Hari ini, ${value.hour.toString().padLeft(2, '0')}.${value.minute.toString().padLeft(2, '0')} WIB';
  }

  String _foodTypeLabel(FoodType type) => switch (type) {
        FoodType.makananBerat => 'Makanan Berat',
        FoodType.camilan => 'Camilan / Roti',
        FoodType.minuman => 'Minuman',
        FoodType.lainnya => 'Lainnya',
      };
}

class _PickupCard extends StatelessWidget {
  const _PickupCard({required this.point});

  final dynamic point;

  @override
  Widget build(BuildContext context) {
    if (point == null) {
      return _DetailCard(
        child: Text('Titik pengambilan tidak tersedia', style: AppTextStyles.body),
      );
    }

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: const Icon(Icons.location_on_outlined,
                    size: 17, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text('Titik Pengambilan', style: AppTextStyles.heading)),
              _Tag(label: 'Buka', color: AppColors.tealDeep),
            ],
          ),
          const SizedBox(height: 12),
          Text(point.name as String, style: AppTextStyles.cardTitle),
          const SizedBox(height: 3),
          Text(point.address as String, style: AppTextStyles.caption),
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.r12),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(point.latitude as double, point.longitude as double),
                  initialZoom: 16,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.bagirasa.unand',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(point.latitude as double, point.longitude as double),
                      width: 36,
                      height: 36,
                      child: const Icon(Icons.location_on,
                          color: AppColors.primary, size: 34),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 26,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(AppRadius.r8),
              boxShadow: const [BoxShadow(color: AppColors.border,
                  blurRadius: 0, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rute jalan kaki tersedia', style: AppTextStyles.badge),
                GestureDetector(
                  onTap: () {
                    // TODO(stub): connect to the route/map flow.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fitur ini belum tersedia')),
                    );
                  },
                  child: Text('Buka Peta  →', style: AppTextStyles.badge.copyWith(
                      color: AppColors.tealDeep)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _IconSquare(icon: Icons.notes_rounded, color: AppColors.brownMid),
              const SizedBox(width: 8),
              Text('Deskripsi & Detail Makanan', style: AppTextStyles.heading),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description.isEmpty
                ? 'Makanan disiapkan dengan baik dan siap dibagikan kepada mahasiswa kampus.'
                : description,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 6,
            runSpacing: 8,
            children: [
              _SmallTag(label: 'Bebas Daging Babi'),
              _SmallTag(label: 'Wadah Ramah Lingkungan'),
              _SmallTag(label: 'Masak Baru Hari Ini'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Catatan Penting Pengambilan',
                          style: AppTextStyles.badge),
                      const SizedBox(height: 2),
                      Text('Tunjukkan kode QR klaim aplikasi kepada petugas stan. Sangat disarankan membawa tote bag atau kantong sendiri demi kelestarian kampus hijau.',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  const _CommunityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.r20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r16),
              boxShadow: const [BoxShadow(color: AppColors.border,
                  blurRadius: 0, offset: Offset(0, 3))],
            ),
            child: Image.asset('assets/images/rasi_empty.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kamu Pahlawan Pangan!', style: AppTextStyles.cardTitle),
                Text('Mengklaim donasi ini menyelamatkan makanan dan membantu kampus lebih hijau.',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActionBar extends StatelessWidget {
  const _DetailActionBar({
    required this.isOwner,
    required this.isClosed,
    required this.onEdit,
    required this.onDelete,
    required this.onClaim,
  });

  final bool isOwner;
  final bool isClosed;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.97),
          boxShadow: const [
            BoxShadow(color: AppColors.border, blurRadius: 16, offset: Offset(0, -4)),
          ],
        ),
        child: isOwner
            ? Row(
                children: [
                  Expanded(child: ChunkyButton(
                    label: 'UBAH', onTap: onEdit, height: 52,
                    icon: const Icon(Icons.edit_outlined, size: 17,
                        color: AppColors.surface),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: ChunkyButton(
                    label: 'HAPUS', onTap: onDelete,
                    variant: ChunkyButtonVariant.danger, height: 52,
                    icon: const Icon(Icons.delete_outline_rounded, size: 17,
                        color: AppColors.surface),
                  )),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChunkyButton(
                    label: isClosed ? 'KLAIM TIDAK TERSEDIA' : 'KLAIM MAKANAN',
                    onTap: isClosed ? null : onClaim,
                    height: 56,
                    icon: const Icon(Icons.volunteer_activism_outlined,
                        size: 18, color: AppColors.surface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isClosed
                        ? 'Listing ini sudah tidak dapat diklaim.'
                        : '100% Gratis  •  Maksimal 1 Porsi per Mahasiswa',
                    style: AppTextStyles.badge.copyWith(
                        color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        boxShadow: const [
          BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, this.color = AppColors.brownMid});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color == AppColors.tealDeep
            ? AppColors.tealSoft
            : AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
      ),
      child: Text(label, style: AppTextStyles.badge.copyWith(color: color)),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
      ),
      child: Text('✓ $label', style: AppTextStyles.badge.copyWith(
          color: AppColors.brownMid)),
    );
  }
}

class _IconSquare extends StatelessWidget {
  const _IconSquare({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }
}
