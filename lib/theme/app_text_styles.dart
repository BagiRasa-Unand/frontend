import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Token Tipografi aplikasi BagiRasa berdasarkan font Literata & Nunito Sans dari Figma.
abstract class AppTextStyles {
  // Brand Header
  static TextStyle get brandTitle => GoogleFonts.literata(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.4,
      );

  static TextStyle get brandSubtitle => GoogleFonts.nunitoSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      );

  static TextStyle get badgeGreen => GoogleFonts.nunitoSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.badgeGreenText,
        letterSpacing: 0.55,
      );

  // Hero Narrative Section
  static TextStyle get heroHeading => GoogleFonts.literata(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 32 / 26,
        color: AppColors.textPrimary,
        letterSpacing: -0.65,
      );

  static TextStyle get heroSubheading => GoogleFonts.nunitoSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 23 / 14,
        color: AppColors.textSecondary,
      );

  // Metric Strip Tokens
  static TextStyle get metricValue => GoogleFonts.nunitoSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get metricLabel => GoogleFonts.nunitoSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  // Feature Highlights Tokens
  static TextStyle get featureTitle => GoogleFonts.nunitoSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.35,
      );

  static TextStyle get featureDesc => GoogleFonts.nunitoSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 20 / 12,
        color: AppColors.textSecondary,
      );

  static TextStyle get featureTagGreen => GoogleFonts.nunitoSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryGreen,
        letterSpacing: 0.5,
      );

  static TextStyle get featureTagGold => GoogleFonts.nunitoSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.accentGold,
        letterSpacing: 0.5,
      );

  static TextStyle get featureTagMuted => GoogleFonts.nunitoSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      );

  // Buttons
  static TextStyle get buttonPrimary => GoogleFonts.nunitoSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get buttonSecondary => GoogleFonts.nunitoSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // Glass Pills / Hero Capsule
  static TextStyle get liveStatusPill => GoogleFonts.nunitoSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.95),
        letterSpacing: 0.275,
      );

  static TextStyle get sdgPill => GoogleFonts.nunitoSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  // Footer
  static TextStyle get footerText => GoogleFonts.nunitoSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.275,
      );

  static TextStyle get footerSubtext => GoogleFonts.nunitoSans(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
      );
}
