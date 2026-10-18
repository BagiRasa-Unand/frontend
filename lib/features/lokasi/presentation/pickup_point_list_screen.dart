import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/pickup_point.dart';
import '../logic/pickup_point_list_notifier.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_radius.dart';
import 'pickup_point_form_screen.dart';
import 'delete_pickup_point_sheet.dart';

/// Sub-widget: solid-bottom-edge icon button used for edit & delete.
class _IconChunkyButton extends StatelessWidget {
  const _IconChunkyButton({
    required this.icon,
    required this.fillColor,
    required this.shadowColor,
    required this.iconColor,
    required this.onTap,
    this.semanticLabel,
  });

  final IconData icon;
  final Color fillColor;
  final Color shadowColor;
  final Color iconColor;
  final VoidCallback onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: semanticLabel,
        button: true,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppRadius.r12),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }
}

/// Sub-widget: pill badge used for status and active-listing count.
class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.label,
    required this.fillColor,
    required this.shadowColor,
    required this.textColor,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final Color fillColor;
  final Color shadowColor;
  final Color textColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.badge.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

/// Sub-widget: the "Quick Interactive Toggle Bar" inside each card.
class _StatusToggleBar extends StatelessWidget {
  const _StatusToggleBar({required this.point, required this.onToggle});

  final PickupPoint point;
  final VoidCallback onToggle;

