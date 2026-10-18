import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/app_session.dart';
import '../data/food_listing.dart';
import '../data/food_listing_repository.dart';

enum DonationHistoryFilter { semua, tersedia, habisDiklaim, kadaluarsa }

class DonationHistoryController extends ChangeNotifier {
  DonationHistoryController(this.repository) {
    repository.addListener(_onRepositoryChanged);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _now = DateTime.now();
      notifyListeners();
    });
  }

  final FoodListingRepository repository;

  Timer? _timer;
  DateTime _now = DateTime.now();
  DonationHistoryFilter _filter = DonationHistoryFilter.semua;

  DateTime get now => _now;
  DonationHistoryFilter get filter => _filter;
  DonorStats get stats => repository.statsFor(kCurrentUserId);

  List<FoodListing> get listings {
    final items = repository.getByDonor(kCurrentUserId).where((listing) {
      final status = listing.statusAt(_now);
      return switch (_filter) {
        DonationHistoryFilter.semua => true,
        DonationHistoryFilter.tersedia =>
          status == ListingStatus.tersedia || status == ListingStatus.segeraHabis,
        DonationHistoryFilter.habisDiklaim => status == ListingStatus.habisDiklaim,
        DonationHistoryFilter.kadaluarsa => status == ListingStatus.kadaluarsa,
      };
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  int countFor(DonationHistoryFilter value) {
    return repository.getByDonor(kCurrentUserId).where((listing) {
      final status = listing.statusAt(_now);
      return switch (value) {
        DonationHistoryFilter.semua => true,
        DonationHistoryFilter.tersedia =>
          status == ListingStatus.tersedia || status == ListingStatus.segeraHabis,
        DonationHistoryFilter.habisDiklaim => status == ListingStatus.habisDiklaim,
        DonationHistoryFilter.kadaluarsa => status == ListingStatus.kadaluarsa,
      };
    }).length;
  }

  void setFilter(DonationHistoryFilter value) {
    _filter = value;
    notifyListeners();
  }

  void _onRepositoryChanged() => notifyListeners();

  @override
  void dispose() {
    _timer?.cancel();
    repository.removeListener(_onRepositoryChanged);
    super.dispose();
  }
}