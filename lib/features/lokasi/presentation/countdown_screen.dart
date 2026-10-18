import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/chunky_button.dart';
import '../logic/countdown_controller.dart';

/// Control flag to show simulation chips for testing all 4 visual states live.
/// Set to `false` for the final production build.
const bool kShowCountdownDemoControls = true;

/// Screen "Countdown Pengambilan" (Module C).
///
/// Displays:
/// 1. Interactive countdown card with dynamic visual levels (Normal, Warning, Critical, Expired).
/// 2. Rescue order details with voucher pass code.
/// 3. Side-by-side 4 states preview grid.
/// 4. Reminder push/vibration toggles (local UI state with stub note).
/// 5. Sticky bottom action CTAs (Navigation & Cancel).
class CountdownScreen extends StatelessWidget {
  const CountdownScreen({
    super.key,
    required this.pickupDeadline,
    this.totalWindow = const Duration(minutes: 30),
    this.listingName = 'Nasi Ayam Bakar Komplit',
    this.pickupPointName = 'Kantin Teknik Sisfo (Gedung GKB Lt. 1)',
    this.merchantName = 'Warung Bu Endang (Stan No. 04)',
    this.voucherCode = '9482',
    this.orderCode = '#BGR-9482',
    this.distanceText = '120m',
  });

  final DateTime pickupDeadline;
  final Duration totalWindow;
  final String listingName;
  final String pickupPointName;
  final String merchantName;
  final String voucherCode;
  final String orderCode;
  final String distanceText;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CountdownController>(
      create: (_) => CountdownController(
        pickupDeadline: pickupDeadline,
        totalWindow: totalWindow,
      ),
      child: _CountdownScreenBody(
        listingName: listingName,
        pickupPointName: pickupPointName,
        merchantName: merchantName,
        voucherCode: voucherCode,
        orderCode: orderCode,
        distanceText: distanceText,
      ),
    );
  }
}

class _CountdownScreenBody extends StatefulWidget {
  const _CountdownScreenBody({
    required this.listingName,
    required this.pickupPointName,
    required this.merchantName,
    required this.voucherCode,
    required this.orderCode,
    required this.distanceText,
  });

  final String listingName;
  final String pickupPointName;
  final String merchantName;
  final String voucherCode;
  final String orderCode;
  final String distanceText;

  @override
  State<_CountdownScreenBody> createState() => _CountdownScreenBodyState();
}

class _CountdownScreenBodyState extends State<_CountdownScreenBody> {
  // Local state for reminder toggles (stub policy: no background scheduling)
  bool _remind30Min = true;
  bool _remind10Min = true;
  bool _remindVibration = true;

