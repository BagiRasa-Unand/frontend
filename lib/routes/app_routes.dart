import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../screens/listing_list_screen.dart';
import '../screens/listing_detail_screen.dart';

abstract class AppRoutes {
  static const String listingList = '/listing-list';
  static const String listingDetail = '/listing-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case listingList:
        return MaterialPageRoute(
          settings: const RouteSettings(name: listingList),
          builder: (_) => const PopScope(
            canPop: false,
            child: ListingListScreen(),
          ),
        );
      case listingDetail:
        // Cek tipe arguments agar tidak crash jika dikirim sembarangan.
        if (settings.arguments is Listing) {
          return MaterialPageRoute<String>(
            settings: settings,
            builder: (_) => ListingDetailScreen(
              listing: settings.arguments as Listing,
            ),
          );
        }
        // Argumen tidak valid.
        return _notFoundRoute(settings);
      default:
        return _notFoundRoute(settings);
    }
  }

  static Route<dynamic> _notFoundRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('404 - Tidak Ditemukan')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                '404',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Halaman tidak ditemukan',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
