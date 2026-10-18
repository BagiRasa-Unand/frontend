import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:first_project/core/app_session.dart';
import 'package:first_project/core/widgets/main_shell.dart';
import 'package:first_project/features/donasi/data/food_listing.dart';
import 'package:first_project/features/donasi/data/food_listing_repository.dart';
import 'package:first_project/features/klaim/data/claim.dart';
import 'package:first_project/features/klaim/data/claim_repository.dart';
import 'package:first_project/features/klaim/logic/claim_history_controller.dart';
import 'package:first_project/features/klaim/presentation/claim_history_screen.dart';
import 'package:first_project/features/lokasi/data/pickup_point.dart';
import 'package:first_project/features/lokasi/data/pickup_point_repository.dart';
import 'package:first_project/features/notifikasi/data/notification_repository.dart';

void main() {
  final now = DateTime(2026, 10, 18, 12, 0);

  FoodListing makeListing({
    required String id,
    required String name,
    int remaining = 10,
    int total = 10,
  }) {
    return FoodListing(
      id: id,
      donorId: 'donor-vendor',
      donorName: 'Stan Teknik',
      name: name,
      foodType: FoodType.makananBerat,
      description: 'Makanan lezat surplus',
      quantityTotal: total,
      quantityRemaining: remaining,
      pickupPointId: 'pp-001',
      createdAt: now.subtract(const Duration(hours: 2)),
      expiresAt: now.add(const Duration(hours: 3)),
    );
  }

  PickupPoint makePickupPoint() {
    return PickupPoint(
      id: 'pp-001',
      name: 'Kantin Teknik Sisfo (Stan 04)',
      address: 'Gedung Teknik Lt 1',
      latitude: -0.9140,
      longitude: 100.4590,
      openTime: '08:00',
      closeTime: '17:00',
    );
  }

  group('ClaimHistoryController Logic', () {
    test('computes totalAcceptedQuantity, level, carbon savings and filters claims correctly', () {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final l1 = makeListing(id: 'food-1', name: 'Nasi Ayam Bakar');
      final l2 = makeListing(id: 'food-2', name: 'Paket Aneka Jajan');
      final l3 = makeListing(id: 'food-3', name: 'Nasi Kotak Ayam G');
      final l4 = makeListing(id: 'food-4', name: 'Sandwich Gandum');
      foodRepo.add(l1);
      foodRepo.add(l2);
      foodRepo.add(l3);
      foodRepo.add(l4);

      // Claim 1: Accepted (qty 2)
      final c1Res = claimRepo.submitClaim(
        listing: l1,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 2,
      );
      claimRepo.acceptClaim(c1Res.claim!.id, actorId: 'donor-vendor');

      // Claim 2: Accepted (qty 3)
      final c2Res = claimRepo.submitClaim(
        listing: l2,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 3,
      );
      claimRepo.acceptClaim(c2Res.claim!.id, actorId: 'donor-vendor');

      // Claim 3: Rejected (qty 1)
      final c3Res = claimRepo.submitClaim(
        listing: l3,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 1,
      );
      claimRepo.rejectClaim(c3Res.claim!.id, actorId: 'donor-vendor', reason: 'Stok habis');

      // Claim 4: Cancelled (qty 1)
      final c4Res = claimRepo.submitClaim(
        listing: l4,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 1,
      );
      claimRepo.cancelClaim(c4Res.claim!.id, actorId: kCurrentUserId);

      final controller = ClaimHistoryController(
        claimRepo: claimRepo,
        foodRepo: foodRepo,
        pickupRepo: pickupRepo,
      );

      // totalSaved = 2 + 3 = 5
      expect(controller.totalSaved, 5);
      expect(controller.carbonSavedKg, 5 * 0.4);
      expect(controller.level, 1);
      expect(controller.remainingToNextLevel, 1); // target 6, remaining 1

      // Counts per filter
      expect(controller.countFor(ClaimHistoryFilter.semua), 4);
      expect(controller.countFor(ClaimHistoryFilter.diterima), 2);
      expect(controller.countFor(ClaimHistoryFilter.ditolak), 1);
      expect(controller.countFor(ClaimHistoryFilter.dibatalkan), 1);

      // Filter switching
      expect(controller.claims.length, 4);

      controller.setFilter(ClaimHistoryFilter.diterima);
      expect(controller.claims.length, 2);
      expect(controller.claims.every((c) => c.status == ClaimStatus.diterima), isTrue);

      controller.setFilter(ClaimHistoryFilter.ditolak);
      expect(controller.claims.length, 1);
      expect(controller.claims.first.status, ClaimStatus.ditolak);

      controller.setFilter(ClaimHistoryFilter.dibatalkan);
      expect(controller.claims.length, 1);
      expect(controller.claims.first.status, ClaimStatus.dibatalkan);

      // Empty preview mode
      controller.setShowEmptyPreview(true);
      expect(controller.claims.isEmpty, isTrue);

      controller.dispose();
    });

    test('updates automatically when ClaimRepository changes', () {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final controller = ClaimHistoryController(
        claimRepo: claimRepo,
        foodRepo: foodRepo,
        pickupRepo: pickupRepo,
      );

      var notified = false;
      controller.addListener(() => notified = true);

      final l1 = makeListing(id: 'food-new', name: 'Roti Coklat');
      foodRepo.add(l1);

      claimRepo.submitClaim(
        listing: l1,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 2,
      );

      expect(notified, isTrue);
      expect(controller.allClaims.length, 1);

      controller.dispose();
    });
  });

  group('ClaimHistoryScreen Widget UI', () {
    Widget buildTestWidget({
      required FoodListingRepository foodRepo,
      required ClaimRepository claimRepo,
      required PickupPointRepository pickupRepo,
    }) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: foodRepo),
          ChangeNotifierProvider.value(value: claimRepo),
          ChangeNotifierProvider.value(value: pickupRepo),
        ],
        child: const MaterialApp(
          home: ClaimHistoryScreen(),
        ),
      );
    }

    testWidgets('renders header, summary card, filter chips, and card list', (tester) async {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final pp = makePickupPoint();
      pickupRepo.add(pp);

      final l1 = makeListing(id: 'food-1', name: 'Nasi Ayam Bakar');
      foodRepo.add(l1);

      final res = claimRepo.submitClaim(
        listing: l1,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 2,
      );
      claimRepo.acceptClaim(res.claim!.id, actorId: 'donor-vendor');

      await tester.pumpWidget(
        buildTestWidget(
          foodRepo: foodRepo,
          claimRepo: claimRepo,
          pickupRepo: pickupRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('BAGIRASA'), findsOneWidget);
      expect(find.text('Riwayat Klaim'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // View switcher
      expect(find.text('Daftar Riwayat'), findsOneWidget);
      expect(find.text('Pratinjau Kosong'), findsOneWidget);

      // Summary Card
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Porsi'), findsWidgets);
      expect(find.text('Total porsi pangan terselamatkan'), findsOneWidget);
      expect(find.text('Penyelamat Pangan Aktif'), findsOneWidget);
      expect(find.textContaining('kg emisi karbon'), findsOneWidget);

      // Filter chips
      expect(find.text('Semua'), findsOneWidget);
      expect(find.text('Diterima'), findsWidgets);
      expect(find.text('Ditolak'), findsOneWidget);
      expect(find.text('Dibatalkan'), findsOneWidget);

      // Food card
      expect(find.text('Nasi Ayam Bakar'), findsOneWidget);
    });

    testWidgets('empty state displays when Pratinjau Kosong is tapped', (tester) async {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      await tester.pumpWidget(
        buildTestWidget(
          foodRepo: foodRepo,
          claimRepo: claimRepo,
          pickupRepo: pickupRepo,
        ),
      );
      await tester.pumpAndSettle();

      // Initially empty because no claims exist
      expect(find.text('Belum Ada Riwayat Klaim'), findsOneWidget);
      expect(find.text('Semua makanan surplus yang pernah kamu klaim akan tercatat rapi di sini.'), findsOneWidget);

      // Add a claim
      final l1 = makeListing(id: 'food-1', name: 'Paket Aneka Jajan');
      foodRepo.add(l1);
      final res = claimRepo.submitClaim(
        listing: l1,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 1,
      );
      claimRepo.acceptClaim(res.claim!.id, actorId: 'donor-vendor');

      await tester.pumpAndSettle();
      expect(find.text('Paket Aneka Jajan'), findsOneWidget);
      expect(find.text('Belum Ada Riwayat Klaim'), findsNothing);

      // Tap "Pratinjau Kosong"
      await tester.tap(find.text('Pratinjau Kosong'));
      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Riwayat Klaim'), findsOneWidget);

      // Tap back to "Daftar Riwayat"
      await tester.tap(find.text('Daftar Riwayat'));
      await tester.pumpAndSettle();

      expect(find.text('Paket Aneka Jajan'), findsOneWidget);
    });

    testWidgets('MainShell has Riwayat Klaim Saya entry in Profil tab', (tester) async {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();
      final notifRepo = NotificationRepository();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: foodRepo),
            ChangeNotifierProvider.value(value: claimRepo),
            ChangeNotifierProvider.value(value: pickupRepo),
            ChangeNotifierProvider.value(value: notifRepo),
          ],
          child: const MaterialApp(
            home: MainShell(initialIndex: 3),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Riwayat Klaim Saya'), findsOneWidget);

      // Tap button and verify navigation to ClaimHistoryScreen
      await tester.tap(find.text('Riwayat Klaim Saya'));
      await tester.pumpAndSettle();

      expect(find.text('Riwayat Klaim'), findsOneWidget);
    });
  });
}

