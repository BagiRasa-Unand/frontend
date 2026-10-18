import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// Variant enum for [ChunkyButton].
enum ChunkyButtonVariant { primary, danger, neutral }

/// A full-width, 48-px-tall button with a solid "chunky" bottom edge.
///
/// The bottom edge is rendered via a [BoxShadow] with `blurRadius: 0` and
/// `offset: Offset(0, edge)`, giving it a raised, tactile appearance.
/// On press the button shifts down by [edge] pixels and the shadow disappears,
/// simulating a physical key press.
///
/// ### Parameters
/// | Param     | Default              | Description                         |
/// |-----------|----------------------|-------------------------------------|
/// | [label]   | required             | Button text                         |
/// | [onTap]   | required             | Tap callback (null = disabled)      |
/// | [variant] | [ChunkyButtonVariant.primary] | Colour variant          |
/// | [edge]    | `4`                  | Bottom-shadow height in logical px  |
/// | [icon]    | `null`               | Optional leading icon widget        |
///
/// ### Example
/// ```dart
/// ChunkyButton(
///   label: 'Ambil Makanan',
///   onTap: () => _handleTap(),
///   variant: ChunkyButtonVariant.primary,
///   icon: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
/// )
/// ```
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = ChunkyButtonVariant.primary,
    this.edge = 4,
    this.icon,
    this.height = 48,
    this.borderRadius = AppRadius.r12,
    this.fillColor,
    this.shadowColor,
    this.textColor,
    this.letterSpacing,
  });

  final String label;
  final VoidCallback? onTap;
  final ChunkyButtonVariant variant;
  final double edge;
  final Widget? icon;
  final double height;
  final double borderRadius;
  final Color? fillColor;
  final Color? shadowColor;
  final Color? textColor;
  final double? letterSpacing;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _pressed = false;

  // ── colour helpers ────────────────────────────────────────────────────────

  Color get _fill {
    if (widget.onTap == null) return AppColors.slate;
    if (widget.fillColor != null) return widget.fillColor!;
    return switch (widget.variant) {
      ChunkyButtonVariant.primary => AppColors.primary,
      ChunkyButtonVariant.danger  => AppColors.danger,
      ChunkyButtonVariant.neutral => AppColors.neutralButton,
    };
  }

  Color get _shadowColor {
    if (widget.onTap == null) return AppColors.textSecondary;
    if (widget.shadowColor != null) return widget.shadowColor!;
    return switch (widget.variant) {
      ChunkyButtonVariant.primary => AppColors.primaryDark,
      ChunkyButtonVariant.danger  => AppColors.dangerDark,
      ChunkyButtonVariant.neutral => AppColors.border,
    };
  }

  Color get _labelColor {
    if (widget.textColor != null) return widget.textColor!;
    return switch (widget.variant) {
      ChunkyButtonVariant.neutral => AppColors.textPrimary,
      _                           => AppColors.surface,
    };
  }

  // ── gesture handlers ─────────────────────────────────────────────────────

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _)     => setState(() => _pressed = false);
  void _onTapCancel()               => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final double yOffset = _pressed ? widget.edge : 0;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        // Reserve vertical space for the shadow so nothing shifts in layout.
        margin: EdgeInsets.only(bottom: widget.edge),
        transform: Matrix4.translationValues(0, yOffset, 0),
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _fill,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _pressed
              ? const []
              : [
                  BoxShadow(
                    color: _shadowColor,
                    blurRadius: 0,
                    offset: Offset(0, widget.edge),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: AppTextStyles.button.copyWith(
                color: _labelColor,
                letterSpacing: widget.letterSpacing ?? AppTextStyles.button.letterSpacing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
