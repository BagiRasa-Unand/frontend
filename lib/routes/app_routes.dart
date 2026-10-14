import 'package:flutter/material.dart';
import '../screens/pickup_point_list_screen.dart';
import '../screens/edit_pickup_point_screen.dart';
import '../models/pickup_point.dart';

class AppRoutes {
  static const String pickupPointList = '/';
  static const String editPickupPoint = '/edit-pickup-point';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case pickupPointList:
        return MaterialPageRoute(builder: (_) => const PickupPointListScreen());

      case editPickupPoint:
        // Cegah crash jika arguments bukan PickupPoint
        if (settings.arguments is! PickupPoint) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Data titik tidak ditemukan.')),
            ),
          );
        }
        return MaterialPageRoute<PickupPoint>(
          builder: (_) => EditPickupPointScreen(
            point: settings.arguments as PickupPoint,
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan.')),
          ),
        );
    }
  }
}
