import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Builds the single light [ThemeData] for BagiRasa.
///
/// Key decisions:
/// - Background = [AppColors.background] (#FFF8F0).
/// - Uses Material 3 with **no** elevation tint/shadow on cards, etc.
/// - Base text theme wired to Nunito Sans.
abstract class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.surface,
        primaryContainer: AppColors.primarySoft,
        onPrimaryContainer: AppColors.primaryDeep,
        secondary: AppColors.teal,
        onSecondary: AppColors.surface,
        secondaryContainer: AppColors.tealDeep,
        onSecondaryContainer: AppColors.surface,
        tertiary: AppColors.indigo,
        onTertiary: AppColors.surface,
        tertiaryContainer: AppColors.indigo,
        onTertiaryContainer: AppColors.surface,
        error: AppColors.danger,
        onError: AppColors.surface,
        errorContainer: AppColors.danger,
        onErrorContainer: AppColors.surface,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
        outlineVariant: AppColors.border,
        shadow: Colors.transparent,
        scrim: AppColors.overlay,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.surface,
        inversePrimary: AppColors.primarySoft,
      ),
      scaffoldBackgroundColor: AppColors.background,
      // ── Typography ────────────────────────────────────────────────────────
      textTheme: GoogleFonts.nunitoSansTextTheme(),
      // ── No elevation shadows on cards / app bars ──────────────────────────
      cardTheme: const CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.nunitoSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 0,
      ),
      // Disable global elevation on ElevatedButton; use ChunkyButton instead.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(elevation: 0),
      ),
    );

    return base;
  }
}
