import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
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
      title: 'BagiRasa - Penyaluran Makanan Surplus Kampus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 45, 90, 61),
          primary: const Color.fromARGB(255, 203, 53, 173),
          surface: AppColors.backgroundWarm,
        ),
        scaffoldBackgroundColor: AppColors.backgroundWarm,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.listingList,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
