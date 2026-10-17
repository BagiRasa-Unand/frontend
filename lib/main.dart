import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell.dart';
import 'features/lokasi/data/pickup_point_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait – BagiRasa is portrait-only (390 × 844 baseline).
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const BagiRasaApp());
}

class BagiRasaApp extends StatelessWidget {
  const BagiRasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Singleton repository shared across the whole app.
        ChangeNotifierProvider(create: (_) => PickupPointRepository()),
      ],
      child: MaterialApp(
        title: 'BagiRasa - Penyaluran Makanan Surplus Kampus',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const MainShell(),
      ),
    );
  }
}
