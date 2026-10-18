import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:first_project/core/app_session.dart';
import 'package:first_project/features/donasi/data/food_listing.dart';
import 'package:first_project/features/donasi/data/food_listing_repository.dart';
import 'package:first_project/features/klaim/data/claim.dart';
import 'package:first_project/features/klaim/data/claim_repository.dart';
import 'package:first_project/features/klaim/logic/claim_notification_mapper.dart';
import 'package:first_project/features/lokasi/data/pickup_point.dart';
import 'package:first_project/features/lokasi/data/pickup_point_repository.dart';
import 'package:first_project/features/notifikasi/data/app_notification.dart';
import 'package:first_project/features/notifikasi/data/notification_repository.dart';
import 'package:first_project/features/notifikasi/presentation/notification_screen.dart';

void main() {
  final now = DateTime(2026, 10, 18, 12, 0);

  final listing = FoodListing(
    id: 'food-001',
    donorId: 'donor-vendor',
    donorName: 'Stan Sisfo',
    name: 'Nasi Ayam Bakar',
    foodType: FoodType.makananBerat,
    description: 'Enak dan lezat',
    quantityTotal: 10,
    quantityRemaining: 5,
    unit: 'porsi',
    pickupPointId: 'pp-001',
    createdAt: now.subtract(const Duration(hours: 1)),
    expiresAt: now.add(const Duration(hours: 2)), // 14:00
  );

  final pickupPoint = PickupPoint(
    id: 'pp-001',
    name: 'Kantin Rektorat Stand 08',
    address: 'Gedung Rektorat Lt 1',
    latitude: -0.9140,
    longitude: 100.4590,
    openTime: '08:00',
    closeTime: '17:00',
  );

  Claim makeClaim({
    String claimantId = kCurrentUserId,
    ClaimStatus status = ClaimStatus.menunggu,
    String? rejectReason,
    String? cancelReason,
  }) {
    return Claim(
      id: 'claim-101',
      listingId: listing.id,
      claimantId: claimantId,
      claimantName: 'Mahasiswa',
      quantity: 2,
      status: status,
      seq: 1,
      createdAt: now.subtract(const Duration(minutes: 30)),
      rejectReason: rejectReason,
      cancelReason: cancelReason,
    );
  }

  group('ClaimNotificationMapper', () {
    test('returns null when claimantId != kCurrentUserId (another user)', () {
      final claim = makeClaim(claimantId: 'user-other');
      final event = ClaimEvent(type: ClaimEventType.accepted, claim: claim);

      final notif = mapClaimEventToNotification(
        event,
        listing: listing,
        pickupPoint: pickupPoint,
        now: now,
      );

      expect(notif, isNull);
    });

    test('returns null for submitted event type', () {
      final claim = makeClaim();
      final event = ClaimEvent(type: ClaimEventType.submitted, claim: claim);

      final notif = mapClaimEventToNotification(
        event,
        listing: listing,
        pickupPoint: pickupPoint,
        now: now,
      );

      expect(notif, isNull);
    });

    test('maps accepted event type correctly', () {
      final claim = makeClaim(status: ClaimStatus.diterima);
      final event = ClaimEvent(type: ClaimEventType.accepted, claim: claim);

      final notif = mapClaimEventToNotification(
        event,
        listing: listing,
        pickupPoint: pickupPoint,
        now: now,
      );

      expect(notif, isNotNull);
      expect(notif!.type, AppNotificationType.claimStatus);
      expect(notif.refId, claim.id);
      expect(notif.title, 'Klaim diterima!');
      expect(notif.body, 'Klaim 2 porsi Nasi Ayam Bakar diterima. Ambil sebelum 14:00.');
    });

    test('maps rejected event type without reason', () {
      final claim = makeClaim(status: ClaimStatus.ditolak);
      final event = ClaimEvent(type: ClaimEventType.rejected, claim: claim);

      final notif = mapClaimEventToNotification(
        event,
        listing: listing,
        pickupPoint: pickupPoint,
        now: now,
      );

      expect(notif, isNotNull);
      expect(notif!.type, AppNotificationType.claimStatus);
      expect(notif.refId, claim.id);
      expect(notif.title, 'Klaim ditolak');
      expect(notif.body, 'Klaim Nasi Ayam Bakar ditolak pendonor.');
    });

    test('maps rejected event type with reason text', () {
      const reason = 'Stok habis diambil rombongan seminar kampus';
      final claim = makeClaim(
        status: ClaimStatus.ditolak,
        rejectReason: reason,
      );
      final event = ClaimEvent(type: ClaimEventType.rejected, claim: claim);

      final notif = mapClaimEventToNotification(
        event,
        listing: listing,
        pickupPoint: pickupPoint,
        now: now,
      );

      expect(notif, isNotNull);
      expect(notif!.type, AppNotificationType.claimStatus);
      expect(notif.refId, claim.id);
      expect(notif.title, 'Klaim ditolak');
      expect(notif.body, contains('Klaim Nasi Ayam Bakar ditolak pendonor.'));
      expect(notif.body, contains(reason));
    });

    test('maps promoted event type correctly', () {
      final claim = makeClaim(status: ClaimStatus.menunggu);
      final event = ClaimEvent(type: ClaimEventType.promoted, claim: claim);

      final notif = mapClaimEventToNotification(
        event,
        listing: listing,
        pickupPoint: pickupPoint,
        now: now,
      );

      expect(notif, isNotNull);
      expect(notif!.type, AppNotificationType.claimStatus);
      expect(notif.refId, claim.id);
      expect(notif.title, 'Klaimmu maju dari antrean');
      expect(notif.body, 'Klaim Nasi Ayam Bakar kini menunggu persetujuan pendonor.');
    });

    test('maps cancelled event type (user cancel) correctly', () {
      final claim = makeClaim(
        status: ClaimStatus.dibatalkan,
        cancelReason: 'Dibatalkan oleh pemohon',
      );
      final event = ClaimEvent(type: ClaimEventType.cancelled, claim: claim);

      final notif = mapClaimEventToNotification(
        event,
        listing: listing,
        pickupPoint: pickupPoint,
        now: now,
      );

      expect(notif, isNotNull);
      expect(notif!.type, AppNotificationType.claimStatus);
      expect(notif.refId, claim.id);
      expect(notif.title, 'Klaim dibatalkan');
      expect(notif.body, 'Kamu membatalkan klaim Nasi Ayam Bakar.');
    });

    test('maps autoCancelled event type with cancelReason correctly', () {
      const reason = 'Stok tidak lagi mencukupi';
      final claim = makeClaim(
        status: ClaimStatus.dibatalkan,
        cancelReason: reason,
      );
      final event = ClaimEvent(type: ClaimEventType.autoCancelled, claim: claim);

      final notif = mapClaimEventToNotification(
        event,
        listing: listing,
        pickupPoint: pickupPoint,
        now: now,
      );

      expect(notif, isNotNull);
      expect(notif!.type, AppNotificationType.claimStatus);
      expect(notif.refId, claim.id);
      expect(notif.title, 'Klaim dibatalkan');
      expect(notif.body, reason);
    });

    test('maps reminderDue event type correctly', () {
      final claim = makeClaim(status: ClaimStatus.diterima);
      final event = ClaimEvent(type: ClaimEventType.reminderDue, claim: claim);

      final notif = mapClaimEventToNotification(
        event,
        listing: listing,
        pickupPoint: pickupPoint,
        now: now,
      );

      expect(notif, isNotNull);
      expect(notif!.type, AppNotificationType.reminder);
      expect(notif.refId, claim.id);
      expect(notif.title, 'Waktu pengambilan hampir habis');
      expect(notif.body, 'Nasi Ayam Bakar: sisa 120 menit untuk mengambil di Kantin Rektorat Stand 08.');
    });
  });

  group('NotificationScreen Integration with ClaimDetailScreen', () {
    testWidgets('tap on claim notification opens ClaimDetailScreen when claim exists', (tester) async {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final notifRepo = NotificationRepository();
      final pickupRepo = PickupPointRepository();

      foodRepo.add(listing);
      pickupRepo.add(pickupPoint);

      final claimRes = claimRepo.submitClaim(
        listing: listing,
        claimantId: kCurrentUserId,
        claimantName: 'Saya',
        quantity: 2,
      );
      claimRepo.acceptClaim(claimRes.claim!.id, actorId: 'donor-vendor');

      // Add notification with refId = claimRes.claim!.id
      notifRepo.add(
        AppNotification(
          id: 'test-notif-1',
          type: AppNotificationType.claimStatus,
          title: 'Klaim diterima!',
          body: 'Klaim 2 porsi Nasi Ayam Bakar diterima.',
          createdAt: now,
          isRead: false,
          refId: claimRes.claim!.id,
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: foodRepo),
            ChangeNotifierProvider.value(value: claimRepo),
            ChangeNotifierProvider.value(value: notifRepo),
            ChangeNotifierProvider.value(value: pickupRepo),
          ],
          child: const MaterialApp(
            home: NotificationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Klaim diterima!'), findsOneWidget);

      await tester.tap(find.text('Klaim diterima!'));
      await tester.pumpAndSettle();

      // Verified navigated to ClaimDetailScreen
      expect(find.text('Detail Klaim'), findsOneWidget);
    });

    testWidgets('tap on claim notification shows SnackBar when claim no longer exists', (tester) async {
      final foodRepo = FoodListingRepository();
      final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: () => now);
      final notifRepo = NotificationRepository();
      final pickupRepo = PickupPointRepository();

      // Notification with non-existent refId
      notifRepo.add(
        AppNotification(
          id: 'test-notif-deleted',
          type: AppNotificationType.claimStatus,
          title: 'Klaim diterima!',
          body: 'Klaim pesanan lama.',
          createdAt: now,
          isRead: false,
          refId: 'claim-non-existent-999',
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: foodRepo),
            ChangeNotifierProvider.value(value: claimRepo),
            ChangeNotifierProvider.value(value: notifRepo),
            ChangeNotifierProvider.value(value: pickupRepo),
          ],
          child: const MaterialApp(
            home: NotificationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Klaim diterima!'), findsOneWidget);

      await tester.tap(find.text('Klaim diterima!'));
      await tester.pumpAndSettle();

      // SnackBar shows "Klaim tidak ditemukan"
      expect(find.text('Klaim tidak ditemukan'), findsOneWidget);
    });
  });
}
