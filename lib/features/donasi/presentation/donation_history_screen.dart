import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../data/food_listing.dart';
import '../data/food_listing_repository.dart';
import '../logic/donation_history_controller.dart';
import 'listing_detail_screen.dart';
import 'widgets/status_badge.dart';

class DonationHistoryScreen extends StatelessWidget {
  const DonationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DonationHistoryController(
        context.read<FoodListingRepository>(),
      ),
      child: const _DonationHistoryBody(),
    );
  }
}

class _DonationHistoryBody extends StatelessWidget {
  const _DonationHistoryBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DonationHistoryController>();
    final stats = controller.stats;
    final listings = controller.listings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _HistoryHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _StatsRow(stats: stats),
                  const SizedBox(height: 12),
                  const _DonorLevelCard(),
                  const SizedBox(height: 16),
                  _FilterSwitcher(controller: controller),
                  const SizedBox(height: 16),
                  if (listings.isEmpty)
                    const _EmptyHistory()
                  else
                    ...listings.map((listing) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _HistoryCard(
                            listing: listing,
                            now: controller.now,
                            pickupPointName: context
                                .read<PickupPointRepository>()
                                .getById(listing.pickupPointId)
                                ?.name ??
                              'Titik pengambilan',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ListingDetailScreen(
                                  listingId: listing.id,
                                ),
                              ),
                            ),
                          ),
                        )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: AppColors.background.withValues(alpha: 0.96),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BAGIRASA', style: AppTextStyles.overline),
                Text('Riwayat Donasi', style: AppTextStyles.heading),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryDeep,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline_rounded,
                size: 17, color: AppColors.surface),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final DonorStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(
          value: stats.totalSaved,
          label: 'Porsi Berkah',
          icon: Icons.volunteer_activism_outlined,
          fill: AppColors.warningSoft,
          iconColor: AppColors.warningText,
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          value: stats.totalListings,
          label: 'Listing Terbit',
          icon: Icons.inventory_2_outlined,
          fill: AppColors.primarySoft,
          iconColor: AppColors.primary,
        )),
        const SizedBox(width: 10),
        Expanded(child: _StatCard(
          value: stats.expiredCount,
          label: 'Terlewat',
          icon: Icons.hourglass_empty_rounded,
          fill: AppColors.dangerSoft,
          iconColor: AppColors.danger,
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon,
      required this.fill, required this.iconColor});

  final int value;
  final String label;
  final IconData icon;
  final Color fill;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 103,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: const [
          BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          Text('$value', style: AppTextStyles.modalTitle.copyWith(
              color: iconColor == AppColors.danger
                  ? AppColors.dangerDark
                  : AppColors.brownDark)),
          Text(label, textAlign: TextAlign.center,
              style: AppTextStyles.badge.copyWith(fontSize: 10, color: iconColor)),
        ],
      ),
    );
  }
}

