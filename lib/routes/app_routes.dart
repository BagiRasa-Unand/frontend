import 'package:flutter/material.dart';
import '../models/item.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/not_found_screen.dart';

/// Konstanta nama route dan generator route terpusat.
/// Semua navigasi di app menggunakan konstanta class ini.
class AppRoutes {
  // Konstruktor private – class ini tidak perlu di-instansiasi
  AppRoutes._();

  // ── Konstanta Nama Route ──────────────────────────────────────────────────
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';

  // ── Generator Route (onGenerateRoute) ─────────────────────────────────────
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case detail:
        // Periksa tipe argument sebelum diteruskan ke DetailScreen
        final args = settings.arguments;
        if (args is Item) {
          return MaterialPageRoute<void>(
            builder: (_) => DetailScreen(item: args),
            settings: settings,
          );
        }
        // Argument tidak valid -> langsung tampilkan 404 (bukan return null)
        return MaterialPageRoute<void>(
          builder: (_) => NotFoundScreen(
            routeName: settings.name,
            message: 'Data item tidak ditemukan atau tidak valid.',
          ),
          settings: settings,
        );

      case catatanForm:
        // <String> karena layar ini mengembalikan teks saat ditutup
        return MaterialPageRoute<String>(
          builder: (_) => const CatatanFormScreen(),
          settings: settings,
        );

      default:
        // Route tidak terdaftar -> langsung tampilkan 404 (lebih andal di Flutter Web)
        return MaterialPageRoute<void>(
          builder: (_) => NotFoundScreen(routeName: settings.name),
          settings: settings,
        );
    }
  }

  // ── Fallback untuk Route Tidak Dikenal (onUnknownRoute) ──────────────────
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }
}
