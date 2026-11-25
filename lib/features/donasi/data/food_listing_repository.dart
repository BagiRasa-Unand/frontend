import 'package:flutter/foundation.dart';

import '../../../core/app_session.dart';
import 'donation_api_service.dart';
import 'food_listing.dart';

class FoodListingRepository extends ChangeNotifier {
  FoodListingRepository({DonationApiService? apiService})
      : _apiService = apiService ?? DonationApiService(),
        _items = _seed(DateTime.now()) {
    // Sinkronisasi data awal langsung dari PostgreSQL backend
    fetchFromApi();
  }

  final DonationApiService _apiService;
  List<FoodListing> _items;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Memuat daftar donasi makanan riil dari PostgreSQL backend
  Future<void> fetchFromApi({String? search, String? categoryId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final backendList = await _apiService.getDonations(
        search: search,
        categoryId: categoryId,
      );

      if (backendList != null) {
        _items = backendList;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[FoodListingRepository] Fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<FoodListing> getAll() => List.unmodifiable(_items);

  FoodListing? getById(String id) {
    for (final listing in _items) {
      if (listing.id == id) return listing;
    }
    return null;
  }

  List<FoodListing> getByDonor(String donorId) => List.unmodifiable(
        _items.where((listing) => listing.donorId == donorId),
      );

  void add(FoodListing listing) {
    _items.insert(0, listing);
    notifyListeners();

    _syncAdd(listing);
  }

  Future<void> _syncAdd(FoodListing listing) async {
    try {
      final created = await _apiService.createDonation(
        listing,
        imagePath: listing.photoPath,
      );
      if (created != null) {
        final idx = _items.indexWhere((item) => item.id == listing.id);
        if (idx != -1) {
          _items[idx] = created;
          notifyListeners();
        }
      } else {
        // Rollback jika server backend menolak agar UI tidak menampilkan data palsu
        _items.removeWhere((item) => item.id == listing.id);
        notifyListeners();
        debugPrint('⚠️ [FoodListingRepository] Donasi ditolak backend, rollback data lokal.');
      }
    } catch (e) {
      _items.removeWhere((item) => item.id == listing.id);
      notifyListeners();
      debugPrint('[FoodListingRepository] Sync add error: $e');
    }
  }

  void update(FoodListing listing) {
    final index = _items.indexWhere((item) => item.id == listing.id);
    if (index == -1) return;
    _items[index] = listing;
    notifyListeners();

    _syncUpdate(listing);
  }

  Future<void> _syncUpdate(FoodListing listing) async {
    try {
      await _apiService.updateDonation(listing);
    } catch (e) {
      debugPrint('[FoodListingRepository] Sync update error: $e');
    }
  }

  bool delete(String id) {
    final listing = getById(id);
    if (listing == null || listing.claimedQuantity > 0) return false;
    _items.remove(listing);
    notifyListeners();

    _syncDelete(id);
    return true;
  }

  Future<void> _syncDelete(String id) async {
    try {
      await _apiService.cancelDonation(id);
    } catch (e) {
      debugPrint('[FoodListingRepository] Sync delete error: $e');
    }
  }

  bool decreaseStock(String id, int qty) {
    final listing = getById(id);
    if (listing == null || qty <= 0 || qty > listing.quantityRemaining) {
      return false;
    }
    update(listing.copyWith(quantityRemaining: listing.quantityRemaining - qty));
    return true;
  }

  DonorStats statsFor(String donorId) {
    final listings = getByDonor(donorId);
    return DonorStats(
      totalSaved: listings.fold(0, (sum, listing) => sum + listing.claimedQuantity),
      totalListings: listings.length,
      expiredCount: listings
          .where((listing) => listing.statusAt(DateTime.now()) == ListingStatus.kadaluarsa)
          .length,
    );
  }

  static List<FoodListing> _seed(DateTime now) {
    return [
      FoodListing(
        id: 'food-001', donorId: kCurrentUserId, donorName: 'Budi Santoso',
        name: 'Nasi Ayam Bakar Rempah', foodType: FoodType.makananBerat,
        description: 'Nasi ayam dengan sambal dan lalapan.', quantityTotal: 10,
        quantityRemaining: 10, pickupPointId: 'b0000000-0000-0000-0000-000000000001',
        createdAt: now.subtract(const Duration(minutes: 10)),
        expiresAt: now.add(const Duration(minutes: 25)),
      ),
      FoodListing(
        id: 'food-002', donorId: kCurrentUserId, donorName: 'Budi Santoso',
        name: 'Paket Pastel & Lemper Ceria', foodType: FoodType.camilan,
        description: 'Aneka camilan untuk teman belajar.', quantityTotal: 10,
        quantityRemaining: 1, pickupPointId: 'b0000000-0000-0000-0000-000000000002',
        createdAt: now.subtract(const Duration(hours: 1)),
        expiresAt: now.add(const Duration(minutes: 15)),
      ),
      FoodListing(
        id: 'food-003', donorId: kCurrentUserId, donorName: 'Budi Santoso',
        name: 'Nasi Kotak Ayam Sambal Ijo', foodType: FoodType.makananBerat,
        description: 'Nasi kotak siap santap.', quantityTotal: 8,
        quantityRemaining: 0, pickupPointId: 'b0000000-0000-0000-0000-000000000003',
        createdAt: now.subtract(const Duration(hours: 2)),
        expiresAt: now.add(const Duration(hours: 1)),
      ),
    ];
  }
}
