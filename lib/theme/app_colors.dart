import 'package:flutter/material.dart';

/// Design Token untuk warna aplikasi BagiRasa berdasarkan spesifikasi Figma.
abstract class AppColors {
  // Primary Palette
  static const Color primaryGreen = Color(0xFF2D5A3D);
  static const Color primaryGreenDark = Color(0xFF1E3F2A);
  static const Color primaryGreenLight = Color(0xFFC8E8D0);
  
  // Background & Surfaces
  static const Color backgroundWarm = Color(0xFFFAF9F6);
  static const Color cardBgWarm = Color(0xFFF6F3ED);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  
  // Typography Colors
  static const Color textPrimary = Color(0xFF2E3230);
  static const Color textSecondary = Color(0xFF5A605B);
  static const Color textMuted = Color(0xFF74796E);
  
  // Accent & Secondary Colors
  static const Color accentGold = Color(0xFF705C30);
  static const Color accentGoldBg = Color.fromRGBO(248, 224, 168, 0.6);
  static const Color badgeGreenBg = Color.fromRGBO(200, 232, 208, 0.5);
  static const Color badgeGreenText = Color(0xFF2D5A3D);
  
  // Status Colors
  static const Color statusLiveGreen = Color(0xFF34D399);
  
  // Borders & Shadows
  static const Color borderLight = Color.fromRGBO(0, 0, 0, 0.04);
  static const Color shadowColor = Color.fromRGBO(46, 50, 48, 0.05);
}
