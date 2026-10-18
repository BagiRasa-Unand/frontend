import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:first_project/core/app_session.dart';
import 'package:first_project/features/donasi/data/food_listing.dart';
import 'package:first_project/features/donasi/data/food_listing_repository.dart';
import 'package:first_project/features/klaim/data/claim_repository.dart';
import 'package:first_project/features/klaim/logic/claim_form_controller.dart';
import 'package:first_project/features/klaim/presentation/claim_form_sheet.dart';
import 'package:first_project/features/lokasi/data/pickup_point_repository.dart';

void main() {
  final now = DateTime(2026, 10, 18, 12, 0);

  FoodListing makeListing({
    String id = 'food-test',
    String donorId = 'donor-other',
    int remaining = 5,
    int total = 5,
  }) {
    return FoodListing(
      id: id,
      donorId: donorId,
      donorName: 'Stan Uji Coba',
      name: 'Nasi Ayam Bakar Madu',
      foodType: FoodType.makananBerat,
      description: 'Enak dan bergizi',
      quantityTotal: total,
      quantityRemaining: remaining,
      pickupPointId: 'pp-001',
      createdAt: now.subtract(const Duration(hours: 1)),
      expiresAt: now.add(const Duration(hours: 2)),
    );
  }

  group('ClaimFormController Logic', () {
    test('initial state and computed variant normal when stock is available', () {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final listing = makeListing(remaining: 5);
      foodRepo.add(listing);

      final controller = ClaimFormController(
        listing: listing,
        claimRepository: claimRepo,
      );

      expect(controller.quantity, 1);
      expect(controller.maxQuantity, 5);
      expect(controller.minQuantity, 1);
      expect(controller.computedVariant, ClaimFormVariant.normal);
      expect(controller.variant, ClaimFormVariant.normal);
      expect(controller.carbonSavedKg, 1.4);
    });

    test('increment and decrement updates quantity and carbon saved', () {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final listing = makeListing(remaining: 3);
      foodRepo.add(listing);

      final controller = ClaimFormController(
        listing: listing,
        claimRepository: claimRepo,
      );

      expect(controller.canDecrement, isFalse);
      expect(controller.canIncrement, isTrue);

      controller.increment();
      expect(controller.quantity, 2);
      expect(controller.carbonSavedKg, 2.8);
      expect(controller.canDecrement, isTrue);

      controller.increment();
      expect(controller.quantity, 3);
      expect(controller.canIncrement, isFalse);

      controller.increment(); // Should not exceed max
      expect(controller.quantity, 3);

      controller.decrement();
      expect(controller.quantity, 2);
    });

    test('variant changes dynamically to queue when quantity exceeds availableToRequest', () {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final listing = makeListing(remaining: 3);
      foodRepo.add(listing);

      // Submit claim by dummy user for 2 portions -> availableToRequest becomes 1
      claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-other',
        claimantName: 'Other',
        quantity: 2,
      );

      final controller = ClaimFormController(
        listing: listing,
        claimRepository: claimRepo,
      );

      // Quantity 1 <= available (1) -> normal
      expect(controller.quantity, 1);
      expect(controller.computedVariant, ClaimFormVariant.normal);

      // Quantity 2 > available (1) -> queue
      controller.increment();
      expect(controller.quantity, 2);
      expect(controller.computedVariant, ClaimFormVariant.queue);
      expect(controller.queuePositionForNewClaim, 1);
    });

    test('variant is blocked when claimant already has an active claim', () {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final listing = makeListing(remaining: 3);
      foodRepo.add(listing);

      // Current user submits claim
      claimRepo.submitClaim(
        listing: listing,
        claimantId: kCurrentUserId,
        claimantName: kCurrentUserName,
        quantity: 1,
      );

      final controller = ClaimFormController(
        listing: listing,
        claimRepository: claimRepo,
      );

      expect(controller.hasActiveClaim, isTrue);
      expect(controller.computedVariant, ClaimFormVariant.blocked);
      expect(controller.canIncrement, isFalse);
      expect(controller.canDecrement, isFalse);
    });
  });

  group('ClaimFormSheet Widget UI', () {
    testWidgets('renders all sheet components and handles claim submission', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();
      final listing = makeListing(remaining: 5);
      foodRepo.add(listing);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: foodRepo),
            ChangeNotifierProvider.value(value: claimRepo),
            ChangeNotifierProvider.value(value: pickupRepo),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showClaimSheet(context, listing),
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      // Tap open button
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Verify Header & Components
      expect(find.text('Klaim Makanan'), findsOneWidget);
      expect(find.text('BagiRasa Rescue'), findsOneWidget);
      expect(find.text('Nasi Ayam Bakar Madu'), findsOneWidget);
      expect(find.text('Porsi yang ingin diselamatkan'), findsOneWidget);
      expect(find.text('Maks 2 porsi'), findsOneWidget);
      expect(find.text('Porsi santap mahasiswa'), findsOneWidget);
      expect(find.text('Hemat 1.4 kg Jejak Karbon'), findsOneWidget);
      expect(find.text('Menunggu Persetujuan Stan'), findsOneWidget);
      expect(find.text('AJUKAN KLAIM'), findsOneWidget);
      expect(find.text('BATAL'), findsOneWidget);

      // Increment quantity
      final plusButton = find.byIcon(Icons.add_rounded);
      await tester.tap(plusButton);
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('Hemat 2.8 kg Jejak Karbon'), findsOneWidget);

      // Submit Claim
      final submitButton = find.text('AJUKAN KLAIM');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Sheet closed and snackbar appears
      expect(find.text('Klaim diajukan'), findsOneWidget);
      // Pushed ClaimDetailScreen placeholder
      expect(find.text('Detail Klaim'), findsOneWidget);
    });
  });
}
