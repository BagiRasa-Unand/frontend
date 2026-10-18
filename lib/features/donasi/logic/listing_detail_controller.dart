import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../features/lokasi/data/pickup_point.dart';
import '../../../features/lokasi/data/pickup_point_repository.dart';
import '../data/food_listing.dart';
import '../data/food_listing_repository.dart';

class ListingDetailController extends ChangeNotifier {
  ListingDetailController({
    required this.listingId,
    required this.listingRepository,
    required this.pickupPointRepository,
  }) {
    listingRepository.addListener(_onRepositoryChanged);
    pickupPointRepository.addListener(_onRepositoryChanged);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  final String listingId;
  final FoodListingRepository listingRepository;
  final PickupPointRepository pickupPointRepository;

  Timer? _timer;
  DateTime _now = DateTime.now();

  DateTime get now => _now;
  FoodListing? get listing => listingRepository.getById(listingId);
  PickupPoint? get pickupPoint {
    final current = listing;
    return current == null
        ? null
        : pickupPointRepository.getById(current.pickupPointId);
  }

  void _onRepositoryChanged() => notifyListeners();

  @override
  void dispose() {
    _timer?.cancel();
    listingRepository.removeListener(_onRepositoryChanged);
    pickupPointRepository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}