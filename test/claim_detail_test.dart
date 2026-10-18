import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:first_project/features/donasi/data/food_listing.dart';
import 'package:first_project/features/donasi/data/food_listing_repository.dart';
import 'package:first_project/features/klaim/data/claim.dart';
import 'package:first_project/features/klaim/data/claim_repository.dart';
import 'package:first_project/features/klaim/logic/claim_detail_controller.dart';
import 'package:first_project/features/klaim/presentation/claim_detail_screen.dart';
import 'package:first_project/features/lokasi/data/pickup_point.dart';
import 'package:first_project/features/lokasi/data/pickup_point_repository.dart';

void main() {
  final now = DateTime(2026, 10, 18, 10, 15);

  FoodListing makeListing({
    String id = 'food-test',
    String donorId = 'donor-other',
    int remaining = 5,
  }) {
    return FoodListing(
      id: id,
      donorId: donorId,
      donorName: 'Stan Sisfo',
      name: 'Nasi Ayam Bakar Madu',
      foodType: FoodType.makananBerat,
      description: 'Enak dan bergizi',
      quantityTotal: 5,
      quantityRemaining: remaining,
      pickupPointId: 'pp-001',
      createdAt: now.subtract(const Duration(hours: 1)),
      expiresAt: now.add(const Duration(hours: 4, minutes: 15)),
    );
  }

  PickupPoint makePickupPoint({String id = 'pp-001'}) {
    return PickupPoint(
      id: id,
      name: 'Kantin Teknik Sisfo (Stan 04 - Bu Joko)',
      address: 'Gedung GKB Lt. 1 Sayap Barat, Kampus Sukolilo',
      latitude: -0.9140,
      longitude: 100.4590,
      openTime: '08:00',
      closeTime: '17:00',
    );
  }

  group('ClaimDetailController Logic', () {
    test('loads claim, listing, and calculates carbon correctly', () {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final listing = makeListing();
      foodRepo.add(listing);

      final claimRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-1',
        claimantName: 'Rina',
        quantity: 3,
      );
      final claim = claimRes.claim!;

      final controller = ClaimDetailController(
        claimId: claim.id,
        claimRepository: claimRepo,
        foodRepository: foodRepo,
        pickupPointRepository: pickupRepo,
        clock: () => now,
      );

      expect(controller.claim, isNotNull);
      expect(controller.claim!.id, claim.id);
      expect(controller.listing, isNotNull);
      expect(controller.listing!.name, 'Nasi Ayam Bakar Madu');
      expect(controller.carbonSavedKg, 3 * 1.4);
      expect(controller.effectiveStatus, ClaimStatus.menunggu);

      controller.dispose();
    });

    test('simulated status overrides effectiveStatus', () {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final listing = makeListing();
      foodRepo.add(listing);

      final claimRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-1',
        claimantName: 'Rina',
        quantity: 1,
      );

      final controller = ClaimDetailController(
        claimId: claimRes.claim!.id,
        claimRepository: claimRepo,
        foodRepository: foodRepo,
        pickupPointRepository: pickupRepo,
        clock: () => now,
      );

      expect(controller.effectiveStatus, ClaimStatus.menunggu);

      controller.setSimulatedStatus(ClaimStatus.diterima);
      expect(controller.effectiveStatus, ClaimStatus.diterima);

      controller.setSimulatedStatus(ClaimStatus.diterima); // toggle off
      expect(controller.effectiveStatus, ClaimStatus.menunggu);

      controller.dispose();
    });
  });

  group('ClaimDetailScreen UI & Status Variants', () {
    testWidgets('renders all cards for status menunggu and shows BATALKAN KLAIM button', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final listing = makeListing();
      final point = makePickupPoint();
      foodRepo.add(listing);
      pickupRepo.add(point);

      final claimRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-1',
        claimantName: 'Rina',
        quantity: 3,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: foodRepo),
            ChangeNotifierProvider.value(value: claimRepo),
            ChangeNotifierProvider.value(value: pickupRepo),
          ],
          child: MaterialApp(
            home: ClaimDetailScreen(claimId: claimRes.claim!.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header
      expect(find.text('Detail Klaim'), findsOneWidget);
      expect(find.text('KLAIM'), findsOneWidget);

      // Hero Card
      expect(find.text('Menunggu Persetujuan'), findsOneWidget);
      expect(find.text('Menunggu persetujuan pendonor'), findsOneWidget);

      // Listing Card
      expect(find.text('3 Porsi Diklaim'), findsOneWidget);
      expect(find.text('Nasi Ayam Bakar Madu'), findsOneWidget);
      expect(find.text('Halal'), findsOneWidget);

      // Pickup Card
      expect(find.text('Titik Pengambilan'), findsOneWidget);
      expect(find.text('250m dari lokasimu'), findsOneWidget);
      expect(find.text('Buka di Google Maps'), findsOneWidget);

      // Time & Code Card
      expect(find.text('ID Transaksi Klaim'), findsOneWidget);
      expect(find.text('Waktu Diajukan'), findsOneWidget);
      expect(find.text('Batas Ambil'), findsOneWidget);

      // Bottom Button
      expect(find.text('BATALKAN KLAIM'), findsOneWidget);
    });

    testWidgets('renders antre status and shows Antrean ke-N without estimated waiting time', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final listing = makeListing(remaining: 2);
      foodRepo.add(listing);

      // First claim takes all available
      claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-dummy',
        claimantName: 'Dummy',
        quantity: 2,
      );

      // Second claim enters queue
      final queueClaim = claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-queued',
        claimantName: 'Queued',
        quantity: 1,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: foodRepo),
            ChangeNotifierProvider.value(value: claimRepo),
            ChangeNotifierProvider.value(value: pickupRepo),
          ],
          child: MaterialApp(
            home: ClaimDetailScreen(claimId: queueClaim.claim!.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Antrean ke-1'), findsOneWidget);
      expect(find.text('Kamu dalam antrean makanan'), findsOneWidget);
      expect(find.text('BATALKAN KLAIM'), findsOneWidget);
    });

    testWidgets('renders diterima status and shows LIHAT WAKTU PENGAMBILAN button', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final listing = makeListing();
      foodRepo.add(listing);

      final claimRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-accepted',
        claimantName: 'Accepted User',
        quantity: 1,
      );
      claimRepo.acceptClaim(claimRes.claim!.id, actorId: listing.donorId);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: foodRepo),
            ChangeNotifierProvider.value(value: claimRepo),
            ChangeNotifierProvider.value(value: pickupRepo),
          ],
          child: MaterialApp(
            home: ClaimDetailScreen(claimId: claimRes.claim!.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Klaim Disetujui (Siap Diambil)'), findsOneWidget);
      expect(find.text('Klaim diterima! Siap diambil'), findsOneWidget);
      expect(find.text('LIHAT WAKTU PENGAMBILAN'), findsOneWidget);
    });

    testWidgets('renders ditolak status with rejectReason and no action button', (tester) async {
      tester.view.physicalSize = const Size(390 * 2.0, 844 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      final listing = makeListing();
      foodRepo.add(listing);

      final claimRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: 'user-rejected',
        claimantName: 'Rejected User',
        quantity: 1,
      );
      claimRepo.rejectClaim(
        claimRes.claim!.id,
        actorId: listing.donorId,
        reason: 'Porsi sudah habis di stan',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: foodRepo),
            ChangeNotifierProvider.value(value: claimRepo),
            ChangeNotifierProvider.value(value: pickupRepo),
          ],
          child: MaterialApp(
            home: ClaimDetailScreen(claimId: claimRes.claim!.id),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Klaim Ditolak'), findsOneWidget);
      expect(find.text('Klaim belum disetujui'), findsOneWidget);
      expect(find.text('Alasan: Porsi sudah habis di stan'), findsOneWidget);
      expect(find.text('BATALKAN KLAIM'), findsNothing);
      expect(find.text('LIHAT WAKTU PENGAMBILAN'), findsNothing);
    });

    testWidgets('shows friendly message when claim is not found', (tester) async {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final pickupRepo = PickupPointRepository();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: foodRepo),
            ChangeNotifierProvider.value(value: claimRepo),
            ChangeNotifierProvider.value(value: pickupRepo),
          ],
          child: const MaterialApp(
            home: ClaimDetailScreen(claimId: 'non-existent-claim'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Klaim Tidak Ditemukan'), findsOneWidget);
      expect(find.text('KEMBALI'), findsOneWidget);
    });
  });
}

