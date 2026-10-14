import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'routes/app_routes.dart';

void main() => runApp(const BagiRasaApp());

class BagiRasaApp extends StatelessWidget {
  const BagiRasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BagiRasa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D5A3D)),
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
