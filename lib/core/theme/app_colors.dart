import 'package:flutter/material.dart';

/// Design tokens – colour palette for BagiRasa (spec v2).
abstract class AppColors {
  // ── Primary (orange) ──────────────────────────────────────────────────────
  static const Color primary     = Color(0xFFF46A1F);
  static const Color primaryDark = Color(0xFFC94D0C);
  static const Color primaryDeep = Color(0xFFA33E00);
  static const Color primarySoft = Color(0xFFFFE9DB);

  // ── Teal ──────────────────────────────────────────────────────────────────
  static const Color teal     = Color(0xFF12A8A0);
  static const Color tealDark = Color(0xFF0B817B);
  static const Color tealDeep = Color(0xFF006A65);

  // ── Indigo ────────────────────────────────────────────────────────────────
  static const Color indigo     = Color(0xFF5B6CFF);
  static const Color indigoDark = Color(0xFF4152E0);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color amber  = Color(0xFFFFAE1A);
  static const Color reward = Color(0xFFFFD23F);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color danger     = Color(0xFFE5484D);
  static const Color dangerDark = Color(0xFFB93338);

  // ── Neutral ───────────────────────────────────────────────────────────────
  static const Color slate = Color(0xFF8A94A6);

  // ── Backgrounds & surfaces ────────────────────────────────────────────────
  static const Color background = Color(0xFFFFF8F0);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color border     = Color(0xFFEADFD3);

  // ── Typography ───────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1F1B17);
  static const Color textSecondary = Color(0xFF7A6F66);

  // ── Utility ───────────────────────────────────────────────────────────────
  static const Color neutralButton  = Color(0xFFF4EFEB);
  static const Color warningSoft    = Color(0xFFFFF4DC);
  static const Color warningBorder  = Color(0xFFF0D8A8);
  static const Color warningText    = Color(0xFF6B4B00);
  static const Color overlay        = Color(0x801F1B17); // rgba(31,27,23,0.5)

  // ── Extra tokens added for pickup-point screen & form ─────────────────────
  static const Color indigoSoft       = Color(0xFFDFE0FF); // edit btn bg / gps btn shadow
  static const Color indigoSoftShadow = Color(0xFFBDC2FF); // edit btn shadow
  static const Color dangerSoft       = Color(0xFFFFDAD6); // delete btn bg
  static const Color dangerSoftShadow = Color(0xFFFFB4AB); // delete btn shadow
  static const Color slateShadow      = Color(0xFF596375); // tutup badge shadow
  static const Color primarySoftShadow = Color(0xFFFFB596); // active listing pill shadow
  static const Color toggleInactive   = Color(0xFFE2D8D2); // inactive toggle bg
  static const Color surfaceWarm      = Color(0xFFF6ECE5); // inactive listing pill bg / map bg
  static const Color brownDeep        = Color(0xFF521C00); // mascot tip text
  static const Color brownMid         = Color(0xFF594238); // mascot subtitle
  static const Color error            = Color(0xFFBA1A1A); // required asterisk & error border
  static const Color primarySoftDeep  = Color(0xFFE1C0B2); // badge & mascot icon shadow
  static const Color verifiedBadge    = Color(0x807CF6ED); // verified badge pill bg
  static const Color gpsIndigo        = Color(0xFF3A4BDF); // gps button text & icon
  static const Color pinShadow        = Color(0x4D1F1B17); // pin shadow under marker

  // ── Extra tokens for delete bottom sheet ──────────────────────────────────
  static const Color brownDark   = Color(0xFF360F00); // highlight pill text
  static const Color sheetShadow = Color(0x381F1B17); // modal sheet ambient shadow (rgba(31,27,23,0.22))
  static const Color ambientGlow = Color(0x66FFDAD6); // rasi ambient glow disk (rgba(255,218,214,0.4))

  // ── Extra tokens for Peta Utama (Module C) ─────────────────────────────────
  static const Color tealSoft     = Color(0xFFE0F5F3); // teal pill / rescue badge bg
  static const Color amberDark    = Color(0xFFC98506); // urgent marker shadow / text
  static const Color amberSoft    = Color(0xFFFFF6E5); // urgent badge soft background
  static const Color handle       = Color(0xFFD1C7BC); // sheet drag handle
  static const Color gpsHaloInner = Color(0x4D5B6CFF); // outer wave 2 (30% alpha)
  static const Color gpsHaloOuter = Color(0x335B6CFF); // outer wave 1 (20% alpha)

  // ── Extra tokens for Countdown & Pengingat (Module C) ──────────────────────
  static const Color creamSoft       = Color(0xFFFCF2EB); // microcopy / voucher / reminder item bg
  static const Color bannerShadow    = Color(0xFFFFDBCD); // gamified info banner shadow
  static const Color pillNeutral     = Color(0xFFF0E6E0); // demo badge / tab chip bg
  static const Color warningTextDark = Color(0xFF352F2B); // dark text for warning pill

  // ── Extra tokens for Form Klaim (Module B) ─────────────────────────────────
  static const Color amberBorder   = Color(0xFFFFE082); // callout 3D shadow for amber
  static const Color amberSoftBg   = Color(0x26FFAE1A); // rgba(255, 174, 26, 0.15)
  static const Color cyanBadge     = Color(0xFF79F3EA); // remaining stock badge bg
  static const Color cyanBadgeText = Color(0xFF006F69); // remaining stock badge text
  static const Color rescueBadgeBg   = Color(0x807CF6ED); // BagiRasa Rescue badge pill
  static const Color dragHandle      = Color(0xFFEBE1DA); // bottom sheet drag handle
  static const Color amberDarkShadow = Color(0xFFC98200); // 3D shadow for amber status badges
  static const Color tealDarkText    = Color(0xFF00504C); // text for distance pill
}

