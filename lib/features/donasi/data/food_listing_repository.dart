import 'package:flutter/foundation.dart';

import '../../../core/app_session.dart';
import 'food_listing.dart';

class FoodListingRepository extends ChangeNotifier {
  FoodListingRepository() : _items = _seed(DateTime.now());

  final List<FoodListing> _items;

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
    _items.add(listing);
    notifyListeners();
  }

  void update(FoodListing listing) {
    final index = _items.indexWhere((item) => item.id == listing.id);
    if (index == -1) return;
    _items[index] = listing;
    notifyListeners();
  }

  bool delete(String id) {
    final listing = getById(id);
    if (listing == null || listing.claimedQuantity > 0) return false;
    _items.remove(listing);
    notifyListeners();
    return true;
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
        quantityRemaining: 10, pickupPointId: 'pp-001',
        createdAt: now.subtract(const Duration(minutes: 10)),
        expiresAt: now.add(const Duration(minutes: 25)),
      ),
      FoodListing(
        id: 'food-002', donorId: kCurrentUserId, donorName: 'Budi Santoso',
        name: 'Paket Pastel & Lemper Ceria', foodType: FoodType.camilan,
        description: 'Aneka camilan untuk teman belajar.', quantityTotal: 10,
        quantityRemaining: 1, pickupPointId: 'pp-002',
        createdAt: now.subtract(const Duration(hours: 1)),
        expiresAt: now.add(const Duration(minutes: 15)),
      ),
      FoodListing(
        id: 'food-003', donorId: kCurrentUserId, donorName: 'Budi Santoso',
        name: 'Nasi Kotak Ayam Sambal Ijo', foodType: FoodType.makananBerat,
        description: 'Nasi kotak siap santap.', quantityTotal: 8,
        quantityRemaining: 0, pickupPointId: 'pp-006',
        createdAt: now.subtract(const Duration(hours: 2)),
        expiresAt: now.add(const Duration(hours: 1)),
      ),
      FoodListing(
        id: 'food-004', donorId: 'donor-campus-1', donorName: 'Siti Rahma',
        name: 'Teh Manis Dingin', foodType: FoodType.minuman,
        description: 'Minuman segar dalam botol.', quantityTotal: 12,
        quantityRemaining: 12, pickupPointId: 'pp-003',
        createdAt: now.subtract(const Duration(hours: 3)),
        expiresAt: now.subtract(const Duration(minutes: 10)),
      ),
      FoodListing(
        id: 'food-005', donorId: 'donor-campus-2', donorName: 'Dina Putri',
        name: 'Roti Isi Cokelat', foodType: FoodType.camilan,
        description: 'Roti lembut dengan isian cokelat.', quantityTotal: 6,
        quantityRemaining: 6, pickupPointId: 'pp-004',
        createdAt: now.subtract(const Duration(minutes: 30)),
        expiresAt: now.add(const Duration(hours: 4)),
      ),
      FoodListing(
        id: 'food-006', donorId: 'donor-campus-1', donorName: 'Siti Rahma',
        name: 'Buah Potong Segar', foodType: FoodType.lainnya,
        description: 'Potongan buah segar harian.', quantityTotal: 5,
        quantityRemaining: 5, pickupPointId: 'pp-005',
        createdAt: now.subtract(const Duration(minutes: 20)),
        expiresAt: now.add(const Duration(hours: 2)),
      ),
      FoodListing(
        id: 'food-007', donorId: 'donor-campus-3', donorName: 'Uni Evi (Kantin Barokah)',
        name: 'Nasi Padang Ayam Gulai', foodType: FoodType.makananBerat,
        description: 'Nasi padang hangat lengkap dengan gulai ayam dan daun singkong.',
        quantityTotal: 8, quantityRemaining: 8, pickupPointId: 'pp-001',
        createdAt: now.subtract(const Duration(minutes: 15)),
        expiresAt: now.add(const Duration(hours: 3)),
      ),
      FoodListing(
        id: 'food-008', donorId: 'donor-campus-4', donorName: 'Pak Wahyu (Kedai Camilan)',
        name: 'Pisang Goreng Keju & Risoles', foodType: FoodType.camilan,
        description: 'Paket camilan sore masih hangat, renyah dan higienis.',
        quantityTotal: 5, quantityRemaining: 5, pickupPointId: 'pp-002',
        createdAt: now.subtract(const Duration(minutes: 25)),
        expiresAt: now.add(const Duration(hours: 2)),
      ),
    ];
  }
}