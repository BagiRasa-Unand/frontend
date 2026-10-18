import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';

/// Floating action button untuk memusatkan peta ke lokasi pengguna (STUB).
class MapGpsFloatingButton extends StatefulWidget {
  const MapGpsFloatingButton({super.key, this.onCenter});

  final VoidCallback? onCenter;

  @override
  State<MapGpsFloatingButton> createState() => _MapGpsFloatingButtonState();
}

class _MapGpsFloatingButtonState extends State<MapGpsFloatingButton> {
  bool _pressed = false;

  void _handleTap() {
    // Panggil callback reposisi peta
    widget.onCenter?.call();

    // Sesuai STUB POLICY: tampilkan SnackBar
    // TODO(stub): implement real GPS tracking and permission check
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
    const double edge = 4;
    final double yOffset = _pressed ? edge : 0;

    return GestureDetector(
      onTap: _handleTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: edge),
        transform: Matrix4.translationValues(0, yOffset, 0),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r16),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: _pressed
              ? const []
              : const [
                  BoxShadow(
                    color: AppColors.border,
                    blurRadius: 0,
                    offset: Offset(0, edge),
                  ),
                ],
        ),
        child: const Center(
          child: Icon(
            Icons.my_location_rounded,
            color: AppColors.gpsIndigo,
            size: 24,
          ),
        ),
      ),
    );
  }
}