class _DonorLevelCard extends StatelessWidget {
  const _DonorLevelCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        boxShadow: const [
          BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.reward.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: const Icon(Icons.emoji_events_outlined,
                color: AppColors.amberDark, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('PERINGKAT DONATUR', style: AppTextStyles.overline),
                    const SizedBox(width: 4),
                    _SmallPill(label: 'Lv. 4'),
                  ],
                ),
                Text('Pahlawan Pangan Teladan Kampus', style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _FilterSwitcher extends StatelessWidget {
  const _FilterSwitcher({required this.controller});

  final DonationHistoryController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 36,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.pillNeutral,
            borderRadius: BorderRadius.circular(AppRadius.r16),
          ),
          child: Row(
            children: [
              _ViewPill(label: 'Daftar Donasi', icon: Icons.list_alt_rounded, selected: true),
              _ViewPill(label: 'Pratinjau Kosong', icon: Icons.sentiment_neutral_outlined),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _HistoryFilterChip(controller: controller,
                  value: DonationHistoryFilter.semua, label: 'Semua'),
              _HistoryFilterChip(controller: controller,
                  value: DonationHistoryFilter.tersedia, label: 'Tersedia'),
              _HistoryFilterChip(controller: controller,
                  value: DonationHistoryFilter.habisDiklaim, label: 'Habis Diklaim'),
              _HistoryFilterChip(controller: controller,
                  value: DonationHistoryFilter.kadaluarsa, label: 'Kadaluarsa'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ViewPill extends StatelessWidget {
  const _ViewPill({required this.label, required this.icon, this.selected = false});

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          boxShadow: selected
              ? const [BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13,
                color: selected ? AppColors.textPrimary : AppColors.textSecondary),
            const SizedBox(width: 5),
            Text(label, style: AppTextStyles.badge.copyWith(
                color: selected ? AppColors.textPrimary : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({required this.controller, required this.value, required this.label});

  final DonationHistoryController controller;
  final DonationHistoryFilter value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final selected = controller.filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => controller.setFilter(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
            boxShadow: [
              BoxShadow(
                color: selected ? AppColors.primaryDark : AppColors.border,
                blurRadius: 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: Text(
            '$label (${controller.countFor(value)})',
            style: AppTextStyles.chip.copyWith(
                color: selected ? AppColors.surface : AppColors.textSecondary),
          )),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.listing, required this.now,
      required this.pickupPointName, required this.onTap});

  final FoodListing listing;
  final DateTime now;
  final String pickupPointName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = listing.statusAt(now);
    final muted = status == ListingStatus.kadaluarsa;
    final accent = muted ? AppColors.danger : AppColors.teal;
    final progress = listing.quantityTotal == 0
        ? 0.0
        : (listing.claimedQuantity / listing.quantityTotal).clamp(0.0, 1.0).toDouble();

    return Opacity(
      opacity: muted ? 0.9 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r20),
            boxShadow: const [
              BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HistoryPhoto(path: listing.photoPath, muted: muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusBadge(status: status, compact: true),
                              Flexible(child: Text(_dateText(listing.createdAt),
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption)),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(listing.name, maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.storefront_outlined,
                                  size: 12, color: muted ? AppColors.danger : AppColors.primaryDeep),
                              const SizedBox(width: 4),
                                Expanded(child: Text(pickupPointName,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: muted ? AppColors.dangerSoft.withValues(alpha: 0.7) : AppColors.creamSoft,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(muted ? 'Waktu habis' : 'Distribusi Makanan',
                            style: AppTextStyles.badge.copyWith(color: accent)),
                        Text(muted
                            ? '${listing.claimedQuantity} porsi terlewat'
                            : '${listing.claimedQuantity} / ${listing.quantityTotal} porsi habis terbagi',
                            style: AppTextStyles.badge.copyWith(
                                color: muted ? AppColors.dangerDark : AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r9999),
                      child: SizedBox(
                        height: 8,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(color: AppColors.border),
                            FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: progress,
                              child: Container(color: accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateText(DateTime date) {
    final nowDate = DateTime.now();
    if (date.year == nowDate.year && date.month == nowDate.month && date.day == nowDate.day) {
      return 'Hari ini, ${_time(date)}';
    }
    final yesterday = nowDate.subtract(const Duration(days: 1));
    if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      return 'Kemarin, ${_time(date)}';
    }
    return '${date.day} ${_month(date.month)} ${date.year}';
  }

  String _time(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  String _month(int month) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ][month];

}

class _HistoryPhoto extends StatelessWidget {
  const _HistoryPhoto({required this.path, required this.muted});

  final String? path;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r14),
      child: SizedBox(
        width: 80,
        height: 80,
        child: path == null
            ? Container(
                color: AppColors.surfaceWarm,
                child: Icon(Icons.restaurant_rounded,
                    size: 30, color: muted ? AppColors.slate : AppColors.primary),
              )
            : path!.startsWith('assets/')
                ? Image.asset(path!, fit: BoxFit.cover)
                : Image.file(File(path!), fit: BoxFit.cover),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  const _SmallPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
      ),
      child: Text(label, style: AppTextStyles.badge.copyWith(
          fontSize: 10, color: AppColors.primaryDeep)),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
      child: Column(
        children: [
          Image.asset('assets/images/rasi_empty.png', width: 132, height: 132),
          const SizedBox(height: 16),
          Text('Belum ada donasi di sini', style: AppTextStyles.heading,
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('Listing donasimu akan muncul di halaman ini setelah dibuat.',
              style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
