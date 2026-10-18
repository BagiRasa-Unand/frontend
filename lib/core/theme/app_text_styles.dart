import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Design-token text styles for BagiRasa.
///
/// All styles use **Nunito Sans** via the google_fonts package.
abstract class AppTextStyles {
  /// Modal title — ExtraBold 20/28
  static TextStyle get modalTitle => GoogleFonts.nunitoSans(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  /// Heading — Bold 18/24
  static TextStyle get heading => GoogleFonts.nunitoSans(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// Body — Regular 14/23
  static TextStyle get body => GoogleFonts.nunitoSans(
        fontSize: 14,
        height: 23 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  /// Caption — Regular 12/16
  static TextStyle get caption => GoogleFonts.nunitoSans(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  /// Badge — Bold 11/14, letterSpacing 0.22
  static TextStyle get badge => GoogleFonts.nunitoSans(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.22,
        color: AppColors.textPrimary,
      );

  /// Button — ExtraBold 14/20, letterSpacing 0.28
  static TextStyle get button => GoogleFonts.nunitoSans(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.28,
        color: AppColors.surface,
      );

  /// Overline — Bold 11/11, letterSpacing 0.55, uppercase
  static TextStyle get overline => GoogleFonts.nunitoSans(
        fontSize: 11,
        height: 11 / 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.55,
        color: AppColors.textSecondary,
      ).copyWith(
        // Uppercase is applied via TextCapitalization / AllCaps widget at call
        // site; the style itself is kept pure so callers can choose to apply it.
      );

  /// Warning callout text — Bold 14/19
  static TextStyle get warningCallout => GoogleFonts.nunitoSans(
        fontSize: 14,
        height: 19 / 14,
        fontWeight: FontWeight.w700,
        color: AppColors.warningText,
      );

  /// Highlight pill text — Bold 14/20
  static TextStyle get highlightPill => GoogleFonts.nunitoSans(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w700,
        color: AppColors.brownDark,
      );

  /// Filter chip text — Bold 12/16
  static TextStyle get chip => GoogleFonts.nunitoSans(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// Marker pin badge — ExtraBold 10/15, letterSpacing 0.5
  static TextStyle get pinBadge => GoogleFonts.nunitoSans(
        fontSize: 10,
        height: 15 / 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      );

  /// Card photo badge — Black 9/14
  static TextStyle get photoTag => GoogleFonts.nunitoSans(
        fontSize: 9,
        height: 14 / 9,
        fontWeight: FontWeight.w900,
      );

  /// Card title — Bold 14/18
  static TextStyle get cardTitle => GoogleFonts.nunitoSans(
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  /// Card subtitle — Regular 12/16
  static TextStyle get cardSubtitle => GoogleFonts.nunitoSans(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  /// Mini button / action — Bold 11/14, letterSpacing 0.22
  static TextStyle get miniButton => GoogleFonts.nunitoSans(
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.22,
        color: AppColors.surface,
      );

  /// Countdown digital timer — ExtraBold 44/55, letterSpacing -1.1
  static TextStyle get countdownTimer => GoogleFonts.nunitoSans(
        fontSize: 44,
        height: 55 / 44,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
      );

  /// Voucher pass code — ExtraBold 20/28, letterSpacing 1.0
  static TextStyle get voucherCode => GoogleFonts.nunitoSans(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: AppColors.primaryDeep,
      );

  /// Subtitle uppercase tracking — Regular 14/20, letterSpacing 1.6, uppercase
  static TextStyle get timerSubtitle => GoogleFonts.nunitoSans(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: AppColors.textSecondary,
      );

  /// Stepper number display — ExtraBold 32/32
  static TextStyle get stepperNumber => GoogleFonts.nunitoSans(
        fontSize: 32,
        height: 1.0,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );
}

