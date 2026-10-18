import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../features/lokasi/data/pickup_point_repository.dart';
import '../data/food_listing.dart';
import '../data/food_listing_repository.dart';
import '../logic/home_controller.dart';
import '../../notifikasi/data/notification_repository.dart';
import 'listing_detail_screen.dart';
import 'listing_form_screen.dart';
import '../../notifikasi/presentation/notification_screen.dart';
import 'widgets/food_listing_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeController(
        context.read<FoodListingRepository>(),
        context.read<PickupPointRepository>(),
      ),
      child: const _HomeScreenBody(),
    );
  }
}

class _HomeScreenBody extends StatelessWidget {
  const _HomeScreenBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final notifications = context.watch<NotificationRepository>();
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: kIsDonor
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ListingFormScreen()),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              elevation: 0,
              icon: const Icon(Icons.add_rounded),
              label: Text('TAMBAH DONASI', style: AppTextStyles.button),
            )
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 64)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 112),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const _GreetingBanner(),
                    const SizedBox(height: 16),
                    _SearchBar(controller: controller),
                    const SizedBox(height: 8),
                    _FilterBar(controller: controller),
                    const SizedBox(height: 16),
                    const _ResultsHeading(),
                    const SizedBox(height: 12),
                    if (controller.visibleListings.isEmpty)
                      const _EmptyResults()
                    else
                      ...controller.visibleListings.map((listing) {
                        final pickupPoint = controller.pickupPointRepository
                            .getById(listing.pickupPointId);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: FoodListingCard(
                            listing: listing,
                            pickupPointName:
                                pickupPoint?.name ?? 'Titik pengambilan',
                            now: controller.now,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ListingDetailScreen(
                                  listingId: listing.id,
                                  showOwnerActions: false,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 4),
                    const _ImpactBanner(),
                  ]),
                ),
              ),
            ],
          ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _HomeHeader(
                onNotifications: () => _openNotifications(context),
                unreadCount: notifications.unreadCount,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onNotifications, required this.unreadCount});

  final VoidCallback onNotifications;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppColors.background.withValues(alpha: 0.96),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: const Icon(Icons.campaign_outlined,
                color: AppColors.surface, size: 21),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppColors.primaryDeep),
                    Text('Kampus Utama', style: AppTextStyles.badge.copyWith(
                        color: AppColors.primaryDeep)),
                    const SizedBox(width: 3),
                    const Icon(Icons.circle, size: 6, color: AppColors.tealDeep),
                  ],
                ),
                Text('Beranda', style: AppTextStyles.heading),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onNotifications,
                tooltip: 'Notifikasi',
                icon: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.brownMid, size: 24),
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 4,
                  top: 2,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    height: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: AppTextStyles.badge.copyWith(
                          fontSize: 10, color: AppColors.surface),
                    )),
                  ),
                ),
            ],
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

