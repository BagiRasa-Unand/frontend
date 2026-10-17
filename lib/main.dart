import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes/app_routes.dart';
import 'theme/app_colors.dart';

void main() {
  usePathUrlStrategy();
  runApp(const BagiRasaApp());
}

class BagiRasaApp extends StatelessWidget {
  const BagiRasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BagiRasa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.accentGold,
        ),
        textTheme: GoogleFonts.nunitoSansTextTheme(),
        useMaterial3: true,
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      initialRoute: AppRoutes.pickupPointList,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
