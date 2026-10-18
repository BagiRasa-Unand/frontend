import 'package:first_project/features/donasi/data/food_listing.dart';
import 'package:first_project/features/donasi/data/food_listing_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime(2026, 10, 18, 12);

  FoodListing makeListing({
    int total = 10,
    int remaining = 10,
    Duration lifetime = const Duration(hours: 1),
  }) {
    return FoodListing(
      id: 'test', donorId: 'donor', donorName: 'Donor', name: 'Makanan',
      foodType: FoodType.makananBerat, description: 'Deskripsi',
      quantityTotal: total, quantityRemaining: remaining,
      pickupPointId: 'pp-001', createdAt: createdAt,
      expiresAt: createdAt.add(lifetime),
    );
  }

  test('status respects stock, expiry, and 20 percent boundaries', () {
    final justOverThirtyMinutes = makeListing(
      lifetime: const Duration(minutes: 31),
    );
    expect(justOverThirtyMinutes.statusAt(createdAt), ListingStatus.tersedia);

    final exactlyThirtyMinutes = makeListing(
      lifetime: const Duration(minutes: 30),
    );
    expect(exactlyThirtyMinutes.statusAt(createdAt), ListingStatus.segeraHabis);

    final oneHour = makeListing();
    expect(
      oneHour.statusAt(createdAt.add(const Duration(minutes: 48))),
      ListingStatus.segeraHabis,
    );

    final claimedAndExpired = makeListing(
      remaining: 0,
      lifetime: const Duration(minutes: 10),
    );
    expect(
      claimedAndExpired.statusAt(createdAt.add(const Duration(minutes: 10))),
      ListingStatus.habisDiklaim,
    );
  });

  test('timeLeftAt never becomes negative', () {
    final item = makeListing(lifetime: const Duration(minutes: 30));
    expect(item.timeLeftAt(createdAt.add(const Duration(minutes: 31))), Duration.zero);
  });

  test('decreaseStock succeeds and rejects invalid quantities', () {
    final repository = FoodListingRepository();
    final item = repository.getById('food-001')!;
    expect(repository.decreaseStock(item.id, 2), isTrue);
    expect(repository.getById(item.id)!.quantityRemaining, item.quantityRemaining - 2);
    expect(repository.decreaseStock(item.id, 0), isFalse);
    expect(repository.decreaseStock(item.id, 99), isFalse);
  });

  test('delete refuses claimed listings', () {
    final repository = FoodListingRepository();
    expect(repository.delete('food-003'), isFalse);
    expect(repository.getById('food-003'), isNotNull);
  });

  test('statsFor returns saved, listing, and expired totals', () {
    final repository = FoodListingRepository();
    final stats = repository.statsFor('donor-current');
    expect(stats.totalSaved, 17);
    expect(stats.totalListings, 3);
    expect(stats.expiredCount, 0);
  });
}