import 'package:first_project/features/donasi/data/food_listing.dart';
import 'package:first_project/features/donasi/data/food_listing_repository.dart';
import 'package:first_project/features/donasi/logic/listing_form_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 18, 12);

  test('create validation requires name, type, deadline, and pickup point', () {
    final controller = ListingFormController();
    expect(controller.validate(now), isFalse);
    expect(controller.nameError, isNotNull);
    expect(controller.foodTypeError, isNotNull);
    expect(controller.expiresAtError, isNotNull);
    expect(controller.pickupPointError, isNotNull);
  });

  test('create saves a new listing with all remaining quantity', () {
    final repository = FoodListingRepository();
    final controller = ListingFormController()
      ..setName('Nasi Baru')
      ..setFoodType(FoodType.makananBerat)
      ..setQuantity(4)
      ..setPickupPoint('pp-001')
      ..setExpiresAt(now.add(const Duration(hours: 2)));

    expect(controller.validate(now), isTrue);
    controller.save(repository);

    final saved = repository.getAll().last;
    expect(saved.name, 'Nasi Baru');
    expect(saved.quantityTotal, 4);
    expect(saved.quantityRemaining, 4);
    expect(saved.pickupPointId, 'pp-001');
  });

  test('edit quantity cannot go below already claimed quantity', () {
    final original = FoodListing(
      id: 'edit-me',
      donorId: 'donor-current',
      donorName: 'Budi Santoso',
      name: 'Nasi Edit',
      foodType: FoodType.makananBerat,
      description: '',
      quantityTotal: 10,
      quantityRemaining: 7,
      pickupPointId: 'pp-001',
      createdAt: now.subtract(const Duration(hours: 1)),
      expiresAt: now.add(const Duration(hours: 1)),
    );
    final repository = FoodListingRepository()..add(original);
    final controller = ListingFormController(listing: original);

    controller.setQuantity(1);
    expect(controller.quantityTotal, 3);
    controller.setQuantity(5);
    controller.setExpiresAt(now.add(const Duration(hours: 2)));
    expect(controller.validate(now), isTrue);
    controller.save(repository);

    final saved = repository.getById('edit-me')!;
    expect(saved.quantityTotal, 5);
    expect(saved.quantityRemaining, 2);
  });
}