  bool get _isActive => point.status == PickupPointStatus.aktif;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: icon + label + status text
          Row(
            children: [
              Icon(
                Icons.store_rounded,
                size: 18,
                color: _isActive ? AppColors.tealDeep : AppColors.slate,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 16 / 12,
                    ),
                  ),
                  Text(
                    _isActive ? 'Buka sekarang' : 'Sedang tutup',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _isActive ? AppColors.tealDeep : AppColors.textSecondary,
                      height: 16 / 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Right: chunky toggle switch
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _isActive ? AppColors.tealDeep : AppColors.toggleInactive,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: _isActive
                    ? [
                        const BoxShadow(
                          color: AppColors.tealDark,
                          blurRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    _isActive ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Resolves badge appearance from [PickupPointStatus].
({
  Color fill,
  Color shadow,
  Color textColor,
  IconData icon,
  Color iconColor,
  String label,
}) _statusBadgeProps(PickupPointStatus status) {
  return switch (status) {
    PickupPointStatus.aktif => (
        fill: AppColors.tealDeep,
        shadow: AppColors.tealDark,
        textColor: AppColors.surface,
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.surface,
        label: 'Buka & Aktif Menerima',
      ),
    PickupPointStatus.tutup => (
        fill: AppColors.slate,
        shadow: AppColors.slateShadow,
        textColor: AppColors.surface,
        icon: Icons.lock_rounded,
        iconColor: AppColors.surface,
        label: 'Sedang Tutup',
      ),
    PickupPointStatus.nonAktif => (
        fill: AppColors.neutralButton,
        shadow: AppColors.border,
        textColor: AppColors.textSecondary,
        icon: Icons.pause_circle_rounded,
        iconColor: AppColors.textSecondary,
        label: 'Tidak Aktif',
      ),
  };
}

({Color fill, Color shadow, Color textColor, Color iconColor, String label})
    _listingBadgeProps(int count, PickupPointStatus status) {
  if (status == PickupPointStatus.aktif && count > 0) {
    return (
      fill: AppColors.primarySoft,
      shadow: AppColors.primarySoftShadow,
      textColor: AppColors.primaryDeep,
      iconColor: AppColors.primaryDeep,
      label: '$count Listing Aktif',
    );
  }
  return (
    fill: AppColors.surfaceWarm,
    shadow: AppColors.border,
    textColor: AppColors.textSecondary,
    iconColor: AppColors.textSecondary,
    label: '$count Listing Aktif',
  );
}

/// Sub-widget: one pickup-point card.
class _PickupPointCard extends StatelessWidget {
  const _PickupPointCard({required this.point});
  final PickupPoint point;

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<PickupPointListNotifier>();
    final sBadge = _statusBadgeProps(point.status);
    final lBadge = _listingBadgeProps(point.activeListingCount, point.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.r20),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: notifier,
                child: PickupPointFormScreen(point: point),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row: name + address + action buttons ──────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name row
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  point.name,
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 24 / 18,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (point.status == PickupPointStatus.aktif)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.verified_rounded,
                                    size: 17,
                                    color: AppColors.tealDeep,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          // Address row
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 12, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  point.address,
                                  style: AppTextStyles.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit + Delete buttons
                    Row(
                      children: [
                        _IconChunkyButton(
                          icon: Icons.edit_rounded,
                          fillColor: AppColors.indigoSoft,
                          shadowColor: AppColors.indigoSoftShadow,
                          iconColor: const Color(0xFF000965),
                          semanticLabel: 'Edit titik ${point.name}',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider.value(
                                value: notifier,
                                child: PickupPointFormScreen(point: point),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _IconChunkyButton(
                          icon: Icons.delete_rounded,
                          fillColor: AppColors.dangerSoft,
                          shadowColor: AppColors.dangerSoftShadow,
                          iconColor: AppColors.danger,
                          semanticLabel: 'Hapus titik ${point.name}',
                          onTap: () =>
                              showDeletePickupPointSheet(context, point),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Badges row ───────────────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PillBadge(
                      label: sBadge.label,
                      fillColor: sBadge.fill,
                      shadowColor: sBadge.shadow,
                      textColor: sBadge.textColor,
                      icon: sBadge.icon,
                      iconColor: sBadge.iconColor,
                    ),
                    _PillBadge(
                      label: lBadge.label,
                      fillColor: lBadge.fill,
                      shadowColor: lBadge.shadow,
                      textColor: lBadge.textColor,
                      icon: Icons.restaurant_menu_rounded,
                      iconColor: lBadge.iconColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Toggle bar ───────────────────────────────────────────────
                _StatusToggleBar(
                  point: point,
                  onToggle: () => notifier.toggleStatus(point.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sub-widget: summary banner at the top.
class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.totalPoints,
    required this.totalListings,
  });

  final int totalPoints;
  final int totalListings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + title + "AKTIF" pill
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      blurRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.store_mall_directory_rounded,
                    size: 24, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + "AKTIF" badge
                    Row(
                      children: [
                        Text(
                          'Titik Pengambilan',
                          style: AppTextStyles.heading,
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.tealDeep,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            'AKTIF',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.surface,
                              height: 15 / 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pastikan data titik & jam operasional selalu diperbarui agar makanan terselamatkan tepat waktu.',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quick-stats pills
          Container(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.border,
                          blurRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.tealDeep,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$totalPoints Titik Aktif',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 16 / 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.border,
                          blurRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.restaurant_menu_rounded,
                            size: 14, color: AppColors.amber),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '$totalListings Total Listing',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 16 / 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
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
    );
  }
}

/// Sub-widget: empty state shown when repository has no points.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative blobs (approximated without backdrop-filter)
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: Column(
              children: [
                // Mascot Rasi illustration
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.border,
                        blurRadius: 0,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    // TODO: replace with Image.asset when rasi_empty.png is added
                    child: Center(
                      child: Icon(
                        Icons.sentiment_neutral_rounded,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // "Rasi sedang menunggu..." pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWarm,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.hourglass_empty_rounded,
                          size: 13, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Rasi sedang menunggu...',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.brownMid,
                          height: 16 / 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Belum Ada Titik Pengambilan',
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tambahkan titik pengambilan pertama agar donatur dan penerima bisa saling terhubung.',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lightbulb_rounded,
                          size: 15, color: AppColors.primaryDark),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Ketuk "+ TAMBAH TITIK" untuk memulai',
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.brownDeep,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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

/// Sub-widget: section header row ("Daftar Titik" + count badge + caption).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Daftar Titik', style: AppTextStyles.heading),
              const SizedBox(width: 8),
              // Count badge with chunky shadow
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.primaryDark,
                      blurRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.badge.copyWith(color: AppColors.surface),
                ),
              ),
            ],
          ),
        ),
        // Caption on right
        Text(
          'Diurutkan terbaru',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

/// App bar header with back button, logo area, title, and profile button.
class _PickupPointAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _PickupPointAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      size: 20, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 4),
              // App logo (fallback to icon)
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: Image.asset(
                  'assets/logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx2, err, stack) => Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.volunteer_activism,
                        size: 16, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Screen title
              Expanded(
                child: Text(
                  'Kelola Titik Pengambilan',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 24 / 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Profile avatar button
              GestureDetector(
                onTap: () {}, // navigasi profil – bukan bagian screen ini
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        size: 18, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────

/// "Kelola Titik Pengambilan" – Module C, READ list.
///
/// Reads from [PickupPointListNotifier] via Provider and rebuilds automatically
/// when the repository changes.
class PickupPointListScreen extends StatelessWidget {
  const PickupPointListScreen({super.key});

  void _openAddForm(BuildContext context) {
    final notifier = context.read<PickupPointListNotifier>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: notifier,
          child: const PickupPointFormScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<PickupPointListNotifier>();
    final points = notifier.points;
    final isEmpty = points.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const _PickupPointAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _SummaryBanner(
                totalPoints: notifier.totalPoints,
                totalListings: notifier.totalActiveListings,
              ),
            ),
          ),
          if (!isEmpty) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _SectionHeader(count: points.length),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
              sliver: SliverList.separated(
                itemCount: points.length,
                separatorBuilder: (_, idx) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) => _PickupPointCard(point: points[i]),
              ),
            ),
          ] else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 112),
              sliver: SliverToBoxAdapter(child: const _EmptyState()),
            ),
          ],
        ],
      ),
      // ── Sticky floating "+ TAMBAH TITIK" button ───────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: AppColors.background.withValues(alpha: 0.95),
        child: SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () => _openAddForm(context),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.r16),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryDark,
                    blurRadius: 0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded,
                      size: 22, color: AppColors.surface),
                  const SizedBox(width: 8),
                  Text(
                    '+ TAMBAH TITIK',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surface,
                      height: 24 / 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
