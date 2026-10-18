import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_session.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell.dart';
import 'features/donasi/data/food_listing_repository.dart';
import 'features/klaim/data/claim_repository.dart';
import 'features/klaim/logic/claim_notification_mapper.dart';
import 'features/lokasi/data/pickup_point_repository.dart';
import 'features/notifikasi/data/notification_repository.dart';

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
        ChangeNotifierProvider(create: (_) => FoodListingRepository()),
        ChangeNotifierProvider(create: (_) => NotificationRepository()),
        ChangeNotifierProvider(
          create: (context) {
            final repo = ClaimRepository(
              foodRepo: context.read<FoodListingRepository>(),
            );
            final notifRepo = context.read<NotificationRepository>();
            final pickupRepo = context.read<PickupPointRepository>();
            repo.onEvent = (event) {
              final notif = mapClaimEventToNotification(
                event,
                foodRepo: repo.foodRepo,
                pickupRepo: pickupRepo,
              );
              if (notif != null) {
                notifRepo.add(notif);
              }
            };
            repo.startTicker();
            if (kShowDemoControls) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                repo.seedDemoData();
              });
            }
            return repo;
          },
        ),
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
