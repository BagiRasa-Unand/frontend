import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Reusable Glass Pill dengan Backdrop Filter & Border Transparan
class GlassPill extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GlassPill({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
    this.borderRadius = AppSpacing.radiusPill,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