  void _onToggleReminder(String label, bool value, void Function(bool) updater) {
    setState(() => updater(value));
    // TODO(stub): reminder scheduling not implemented
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? '$label diaktifkan. (Fitur pengingat notifikasi belum tersedia)'
              : '$label dinonaktifkan.',
          style: AppTextStyles.caption.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCopyVoucher() {
    Clipboard.setData(ClipboardData(text: widget.voucherCode));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Kode voucher ${widget.voucherCode} disalin ke papan klip!',
          style: AppTextStyles.caption.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.tealDeep,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onNavigateLocation() {
    // TODO(stub): route navigation not implemented
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fitur navigasi rute ke lokasi belum tersedia.',
          style: AppTextStyles.caption.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCancelClaim() {
    // TODO(stub): cancel claim backend call not implemented
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.r16),
        ),
        title: Text('Batalkan Klaim?', style: AppTextStyles.heading),
        content: Text(
          'Porsi makanan akan dikembalikan ke etalase agar dapat dinikmati mahasiswa lain.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Kembali',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Klaim makanan berhasil dibatalkan.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.surface),
                  ),
                  backgroundColor: AppColors.textPrimary,
                ),
              );
            },
            child: Text(
              'Ya, Batalkan',
              style: AppTextStyles.badge.copyWith(color: AppColors.surface),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CountdownController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _CountdownTopAppBar(
          onBack: () => Navigator.of(context).pop(),
          onHelp: () {
            // TODO(stub): help support not implemented
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Fitur bantuan tiket belum tersedia.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.surface),
                ),
                backgroundColor: AppColors.textPrimary,
              ),
            );
          },
          onProfile: () {
            // TODO(stub): user profile screen not implemented
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Fitur profil belum tersedia.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                ),
                backgroundColor: AppColors.textPrimary,
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Gamified Info Banner
              const _GamifiedInfoBanner(),
              const SizedBox(height: 16),

              // 2. Interactive Simulation State Selector (if enabled)
              if (kShowCountdownDemoControls) ...[
                _InteractiveStateSelector(controller: controller),
                const SizedBox(height: 16),
              ],

              // 3. Primary Interactive Countdown Card
              _PrimaryCountdownCard(
                controller: controller,
                pickupPointName: widget.pickupPointName,
                distanceText: widget.distanceText,
              ),
              const SizedBox(height: 20),

              // 4. Rescue Order Details Card
              _RescueOrderDetailsCard(
                listingName: widget.listingName,
                merchantName: widget.merchantName,
                orderCode: widget.orderCode,
                voucherCode: widget.voucherCode,
                onCopyVoucher: _onCopyVoucher,
              ),
              const SizedBox(height: 20),

              // 5. 4 States Preview Grid
              const _StatesComparisonGrid(),
              const SizedBox(height: 20),

              // 6. Reminder Settings Card
              _ReminderSettingsCard(
                remind30Min: _remind30Min,
                remind10Min: _remind10Min,
                remindVibration: _remindVibration,
                onToggle30Min: (v) => _onToggleReminder(
                  'Ingatkan 30 menit sebelum',
                  v,
                  (val) => _remind30Min = val,
                ),
                onToggle10Min: (v) => _onToggleReminder(
                  'Ingatkan 10 menit sebelum',
                  v,
                  (val) => _remind10Min = val,
                ),
                onToggleVibration: (v) => _onToggleReminder(
                  'Ingatkan via Getaran Kuat',
                  v,
                  (val) => _remindVibration = val,
                ),
              ),
              const SizedBox(height: 24),

              // 7. Sticky Bottom Actions
              _BottomActionButtons(
                onNavigate: _onNavigateLocation,
                onCancel: _onCancelClaim,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Top App Bar
// ─────────────────────────────────────────────────────────────────────────────

class _CountdownTopAppBar extends StatelessWidget {
  const _CountdownTopAppBar({
    required this.onBack,
    required this.onHelp,
    required this.onProfile,
  });

  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
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
              // Back Button (44x44, white rounded container)
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(AppRadius.r12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.border,
                        blurRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tiket Klaim Aktif',
                style: AppTextStyles.heading,
              ),
            ],
          ),
          Row(
            children: [
              // Support button (36x36 cream circle)
              InkWell(
                onTap: onHelp,
                borderRadius: BorderRadius.circular(AppRadius.r9999),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.support_agent_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // User avatar button (32x32 deep orange circle)
              InkWell(
                onTap: onProfile,
                borderRadius: BorderRadius.circular(AppRadius.r9999),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDeep,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.surface,
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

// ─────────────────────────────────────────────────────────────────────────────
// 2. Gamified Info Banner
// ─────────────────────────────────────────────────────────────────────────────

class _GamifiedInfoBanner extends StatelessWidget {
  const _GamifiedInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.bannerShadow,
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Orange icon badge
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark,
                  blurRadius: 0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.timer_outlined,
              size: 20,
              color: AppColors.surface,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PANTAUAN PENGAMBILAN',
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.primaryDeep,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Jangan biarkan porsi berkah terbuang!',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────────────────────────
// 3. Interactive State Selector Bar (DEMO Controls)
// ─────────────────────────────────────────────────────────────────────────────

class _InteractiveStateSelector extends StatelessWidget {
  const _InteractiveStateSelector({required this.controller});

  final CountdownController controller;

  @override
  Widget build(BuildContext context) {
    final currentLevel = controller.level;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.track_changes_rounded,
                  size: 14,
                  color: AppColors.primaryDeep,
                ),
                const SizedBox(width: 6),
                Text(
                  'Simulasi Status Hitung Mundur:',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.pillNeutral,
                borderRadius: BorderRadius.circular(AppRadius.r9999),
              ),
              child: Text(
                'Klik Tab',
                style: AppTextStyles.badge.copyWith(
                  fontSize: 10,
                  color: AppColors.brownMid,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _DemoChip(
                label: 'Normal (>10m)',
                dotColor: AppColors.tealDeep,
                isActive: currentLevel == CountdownLevel.normal,
                activeBg: AppColors.tealDeep,
                activeShadow: AppColors.tealDark,
                activeText: AppColors.surface,
                onTap: () {
                  controller.setRemaining(const Duration(minutes: 24, seconds: 35));
                },
              ),
              const SizedBox(width: 8),
              _DemoChip(
                label: 'Peringatan (<10m)',
                dotColor: AppColors.amber,
                isActive: currentLevel == CountdownLevel.warning,
                activeBg: AppColors.amber,
                activeShadow: AppColors.amberDark,
                activeText: AppColors.warningTextDark,
                onTap: () {
                  controller.setRemaining(const Duration(minutes: 8, seconds: 42));
                },
              ),
              const SizedBox(width: 8),
              _DemoChip(
                label: 'Kritis (<3m)',
                dotColor: AppColors.danger,
                isActive: currentLevel == CountdownLevel.critical,
                activeBg: AppColors.danger,
                activeShadow: AppColors.dangerDark,
                activeText: AppColors.surface,
                onTap: () {
                  controller.setRemaining(const Duration(minutes: 2, seconds: 15));
                },
              ),
              const SizedBox(width: 8),
              _DemoChip(
                label: 'Hangus (00:00)',
                dotColor: AppColors.slate,
                isActive: currentLevel == CountdownLevel.expired,
                activeBg: AppColors.slate,
                activeShadow: AppColors.slateShadow,
                activeText: AppColors.surface,
                onTap: () {
                  controller.setRemaining(Duration.zero);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DemoChip extends StatelessWidget {
  const _DemoChip({
    required this.label,
    required this.dotColor,
    required this.isActive,
    required this.activeBg,
    required this.activeShadow,
    required this.activeText,
    required this.onTap,
  });

  final String label;
  final Color dotColor;
  final bool isActive;
  final Color activeBg;
  final Color activeShadow;
  final Color activeText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? activeBg : AppColors.surface;
    final shadow = isActive ? activeShadow : AppColors.border;
    final textColor = isActive ? activeText : AppColors.textPrimary;
    final circleColor = isActive ? AppColors.surface : dotColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.r9999),
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.chip.copyWith(
                color: textColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Primary Interactive Countdown Card
// ─────────────────────────────────────────────────────────────────────────────

class _PrimaryCountdownCard extends StatelessWidget {
  const _PrimaryCountdownCard({
    required this.controller,
    required this.pickupPointName,
    required this.distanceText,
  });

  final CountdownController controller;
  final String pickupPointName;
  final String distanceText;

  @override
  Widget build(BuildContext context) {
    final level = controller.level;

    // Visual theme colors based on active level
    final Color primaryColor = switch (level) {
      CountdownLevel.normal => AppColors.tealDeep,
      CountdownLevel.warning => AppColors.amber,
      CountdownLevel.critical => AppColors.danger,
      CountdownLevel.expired => AppColors.slate,
    };

    final Color shadowColor = switch (level) {
      CountdownLevel.normal => AppColors.tealDark,
      CountdownLevel.warning => AppColors.amberDark,
      CountdownLevel.critical => AppColors.dangerDark,
      CountdownLevel.expired => AppColors.slateShadow,
    };

    final percentageText = '${(controller.progress * 100).round()}%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Status badge & Mascot avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CountdownBadge(level: level),
              _MascotFace(level: level),
            ],
          ),
          const SizedBox(height: 12),

          // Big Chunky Digital Timer
          Column(
            children: [
              Text(
                'SISA WAKTU PENJEMPUTAN',
                style: AppTextStyles.timerSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                controller.formattedTimer,
                style: AppTextStyles.countdownTimer.copyWith(
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rounded Chunky Progress Bar Track
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Batas Waktu Klaim',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                percentageText,
                style: AppTextStyles.badge.copyWith(
                  fontSize: 13,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _ChunkyProgressBar(
            progress: controller.progress,
            barColor: primaryColor,
            shadowColor: shadowColor,
          ),
          const SizedBox(height: 16),

          // Dynamic Alert Microcopy
          _AlertMicrocopy(level: level, primaryColor: primaryColor),
          const SizedBox(height: 12),

          // Quick Location Bar Inside Card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.primaryDeep,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pickupPointName,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                distanceText,
                style: AppTextStyles.heading.copyWith(
                  fontSize: 15,
                  color: AppColors.primaryDeep,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.level});

  final CountdownLevel level;

  @override
  Widget build(BuildContext context) {
    final (bg, shadow, textColor, iconData, text) = switch (level) {
      CountdownLevel.normal => (
          AppColors.tealDeep,
          AppColors.tealDark,
          AppColors.surface,
          Icons.check_circle_outline_rounded,
          'Waktu Cukup Aman',
        ),
      CountdownLevel.warning => (
          AppColors.amber,
          AppColors.amberDark,
          AppColors.warningTextDark,
          Icons.warning_amber_rounded,
          'Peringatan (<10m)',
        ),
      CountdownLevel.critical => (
          AppColors.danger,
          AppColors.dangerDark,
          AppColors.surface,
          Icons.error_outline_rounded,
          'Kritis (< 3m)',
        ),
      CountdownLevel.expired => (
          AppColors.slate,
          AppColors.slateShadow,
          AppColors.surface,
          Icons.timer_off_outlined,
          'Waktu Pengambilan Habis',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 13, color: textColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.badge.copyWith(
              color: textColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotFace extends StatelessWidget {
  const _MascotFace({required this.level});

  final CountdownLevel level;

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (level) {
      case CountdownLevel.normal:
        // Cheerful mascot avatar / smiling expression
        content = const Text(
          '(^‿^)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        );
      case CountdownLevel.warning:
      case CountdownLevel.critical:
        // Worried mascot
        content = Image.asset(
          'assets/images/rasi_worried.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.sentiment_dissatisfied_rounded,
            color: AppColors.danger,
            size: 28,
          ),
        );
      case CountdownLevel.expired:
        // Empty / sad mascot
        content = Image.asset(
          'assets/images/rasi_empty.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.sentiment_very_dissatisfied_rounded,
            color: AppColors.slate,
            size: 28,
          ),
        );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.border,
            blurRadius: 0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: content,
    );
  }
}

class _ChunkyProgressBar extends StatelessWidget {
  const _ChunkyProgressBar({
    required this.progress,
    required this.barColor,
    required this.shadowColor,
  });

  final double progress;
  final Color barColor;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 16,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadius.r9999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            height: 12,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(AppRadius.r9999),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlertMicrocopy extends StatelessWidget {
  const _AlertMicrocopy({
    required this.level,
    required this.primaryColor,
  });

  final CountdownLevel level;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final (icon, message) = switch (level) {
      CountdownLevel.normal => (
          Icons.sentiment_satisfied_alt_rounded,
          'Waktu sangat lapang! Silakan menuju ke stan kantin dengan santai dan simpan senyum terbaikmu.',
        ),
      CountdownLevel.warning => (
          Icons.warning_amber_rounded,
          'Segera merapat ke lokasi! Sisa waktu kurang dari 10 menit sebelum porsi dialihkan.',
        ),
      CountdownLevel.critical => (
          Icons.error_outline_rounded,
          'Gawat! Kurang dari 3 menit lagi. Segera tunjukkan voucher ke penjual sekarang!',
        ),
      CountdownLevel.expired => (
          Icons.highlight_off_rounded,
          'Waktu pengambilan habis. Porsi ini telah hangus atau dialihkan kembali ke etalase.',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12,
                height: 16 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Rescue Order Details Card
// ─────────────────────────────────────────────────────────────────────────────

class _RescueOrderDetailsCard extends StatelessWidget {
  const _RescueOrderDetailsCard({
    required this.listingName,
    required this.merchantName,
    required this.orderCode,
    required this.voucherCode,
    required this.onCopyVoucher,
  });

  final String listingName;
  final String merchantName;
  final String orderCode;
  final String voucherCode;
  final VoidCallback onCopyVoucher;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row: icon + title + order badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.restaurant_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Detail Pesanan\nPenyelamatan',
                    style: AppTextStyles.heading.copyWith(fontSize: 16),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.r9999),
                ),
                child: Text(
                  orderCode,
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Listing info row: thumbnail + details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail (80x80)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.border,
                      blurRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lunch_dining_rounded,
                  size: 38,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listingName,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.storefront_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            merchantName,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // 1 Porsi badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceWarm,
                            borderRadius: BorderRadius.circular(AppRadius.r6),
                          ),
                          child: Text(
                            '1 Porsi',
                            style: AppTextStyles.badge.copyWith(
                              fontSize: 11,
                              color: AppColors.brownMid,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Klaim Gratis badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.pillNeutral,
                            borderRadius: BorderRadius.circular(AppRadius.r6),
                          ),
                          child: Text(
                            'Klaim Gratis',
                            style: AppTextStyles.badge.copyWith(
                              fontSize: 11,
                              color: AppColors.primaryDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Voucher Pass Key Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.creamSoft,
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tunjukkan Kode ini ke Penjual:',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      voucherCode,
                      style: AppTextStyles.voucherCode,
                    ),
                  ],
                ),
                InkWell(
                  onTap: onCopyVoucher,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.copy_all_outlined,
                          size: 14,
                          color: AppColors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Salin',
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 12,
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

// ─────────────────────────────────────────────────────────────────────────────
// 6. Side-by-Side 4 States Preview Grid
// ─────────────────────────────────────────────────────────────────────────────

class _StatesComparisonGrid extends StatelessWidget {
  const _StatesComparisonGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.layers_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Pratinjau Keadaan Waktu',
                  style: AppTextStyles.heading.copyWith(fontSize: 16),
                ),
              ],
            ),
            Text(
              '4 Fase Sistem',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _MiniStateCard(
                badgeText: 'Normal',
                badgeBg: AppColors.tealDeep,
                badgeTextCol: AppColors.surface,
                shadowColor: AppColors.tealDark,
                timerText: '00:24:35',
                timerColor: AppColors.tealDeep,
                subtitle: '> 10 Menit tersisa',
                subtitleColor: AppColors.textSecondary,
                progressFactor: 0.70,
                barColor: AppColors.tealDeep,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MiniStateCard(
                badgeText: 'Peringatan',
                badgeBg: AppColors.amber,
                badgeTextCol: AppColors.warningTextDark,
                shadowColor: AppColors.amber,
                timerText: '00:08:42',
                timerColor: AppColors.amber,
                subtitle: '< 10 Menit (Segera)',
                subtitleColor: AppColors.textSecondary,
                progressFactor: 0.25,
                barColor: AppColors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _MiniStateCard(
                badgeText: 'Kritis',
                badgeBg: AppColors.danger,
                badgeTextCol: AppColors.surface,
                shadowColor: AppColors.dangerDark,
                timerText: '00:02:15',
                timerColor: AppColors.danger,
                subtitle: '< 3 Menit (Gawat!)',
                subtitleColor: AppColors.danger,
                progressFactor: 0.08,
                barColor: AppColors.danger,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _MiniStateCard(
                badgeText: 'Hangus',
                badgeBg: AppColors.slate,
                badgeTextCol: AppColors.surface,
                shadowColor: AppColors.slate,
                timerText: '00:00:00',
                timerColor: AppColors.slate,
                subtitle: 'Waktu berakhir',
                subtitleColor: AppColors.textSecondary,
                progressFactor: 0.0,
                barColor: AppColors.slate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniStateCard extends StatelessWidget {
  const _MiniStateCard({
    required this.badgeText,
    required this.badgeBg,
    required this.badgeTextCol,
    required this.shadowColor,
    required this.timerText,
    required this.timerColor,
    required this.subtitle,
    required this.subtitleColor,
    required this.progressFactor,
    required this.barColor,
  });

  final String badgeText;
  final Color badgeBg;
  final Color badgeTextCol;
  final Color shadowColor;
  final String timerText;
  final Color timerColor;
  final String subtitle;
  final Color subtitleColor;
  final double progressFactor;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(AppRadius.r9999),
            ),
            child: Text(
              badgeText,
              style: AppTextStyles.badge.copyWith(
                color: badgeTextCol,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Timer
          Text(
            timerText,
            style: AppTextStyles.cardTitle.copyWith(
              color: timerColor,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              color: subtitleColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Small progress bar
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceWarm,
              borderRadius: BorderRadius.circular(AppRadius.r9999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progressFactor.clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(AppRadius.r9999),
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

// ─────────────────────────────────────────────────────────────────────────────
// 7. Reminder Settings Card (Toggles)
// ─────────────────────────────────────────────────────────────────────────────

class _ReminderSettingsCard extends StatelessWidget {
  const _ReminderSettingsCard({
    required this.remind30Min,
    required this.remind10Min,
    required this.remindVibration,
    required this.onToggle30Min,
    required this.onToggle10Min,
    required this.onToggleVibration,
  });

  final bool remind30Min;
  final bool remind10Min;
  final bool remindVibration;
  final ValueChanged<bool> onToggle30Min;
  final ValueChanged<bool> onToggle10Min;
  final ValueChanged<bool> onToggleVibration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  size: 15,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan Pengingat',
                      style: AppTextStyles.heading.copyWith(fontSize: 16),
                    ),
                    Text(
                      'Notifikasi push dan getaran ponsel pintar',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Toggle 1: 30 minutes
          _ReminderToggleRow(
            title: 'Ingatkan 30 menit sebelum',
            subtitle: 'Pemberitahuan awal untuk bersiap jalan',
            value: remind30Min,
            onChanged: onToggle30Min,
          ),
          const SizedBox(height: 8),

          // Toggle 2: 10 minutes
          _ReminderToggleRow(
            title: 'Ingatkan 10 menit sebelum',
            subtitle: 'Alarm darurat berbunyi nyaring',
            value: remind10Min,
            onChanged: onToggle10Min,
          ),
          const SizedBox(height: 8),

          // Toggle 3: Strong vibration
          _ReminderToggleRow(
            title: 'Ingatkan via Getaran Kuat',
            subtitle: 'Bermanfaat saat di kelas atau berjalan santai',
            value: remindVibration,
            onChanged: onToggleVibration,
          ),
        ],
      ),
    );
  }
}

class _ReminderToggleRow extends StatelessWidget {
  const _ReminderToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.creamSoft,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ChunkySwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ChunkySwitch extends StatelessWidget {
  const _ChunkySwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 28,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.toggleInactive,
          borderRadius: BorderRadius.circular(AppRadius.r9999),
          boxShadow: [
            BoxShadow(
              color: value ? AppColors.primaryDark : AppColors.border,
              blurRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. Sticky Action Buttons
// ─────────────────────────────────────────────────────────────────────────────

class _BottomActionButtons extends StatelessWidget {
  const _BottomActionButtons({
    required this.onNavigate,
    required this.onCancel,
  });

  final VoidCallback onNavigate;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primary CTA
        ChunkyButton(
          label: 'NAVIGASI KE LOKASI SEKARANG',
          onTap: onNavigate,
          variant: ChunkyButtonVariant.primary,
          edge: 4,
          icon: const Icon(
            Icons.near_me_rounded,
            size: 16,
            color: AppColors.surface,
          ),
        ),
        const SizedBox(height: 10),
        // Secondary CTA
        ChunkyButton(
          label: 'Batalkan Klaim Makanan',
          onTap: onCancel,
          variant: ChunkyButtonVariant.neutral,
          edge: 3,
          height: 40,
          textColor: AppColors.textPrimary,
          icon: const Icon(
            Icons.cancel_outlined,
            size: 16,
            color: AppColors.danger,
          ),
        ),
      ],
    );
  }
}
