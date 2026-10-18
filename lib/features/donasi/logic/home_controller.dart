import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../features/lokasi/data/pickup_point_repository.dart';
import '../data/food_listing.dart';
import '../data/food_listing_repository.dart';

enum TimeFilter { semua, kurangDariSatuJam, satuSampaiTigaJam, lebihDariTigaJam }

class HomeController extends ChangeNotifier {
  HomeController(this.listingRepository, this.pickupPointRepository) {
    listingRepository.addListener(_onRepositoryChanged);
    pickupPointRepository.addListener(_onRepositoryChanged);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _refreshNow());
  }

  final FoodListingRepository listingRepository;
  final PickupPointRepository pickupPointRepository;

  Timer? _timer;
  DateTime _now = DateTime.now();
  Duration _demoOffset = Duration.zero;
  String _searchQuery = '';
  FoodType? _foodType;
  TimeFilter _timeFilter = TimeFilter.semua;
  String? _pickupPointId;

  DateTime get now => _now;
  String get searchQuery => _searchQuery;
  FoodType? get foodType => _foodType;
  TimeFilter get timeFilter => _timeFilter;
  String? get pickupPointId => _pickupPointId;

  List<FoodListing> get visibleListings {
    final query = _searchQuery.trim().toLowerCase();
    final results = listingRepository.getAll().where((listing) {
      final matchesSearch = query.isEmpty || listing.name.toLowerCase().contains(query);
      final matchesType = _foodType == null || listing.foodType == _foodType;
      final matchesLocation =
          _pickupPointId == null || listing.pickupPointId == _pickupPointId;
      final matchesTime = _matchesTimeFilter(listing.timeLeftAt(_now));
      return matchesSearch && matchesType && matchesLocation && matchesTime;
    }).toList();

    results.sort((a, b) {
      final aStatus = a.statusAt(_now);
      final bStatus = b.statusAt(_now);
      final aInactive = _isInactive(aStatus);
      final bInactive = _isInactive(bStatus);
      if (aInactive != bInactive) return aInactive ? 1 : -1;
      return a.expiresAt.compareTo(b.expiresAt);
    });
    return results;
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void toggleFoodType(FoodType type) {
    _foodType = _foodType == type ? null : type;
    notifyListeners();
  }

  void clearFoodType() {
    _foodType = null;
    notifyListeners();
  }

  void setTimeFilter(TimeFilter value) {
    _timeFilter = value;
    notifyListeners();
  }

  void setPickupPoint(String? id) {
    _pickupPointId = id;
    notifyListeners();
  }

  void fastForwardDemo() {
    _demoOffset += const Duration(minutes: 30);
    _refreshNow();
  }

  void _refreshNow() {
    _now = DateTime.now().add(_demoOffset);
    notifyListeners();
  }

  void _onRepositoryChanged() => notifyListeners();

  bool _matchesTimeFilter(Duration remaining) {
    switch (_timeFilter) {
      case TimeFilter.semua:
        return true;
      case TimeFilter.kurangDariSatuJam:
        return remaining < const Duration(hours: 1);
      case TimeFilter.satuSampaiTigaJam:
        return remaining >= const Duration(hours: 1) &&
            remaining <= const Duration(hours: 3);
      case TimeFilter.lebihDariTigaJam:
        return remaining > const Duration(hours: 3);
    }
  }

  bool _isInactive(ListingStatus status) {
    return status == ListingStatus.habisDiklaim ||
        status == ListingStatus.kadaluarsa;
  }

  @override
  void dispose() {
    _timer?.cancel();
    listingRepository.removeListener(_onRepositoryChanged);
    pickupPointRepository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}