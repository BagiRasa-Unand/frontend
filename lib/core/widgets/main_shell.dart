import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../features/lokasi/logic/pickup_point_list_notifier.dart';
import '../../features/lokasi/data/pickup_point_repository.dart';
import '../../features/lokasi/presentation/pickup_point_list_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_radius.dart';
import '../../features/lokasi/presentation/map_screen.dart';
import '../../features/donasi/presentation/home_screen.dart';
import '../../features/donasi/presentation/donation_history_screen.dart';
import '../../features/klaim/presentation/claim_tab_screen.dart';
import '../../features/klaim/presentation/claim_history_screen.dart';
import '../app_session.dart';

/// 4-tab bottom navigation shell.
///
/// Tabs without a real screen show a simple placeholder widget.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined, label: 'Beranda'),
    _TabItem(icon: Icons.location_on_rounded, label: 'Peta'),
    _TabItem(icon: Icons.shopping_bag_outlined, label: 'Klaim', hasBadge: true),
    _TabItem(icon: Icons.person_outline_rounded, label: 'Profil'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          const MapScreen(),
          const ClaimTabScreen(),
          _ProfilTab(),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        items: _tabs,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.label,
    this.hasBadge = false,
  });

  final IconData icon;
  final String label;
  final bool hasBadge;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<_TabItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2F2A26),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = i == currentIndex;

              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 70,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primarySoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: selected
                                ? AppColors.primary
                                : AppColors.slate,
                          ),
                          if (item.hasBadge)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.danger,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.surface,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        item.label,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10,
                          height: 1.1,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.primary
                              : AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}



/// Profil tab with the temporary navigation entry point.
class _ProfilTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_rounded, size: 48, color: AppColors.slate),
          const SizedBox(height: 12),
          Text('Profil', style: AppTextStyles.heading),
          const SizedBox(height: 24),
          // TODO(nav): temporary entry – remove when real Profil screen exists.
          _TempNavButton(
            label: 'Kelola Titik Pengambilan',
            icon: Icons.store_rounded,
            onTap: () => _openPickupPointList(context),
          ),
          if (kIsDonor) ...[
            const SizedBox(height: 12),
            // TODO(nav): temporary entry – remove when real Profil screen exists.
            _TempNavButton(
              label: 'Riwayat Donasi Saya',
              icon: Icons.history_edu_rounded,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DonationHistoryScreen(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // TODO(nav): temporary entry
          _TempNavButton(
            label: 'Riwayat Klaim Saya',
            icon: Icons.history_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ClaimHistoryScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPickupPointList(BuildContext context) {
    // Wrap with a fresh notifier that shares the singleton repository.
    final repo = context.read<PickupPointRepository>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => PickupPointListNotifier(repo),
          child: const PickupPointListScreen(),
        ),
      ),
    );
  }
}

class _TempNavButton extends StatelessWidget {
  const _TempNavButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.r12),
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
              Icon(icon, size: 18, color: AppColors.surface),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.button),
            ],
          ),
        ),
      ),
    );
  }
}
