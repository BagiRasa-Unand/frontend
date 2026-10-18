import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../donasi/data/food_listing.dart';
import '../../donasi/data/food_listing_repository.dart';
import '../../donasi/presentation/listing_detail_screen.dart';
import '../data/app_notification.dart';
import '../data/notification_repository.dart';

enum _NotificationFilter { semua, newListing, claimStatus, reminder }

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NotificationBody();
  }
}

class _NotificationBody extends StatefulWidget {
  const _NotificationBody();

  @override
  State<_NotificationBody> createState() => _NotificationBodyState();
}

class _NotificationBodyState extends State<_NotificationBody> {
  _NotificationFilter _filter = _NotificationFilter.semua;

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<NotificationRepository>();
    final notifications = repository.getAll().where(_matchesFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _NotificationHeader()),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _NotificationToolbar(repository: repository),
                  const SizedBox(height: 8),
                  _FilterBar(
                    filter: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 12),
                  if (notifications.isEmpty)
                    const _EmptyNotifications()
                  else
                    ...notifications.map((notification) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NotificationCard(
                            notification: notification,
                            onTap: () => _openNotification(notification),
                          ),
                        )),
                  if (kShowDemoControls) ...[
                    const SizedBox(height: 8),
                    _DemoButton(onTap: _simulateNewListing),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(AppNotification notification) {
    return switch (_filter) {
      _NotificationFilter.semua => true,
      _NotificationFilter.newListing =>
        notification.type == AppNotificationType.newListing,
      _NotificationFilter.claimStatus =>
        notification.type == AppNotificationType.claimStatus,
      _NotificationFilter.reminder =>
        notification.type == AppNotificationType.reminder,
    };
  }

  void _openNotification(AppNotification notification) {
    final notificationRepository = context.read<NotificationRepository>();
    notificationRepository.markRead(notification.id);
    if (notification.type != AppNotificationType.newListing) return;

    final listingId = notification.refId;
    if (listingId == null) return;
    final listing = context.read<FoodListingRepository>().getById(listingId);
    if (listing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing sudah tidak tersedia')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: listing.id)),
    );
  }

  void _simulateNewListing() {
    // TODO: remove for final build
    final now = DateTime.now();
    final id = 'food-demo-${now.microsecondsSinceEpoch}';
    final listing = FoodListing(
      id: id,
      donorId: 'donor-demo-campus',
      donorName: 'Kantin Mitra Demo',
      name: 'Nasi Kotak Demo Kampus',
      foodType: FoodType.makananBerat,
      description: 'Listing simulasi untuk preview notifikasi baru.',
      quantityTotal: 15,
      quantityRemaining: 15,
      pickupPointId: 'pp-001',
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 2)),
    );
    context.read<FoodListingRepository>().add(listing);
    context.read<NotificationRepository>().add(
      AppNotification(
        id: 'notification-demo-${now.microsecondsSinceEpoch}',
        type: AppNotificationType.newListing,
        title: 'Listing baru: ${listing.name}',
        body: 'Kantin Mitra Demo baru saja membagikan 15 porsi untuk mahasiswa.',
        createdAt: now,
        isRead: false,
        refId: listing.id,
      ),
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader();

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
                Text('Notifikasi', style: AppTextStyles.heading),
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

class _NotificationToolbar extends StatelessWidget {
  const _NotificationToolbar({required this.repository});

  final NotificationRepository repository;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.r9999),
                  boxShadow: const [
                    BoxShadow(color: AppColors.primaryDark,
                        blurRadius: 0, offset: Offset(0, 2)),
                  ],
                ),
                child: Text('${repository.unreadCount} Baru',
                    style: AppTextStyles.badge.copyWith(color: AppColors.surface)),
              ),
              const SizedBox(width: 4),
              Text('Pesan untukmu', style: AppTextStyles.caption),
            ],
          ),
          TextButton.icon(
            onPressed: repository.unreadCount == 0
                ? null
                : repository.markAllRead,
            icon: const Icon(Icons.done_all_rounded,
                size: 15, color: AppColors.primary),
            label: Text('Tandai semua dibaca',
                style: AppTextStyles.badge.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.filter, required this.onChanged});

  final _NotificationFilter filter;
  final ValueChanged<_NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(label: 'Semua', value: _NotificationFilter.semua,
              selected: filter, onChanged: onChanged),
          _FilterChip(label: 'Donasi Baru', value: _NotificationFilter.newListing,
              selected: filter, onChanged: onChanged),
          _FilterChip(label: 'Status Klaim', value: _NotificationFilter.claimStatus,
              selected: filter, onChanged: onChanged),
          _FilterChip(label: 'Pengingat', value: _NotificationFilter.reminder,
              selected: filter, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.value,
      required this.selected, required this.onChanged});

  final String label;
  final _NotificationFilter value;
  final _NotificationFilter selected;
  final ValueChanged<_NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
            boxShadow: [
              BoxShadow(
                color: isSelected ? AppColors.bannerShadow : AppColors.border,
                blurRadius: 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: Text(label, style: AppTextStyles.chip.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary))),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _notificationStyle(notification.type);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? AppColors.surface : AppColors.creamSoft,
          borderRadius: BorderRadius.circular(AppRadius.r20),
          boxShadow: const [
            BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: style.color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: style.shadow,
                    blurRadius: 0, offset: const Offset(0, 3))],
              ),
              child: Icon(style.icon, color: style.iconColor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(notification.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 18))),
                      if (!notification.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notification.body, maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(color: AppColors.brownMid)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule_outlined, size: 12,
                          color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(_relativeTime(notification.createdAt),
                          style: AppTextStyles.badge.copyWith(
                              color: AppColors.textSecondary)),
                      const SizedBox(width: 6),
                      Text('•', style: AppTextStyles.caption),
                      const SizedBox(width: 6),
                      Text(style.label, style: AppTextStyles.badge.copyWith(
                          color: style.labelColor)),
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

  _NotificationVisual _notificationStyle(AppNotificationType type) {
    return switch (type) {
      AppNotificationType.newListing => const _NotificationVisual(
          icon: Icons.restaurant_rounded,
          color: AppColors.primary,
          shadow: AppColors.primaryDark,
          iconColor: AppColors.surface,
          label: 'Makanan Berat',
          labelColor: AppColors.primary),
      AppNotificationType.claimStatus => const _NotificationVisual(
          icon: Icons.verified_rounded,
          color: AppColors.indigo,
          shadow: AppColors.indigoDark,
          iconColor: AppColors.surface,
          label: 'Pengambilan',
          labelColor: AppColors.indigo),
      AppNotificationType.reminder => const _NotificationVisual(
          icon: Icons.timer_outlined,
          color: AppColors.amber,
          shadow: AppColors.primaryDark,
          iconColor: AppColors.textPrimary,
          label: 'Pengingat',
          labelColor: AppColors.amberDark),
    };
  }

  String _relativeTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Baru saja';
    if (difference.inHours < 1) return '${difference.inMinutes} menit lalu';
    if (difference.inDays < 1) return '${difference.inHours} jam lalu';
    return '${difference.inDays} hari lalu';
  }
}

class _NotificationVisual {
  const _NotificationVisual({required this.icon, required this.color,
      required this.shadow, required this.iconColor, required this.label,
      required this.labelColor});

  final IconData icon;
  final Color color;
  final Color shadow;
  final Color iconColor;
  final String label;
  final Color labelColor;
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r9999),
            boxShadow: const [
              BoxShadow(color: AppColors.border, blurRadius: 0, offset: Offset(0, 2)),
            ],
          ),
          child: Text('Simulasikan listing baru', style: AppTextStyles.badge.copyWith(
              color: AppColors.textSecondary)),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 80),
      child: Column(
        children: [
          Image.asset('assets/images/rasi_empty.png', width: 132, height: 132),
          const SizedBox(height: 16),
          Text('Belum ada notifikasi', style: AppTextStyles.heading,
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text('Semua pesan untukmu akan muncul di sini.',
              style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
