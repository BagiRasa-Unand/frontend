import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:first_project/core/app_session.dart';
import 'package:first_project/features/donasi/data/food_listing.dart';
import 'package:first_project/features/donasi/data/food_listing_repository.dart';
import 'package:first_project/features/klaim/data/claim.dart';
import 'package:first_project/features/klaim/data/claim_repository.dart';
import 'package:first_project/features/klaim/presentation/claim_decision_sheet.dart';
import 'package:first_project/features/lokasi/data/pickup_point.dart';
import 'package:first_project/features/lokasi/data/pickup_point_repository.dart';

void main() {
  final now = DateTime(2026, 10, 18, 10, 0);

  FoodListing makeListing({
    String id = 'food-test',
    String donorId = kCurrentUserId,
    int remaining = 5,
  }) {
    return FoodListing(
      id: id,
      donorId: donorId,
      donorName: 'Stan Test',
      name: 'Nasi Ayam Bakar Madu',
      foodType: FoodType.makananBerat,
      description: 'Porsi lezat',
      quantityTotal: 5,
      quantityRemaining: remaining,
      pickupPointId: 'pp-stan04',
      createdAt: now.subtract(const Duration(hours: 1)),
      expiresAt: now.add(const Duration(hours: 2)),
    );
  }

  PickupPoint makePickupPoint({String id = 'pp-stan04'}) {
    return PickupPoint(
      id: id,
      name: 'Stan 04',
      address: 'Kantin Pusat',
      latitude: -0.9140,
      longitude: 100.4590,
      openTime: '08:00',
      closeTime: '17:00',
    );
  }

  group('ClaimDecisionSheet UI & Logic', () {
    testWidgets('renders accept variant with real stock calculation and accepts claim', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final listing = makeListing(remaining: 5);
      foodRepo.add(listing);
      pickupRepo.add(makePickupPoint());

      final submitRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-budi',
        claimantName: 'Budi Santoso',
        quantity: 3,
      );
      final claim = submitRes.claim!;

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
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => showClaimDecisionSheet(
                      context,
                      claim,
                      ClaimDecision.accept,
                    ),
                    child: const Text('Buka Sheet'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Buka Sheet'));
      await tester.pumpAndSettle();

      // Check Texts
      expect(find.text('Terima klaim ini?'), findsOneWidget);
      expect(find.text('Nasi Ayam Bakar Madu • Stan 04'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('3 Porsi'), findsOneWidget);

      // Callout: real numbers (5 - 3 = 2 porsi)
      expect(find.text('2 porsi'), findsOneWidget);
      expect(find.textContaining('Stok berkurang'), findsOneWidget);

      // Primary Button
      expect(find.text('YA, TERIMA KLAIM'), findsOneWidget);
      expect(find.text('BATAL'), findsOneWidget);

      // Tap YA, TERIMA KLAIM
      await tester.tap(find.text('YA, TERIMA KLAIM'));
      await tester.pumpAndSettle();

      // Sheet should close and SnackBar appears
      expect(find.text('Terima klaim ini?'), findsNothing);
      expect(find.text('Klaim diterima'), findsOneWidget);

      // Claim status updated
      expect(claimRepo.getById(claim.id)!.status, ClaimStatus.diterima);
      // Food remaining decreased
      expect(foodRepo.getById(listing.id)!.quantityRemaining, 2);
    });

    testWidgets('renders reject variant with reason chips and rejects claim', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final listing = makeListing(remaining: 5);
      foodRepo.add(listing);
      pickupRepo.add(makePickupPoint());

      final submitRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-budi',
        claimantName: 'Budi Santoso',
        quantity: 3,
      );
      final claim = submitRes.claim!;

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
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => showClaimDecisionSheet(
                      context,
                      claim,
                      ClaimDecision.reject,
                    ),
                    child: const Text('Buka Sheet'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Tolak klaim ini?'), findsOneWidget);
      expect(find.text('Alasan Penolakan (opsional):'), findsOneWidget);
      expect(find.text('Porsi sudah habis'), findsOneWidget);
      expect(find.text('YA, TOLAK'), findsOneWidget);

      // Select reason chip
      await tester.tap(find.text('Porsi sudah habis'));
      await tester.pumpAndSettle();

      // Tap YA, TOLAK
      await tester.tap(find.text('YA, TOLAK'));
      await tester.pumpAndSettle();

      // Sheet closed and snackbar appears
      expect(find.text('Tolak klaim ini?'), findsNothing);
      expect(find.text('Klaim ditolak'), findsOneWidget);

      final updated = claimRepo.getById(claim.id)!;
      expect(updated.status, ClaimStatus.ditolak);
      expect(updated.rejectReason, 'Porsi sudah habis');
    });

    testWidgets('renders cancel variant and cancels claim', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final listing = makeListing(donorId: 'other-donor', remaining: 5);
      foodRepo.add(listing);
      pickupRepo.add(makePickupPoint());

      final submitRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: kCurrentUserId, // current user is claimant
        claimantName: 'Current User',
        quantity: 2,
      );
      final claim = submitRes.claim!;

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
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => showClaimDecisionSheet(
                      context,
                      claim,
                      ClaimDecision.cancel,
                    ),
                    child: const Text('Buka Sheet'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Batalkan klaim ini?'), findsOneWidget);
      expect(find.text('YA, BATALKAN'), findsOneWidget);
      expect(find.text('TETAP KLAIM'), findsOneWidget);

      await tester.tap(find.text('YA, BATALKAN'));
      await tester.pumpAndSettle();

      expect(find.text('Batalkan klaim ini?'), findsNothing);
      expect(find.text('Klaim dibatalkan'), findsOneWidget);

      final updated = claimRepo.getById(claim.id)!;
      expect(updated.status, ClaimStatus.dibatalkan);
    });

    testWidgets('tapping BATAL closes sheet without modifying claim', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final listing = makeListing();
      foodRepo.add(listing);

      final submitRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-budi',
        claimantName: 'Budi Santoso',
        quantity: 1,
      );
      final claim = submitRes.claim!;

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
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => showClaimDecisionSheet(
                      context,
                      claim,
                      ClaimDecision.accept,
                    ),
                    child: const Text('Buka Sheet'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Terima klaim ini?'), findsOneWidget);
      await tester.tap(find.text('BATAL'));
      await tester.pumpAndSettle();

      expect(find.text('Terima klaim ini?'), findsNothing);
      expect(claimRepo.getById(claim.id)!.status, ClaimStatus.menunggu);
    });

    testWidgets('on failure shows error in SnackBar and keeps sheet open', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      // Listing owned by a DIFFERENT donor, so kCurrentUserId is not allowed to accept
      final listing = makeListing(donorId: 'other-donor-123', remaining: 2);
      foodRepo.add(listing);

      final submitRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-budi',
        claimantName: 'Budi Santoso',
        quantity: 2,
      );
      final claim = submitRes.claim!;

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
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => showClaimDecisionSheet(
                      context,
                      claim,
                      ClaimDecision.accept,
                    ),
                    child: const Text('Buka Sheet'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Terima klaim ini?'), findsOneWidget);

      // Tap YA, TERIMA KLAIM -> will fail because actor is not donor
      await tester.tap(find.text('YA, TERIMA KLAIM'));
      await tester.pumpAndSettle();

      // Sheet should STILL BE OPEN and show error SnackBar
      expect(find.text('Terima klaim ini?'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('switcher pills dynamically toggle variant between terima, tolak, batalkan', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final listing = makeListing();
      foodRepo.add(listing);

      final submitRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-budi',
        claimantName: 'Budi Santoso',
        quantity: 1,
      );
      final claim = submitRes.claim!;

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
                builder: (context) => Center(
                  child: ElevatedButton(
                    onPressed: () => showClaimDecisionSheet(
                      context,
                      claim,
                      ClaimDecision.accept,
                    ),
                    child: const Text('Buka Sheet'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Terima klaim ini?'), findsOneWidget);

      // Tap 2. Tolak
      await tester.tap(find.text('2. Tolak'));
      await tester.pumpAndSettle();
      expect(find.text('Tolak klaim ini?'), findsOneWidget);

      // Tap 3. Batalkan
      await tester.tap(find.text('3. Batalkan'));
      await tester.pumpAndSettle();
      expect(find.text('Batalkan klaim ini?'), findsOneWidget);

      // Tap 1. Terima
      await tester.tap(find.text('1. Terima'));
      await tester.pumpAndSettle();
      expect(find.text('Terima klaim ini?'), findsOneWidget);
    });
  });
}