class _GreetingBanner extends StatelessWidget {
  const _GreetingBanner();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('👋 Halo, Mahasiswa!', style: AppTextStyles.cardTitle),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r9999),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.border,
                    blurRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.tealDark),
                  const SizedBox(width: 4),
                  Text('24 Porsi Aktif', style: AppTextStyles.badge.copyWith(
                      color: AppColors.tealDeep)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 198,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.r20),
            boxShadow: const [
              BoxShadow(
                color: AppColors.primaryDark,
                blurRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 114,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AKSI BAIK HARI INI', maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.reward)),
                    Text('Yuk,\nselamatkan\nmakanan hari\nini!',
                      maxLines: 4,
                      overflow: TextOverflow.clip,
                        style: AppTextStyles.heading.copyWith(
                            color: AppColors.surface, height: 25 / 18)),
                    Text('Bantu kantin tekan limbah dan isi perutmu.',
                      maxLines: 3,
                      overflow: TextOverflow.clip,
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.bannerShadow, height: 16 / 12)),
                  ],
                ),
              ),
              Image.asset('assets/images/rasi_worried.png', width: 76, height: 76),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Cari makanan lezat di kampus...',
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.tealDeep),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.r16),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.r16),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        scrollDirection: Axis.horizontal,
        children: [
          _TypeChip(
            label: 'Semua',
            selected: controller.foodType == null,
            icon: Icons.restaurant_menu_outlined,
            onTap: controller.clearFoodType,
          ),
          for (final type in FoodType.values)
            _TypeChip(
              label: _foodTypeLabel(type),
              selected: controller.foodType == type,
              icon: _foodTypeIcon(type),
              onTap: () => controller.toggleFoodType(type),
            ),
          _FilterChipButton(
            label: _timeFilterLabel(controller.timeFilter),
            icon: Icons.schedule_rounded,
            onTap: () => _showTimeFilter(context),
          ),
          _FilterChipButton(
            label: _selectedLocationLabel(),
            icon: Icons.location_on_outlined,
            onTap: () => _showLocationFilter(context),
          ),
          // TODO: remove for final build
          if (kShowDemoControls) ...[
            const SizedBox(width: 6),
            _FilterChipButton(
              label: 'DEMO',
              icon: Icons.fast_forward_rounded,
              onTap: controller.fastForwardDemo,
            ),
          ],
        ],
      ),
    );
  }

  String _selectedLocationLabel() {
    if (controller.pickupPointId == null) return 'Lokasi';
    return controller.pickupPointRepository
            .getById(controller.pickupPointId!)
            ?.name ??
        'Lokasi';
  }

  Future<void> _showTimeFilter(BuildContext context) async {
    final selected = await showModalBottomSheet<TimeFilter>(
      context: context,
      showDragHandle: true,
      builder: (context) => _SelectionSheet<TimeFilter>(
        title: 'Sisa waktu',
        value: controller.timeFilter,
        options: const {
          TimeFilter.kurangDariSatuJam: '< 1 jam',
          TimeFilter.satuSampaiTigaJam: '1-3 jam',
          TimeFilter.lebihDariTigaJam: '> 3 jam',
          TimeFilter.semua: 'Semua',
        },
      ),
    );
    if (selected != null) controller.setTimeFilter(selected);
  }

  Future<void> _showLocationFilter(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => _LocationSheet(
        selectedId: controller.pickupPointId,
        repository: controller.pickupPointRepository,
      ),
    );
    if (selected != null) controller.setPickupPoint(selected.isEmpty ? null : selected);
  }

  String _foodTypeLabel(FoodType type) {
    return switch (type) {
      FoodType.makananBerat => 'Makanan berat',
      FoodType.camilan => 'Camilan',
      FoodType.minuman => 'Minuman',
      FoodType.lainnya => 'Lainnya',
    };
  }

  IconData _foodTypeIcon(FoodType type) {
    return switch (type) {
      FoodType.makananBerat => Icons.lunch_dining_outlined,
      FoodType.camilan => Icons.bakery_dining_outlined,
      FoodType.minuman => Icons.local_cafe_outlined,
      FoodType.lainnya => Icons.category_outlined,
    };
  }

  String _timeFilterLabel(TimeFilter filter) {
    return switch (filter) {
      TimeFilter.semua => 'Sisa waktu',
      TimeFilter.kurangDariSatuJam => '< 1 jam',
      TimeFilter.satuSampaiTigaJam => '1-3 jam',
      TimeFilter.lebihDariTigaJam => '> 3 jam',
    };
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        avatar: Icon(icon, size: 15,
            color: selected ? AppColors.surface : AppColors.textSecondary),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: AppTextStyles.chip.copyWith(
            color: selected ? AppColors.primaryDeep : AppColors.textSecondary),
        selectedColor: AppColors.primarySoft,
        backgroundColor: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r9999)),
        showCheckmark: false,
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        avatar: Icon(icon, size: 15, color: AppColors.tealDeep),
        onPressed: onTap,
        labelStyle: AppTextStyles.chip,
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r9999)),
      ),
    );
  }
}

class _ResultsHeading extends StatelessWidget {
  const _ResultsHeading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Menu Kampus Tersedia', style: AppTextStyles.heading),
          Text('Terbaru 10m lalu', style: AppTextStyles.badge),
        ],
      ),
    );
  }
}

class _ImpactBanner extends StatelessWidget {
  const _ImpactBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco_outlined,
                size: 17, color: AppColors.surface),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('DAMPAK POSITIF KAMPUS', style: AppTextStyles.overline.copyWith(
                    color: AppColors.primaryDeep)),
                Text('318 kg makanan terselamatkan bulan ini',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.brownDeep)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.primaryDeep),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 54, 32, 120),
      child: Column(
        children: [
          Image.asset('assets/images/rasi_empty.png', width: 120, height: 120),
          const SizedBox(height: 18),
          Text('Belum ada makanan yang cocok', style: AppTextStyles.heading,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Coba ubah kata pencarian atau filter yang dipilih.',
              style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SelectionSheet<T> extends StatelessWidget {
  const _SelectionSheet({required this.title, required this.value, required this.options});

  final String title;
  final T value;
  final Map<T, String> options;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: const EdgeInsets.all(20), child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: AppTextStyles.heading))),
          for (final option in options.entries)
            ListTile(
              title: Text(option.value, style: AppTextStyles.body),
              trailing: option.key == value
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(option.key),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _LocationSheet extends StatelessWidget {
  const _LocationSheet({required this.selectedId, required this.repository});

  final String? selectedId;
  final PickupPointRepository repository;

  @override
  Widget build(BuildContext context) {
    final points = repository.getAll();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(padding: const EdgeInsets.all(20), child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Lokasi', style: AppTextStyles.heading))),
          ListTile(
            title: Text('Semua lokasi', style: AppTextStyles.body),
            trailing: selectedId == null
                ? const Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
            onTap: () => Navigator.of(context).pop(''),
          ),
          for (final point in points)
            ListTile(
              title: Text(point.name, style: AppTextStyles.body),
              subtitle: Text(point.address, style: AppTextStyles.caption),
              trailing: selectedId == point.id
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(point.id),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}