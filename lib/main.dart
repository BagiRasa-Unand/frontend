import 'package:flutter/material.dart';
import 'screens/splash_onboarding_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const BagiRasaApp());
}

class BagiRasaApp extends StatelessWidget {
  const BagiRasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BagiRasa - Penyaluran Makanan Surplus Kampus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          surface: AppColors.backgroundWarm,
        ),
        scaffoldBackgroundColor: AppColors.backgroundWarm,
        useMaterial3: true,
      ),
      home: const SplashOnboardingScreen(),
    );
  }
}
