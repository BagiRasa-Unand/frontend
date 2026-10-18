import 'package:first_project/features/donasi/data/food_listing.dart';
import 'package:first_project/features/donasi/data/food_listing_repository.dart';
import 'package:first_project/features/klaim/data/claim.dart';
import 'package:first_project/features/klaim/data/claim_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime currentTime;
  DateTime clock() => currentTime;

  FoodListing makeTestListing({
    required String id,
    String donorId = 'donor-1',
    String donorName = 'Donor Test',
    int total = 10,
    int remaining = 10,
    required DateTime createdAt,
    Duration lifetime = const Duration(hours: 2),
  }) {
    return FoodListing(
      id: id,
      donorId: donorId,
      donorName: donorName,
      name: 'Makanan $id',
      foodType: FoodType.makananBerat,
      description: 'Deskripsi $id',
      quantityTotal: total,
      quantityRemaining: remaining,
      pickupPointId: 'pp-001',
      createdAt: createdAt,
      expiresAt: createdAt.add(lifetime),
    );
  }

  setUp(() {
    currentTime = DateTime(2026, 10, 18, 12, 0, 0);
  });

  test('status menunggu vs antre', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-m-vs-a',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final events = <ClaimEvent>[];
    claimRepo.onEvent = events.add;

    // First claim: fits in available stock (3 <= 5) -> menunggu
    final result1 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User Satu',
      quantity: 3,
    );
    expect(result1.ok, isTrue);
    expect(result1.claim!.status, ClaimStatus.menunggu);
    expect(claimRepo.reservedFor(listing.id), 3);
    expect(claimRepo.availableToRequest(listing.id), 2);

    // Second claim: 3 > 2 (available) and 3 <= 5 (remaining) -> antre
    final result2 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-2',
      claimantName: 'User Dua',
      quantity: 3,
    );
    expect(result2.ok, isTrue);
    expect(result2.claim!.status, ClaimStatus.antre);
    expect(events.length, 2);
    expect(events[0].type, ClaimEventType.submitted);
    expect(events[1].type, ClaimEventType.submitted);
  });

  test('a new claim queues behind an existing queue even if it fits', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-queue-behind',
      total: 10,
      remaining: 10,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    // 8 requested -> menunggu, 2 remaining available
    final r1 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User Satu',
      quantity: 8,
    );
    expect(r1.claim!.status, ClaimStatus.menunggu);

    // 3 requested -> does not fit in 2 available -> antre
    final r2 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-2',
      claimantName: 'User Dua',
      quantity: 3,
    );
    expect(r2.claim!.status, ClaimStatus.antre);

    // 1 requested -> fits in 2 available, but queue exists -> antre
    final r3 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-3',
      claimantName: 'User Tiga',
      quantity: 1,
    );
    expect(r3.claim!.status, ClaimStatus.antre);
    expect(claimRepo.queuePosition(r2.claim!.id), 1);
    expect(claimRepo.queuePosition(r3.claim!.id), 2);
  });

  test('strict FIFO promotion after reject and after cancel', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    // Test promotion after reject
    final listing1 = makeTestListing(
      id: 'test-promote-reject',
      donorId: 'donor-promo',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
    );
    foodRepo.add(listing1);

    final promotedEvents = <ClaimEvent>[];
    claimRepo.onEvent = (e) {
      if (e.type == ClaimEventType.promoted) promotedEvents.add(e);
    };

    final r1 = claimRepo.submitClaim(
      listing: listing1,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 4,
    );
    final r2 = claimRepo.submitClaim(
      listing: listing1,
      claimantId: 'user-2',
      claimantName: 'User 2',
      quantity: 3,
    );
    expect(r1.claim!.status, ClaimStatus.menunggu);
    expect(r2.claim!.status, ClaimStatus.antre);

    final rejectRes = claimRepo.rejectClaim(
      r1.claim!.id,
      actorId: 'donor-promo',
      reason: 'Tidak dapat dipenuhi',
    );
    expect(rejectRes.ok, isTrue);
    expect(claimRepo.getById(r1.claim!.id)!.status, ClaimStatus.ditolak);
    expect(claimRepo.getById(r2.claim!.id)!.status, ClaimStatus.menunggu);
    expect(promotedEvents.length, 1);
    expect(promotedEvents.first.claim.id, r2.claim!.id);

    // Test promotion after cancel
    final listing2 = makeTestListing(
      id: 'test-promote-cancel',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
    );
    foodRepo.add(listing2);

    final r3 = claimRepo.submitClaim(
      listing: listing2,
      claimantId: 'user-3',
      claimantName: 'User 3',
      quantity: 4,
    );
    final r4 = claimRepo.submitClaim(
      listing: listing2,
      claimantId: 'user-4',
      claimantName: 'User 4',
      quantity: 3,
    );
    expect(r3.claim!.status, ClaimStatus.menunggu);
    expect(r4.claim!.status, ClaimStatus.antre);

    final cancelRes = claimRepo.cancelClaim(
      r3.claim!.id,
      actorId: 'user-3',
    );
    expect(cancelRes.ok, isTrue);
    expect(claimRepo.getById(r3.claim!.id)!.status, ClaimStatus.dibatalkan);
    expect(claimRepo.getById(r4.claim!.id)!.status, ClaimStatus.menunggu);
  });

  test('stop at the first misfit (a smaller later claim is NOT promoted)', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-misfit',
      total: 10,
      remaining: 5,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    // Reserved: 2, available: 3
    final r1 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 2,
    );
    expect(r1.claim!.status, ClaimStatus.menunggu);

    // Head of queue wants 4 (available is 3) -> misfit
    final r2 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-2',
      claimantName: 'User 2',
      quantity: 4,
    );
    expect(r2.claim!.status, ClaimStatus.antre);

    // Second in queue wants 2 (fits in 3, but blocked by head)
    final r3 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-3',
      claimantName: 'User 3',
      quantity: 2,
    );
    expect(r3.claim!.status, ClaimStatus.antre);

    // Trigger promoteQueue
    claimRepo.promoteQueue(listing.id);

    // Strict FIFO: head (r2) does not fit, so evaluation STOPPED.
    // r3 must NOT be promoted despite having qty 2 <= available 3.
    expect(claimRepo.getById(r2.claim!.id)!.status, ClaimStatus.antre);
    expect(claimRepo.getById(r3.claim!.id)!.status, ClaimStatus.antre);

    // Now test auto-cancellation if head can never fit:
    // If listing remaining drops below r2's quantity (say remaining becomes 3):
    foodRepo.decreaseStock(listing.id, 2); // remaining is now 3, r2 quantity is 4
    expect(foodRepo.getById(listing.id)!.quantityRemaining, 3);

    claimRepo.promoteQueue(listing.id);

    // r2 (qty 4 > remaining 3) can never fit -> auto-cancelled
    expect(claimRepo.getById(r2.claim!.id)!.status, ClaimStatus.dibatalkan);
    expect(claimRepo.getById(r2.claim!.id)!.cancelReason, 'Stok tidak lagi mencukupi');
    // After r2 auto-cancelled, r3 becomes head (qty 2 <= available 1? wait, reserved is 2, available is 3 - 2 = 1)
    // r3 wants 2, available is 1, so r3 cannot fit available 1, stays antre
    expect(claimRepo.getById(r3.claim!.id)!.status, ClaimStatus.antre);
  });

  test('accept decreases stock via decreaseStock', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-accept-decrease',
      donorId: 'donor-1',
      total: 10,
      remaining: 10,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final r1 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 3,
    );

    final acceptRes = claimRepo.acceptClaim(r1.claim!.id, actorId: 'donor-1');
    expect(acceptRes.ok, isTrue);
    expect(acceptRes.claim!.status, ClaimStatus.diterima);
    expect(acceptRes.claim!.decidedAt, currentTime);
    expect(foodRepo.getById(listing.id)!.quantityRemaining, 7);
  });

  test('accepting the last remaining stock does NOT auto-cancel that claim', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-accept-last-stock',
      donorId: 'donor-1',
      total: 3,
      remaining: 3,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final r1 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 3,
    );
    expect(r1.claim!.status, ClaimStatus.menunggu);

    final acceptRes = claimRepo.acceptClaim(r1.claim!.id, actorId: 'donor-1');
    expect(acceptRes.ok, isTrue);
    expect(acceptRes.claim!.status, ClaimStatus.diterima);
    expect(foodRepo.getById(listing.id)!.quantityRemaining, 0);

    // Reconcile was called, but the claim being accepted is diterima, NOT auto-cancelled
    final freshClaim = claimRepo.getById(r1.claim!.id)!;
    expect(freshClaim.status, ClaimStatus.diterima);
    expect(freshClaim.cancelReason, isNull);
  });

  test('accept fails cleanly when decreaseStock returns false', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-accept-fail',
      donorId: 'donor-1',
      total: 3,
      remaining: 3,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final r1 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 2,
    );

    // Decrease stock behind repository's back to 1 (not 0, so listing is not sold out)
    foodRepo.decreaseStock(listing.id, 2); // remaining becomes 1

    // Claim requires 2 portions, but only 1 remains -> decreaseStock returns false
    final acceptRes = claimRepo.acceptClaim(r1.claim!.id, actorId: 'donor-1');
    expect(acceptRes.ok, isFalse);
    expect(acceptRes.error, isNotNull);
    expect(claimRepo.getById(r1.claim!.id)!.status, ClaimStatus.menunggu);
  });

  test('duplicate active claim refused', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-duplicate',
      total: 10,
      remaining: 10,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final r1 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 2,
    );
    expect(r1.ok, isTrue);

    // Same user claims again while first claim is menunggu -> refused
    final r2 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 1,
    );
    expect(r2.ok, isFalse);
    expect(r2.error, contains('klaim aktif'));

    // User in antre also cannot create another active claim
    final r3 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-2',
      claimantName: 'User 2',
      quantity: 9,
    );
    expect(r3.claim!.status, ClaimStatus.antre);

    final r4 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-2',
      claimantName: 'User 2',
      quantity: 1,
    );
    expect(r4.ok, isFalse);
  });

  test('owner cannot claim own listing', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-owner',
      donorId: 'donor-owner',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final result = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'donor-owner',
      claimantName: 'Pemilik Sendiri',
      quantity: 1,
    );
    expect(result.ok, isFalse);
    expect(result.error, contains('Pemilik donasi tidak dapat'));
  });

  test('quantity above remaining refused', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-qty-overflow',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final overResult = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 6,
    );
    expect(overResult.ok, isFalse);
    expect(overResult.error, contains('melebihi'));

    final zeroResult = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 0,
    );
    expect(zeroResult.ok, isFalse);
    expect(zeroResult.error, contains('lebih dari 0'));
  });

  test('non-donor cannot accept', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-non-donor',
      donorId: 'real-donor',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final r = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 2,
    );

    final acceptRes = claimRepo.acceptClaim(
      r.claim!.id,
      actorId: 'fake-donor',
    );
    expect(acceptRes.ok, isFalse);
    expect(acceptRes.error, contains('pemilik donasi'));
    expect(claimRepo.getById(r.claim!.id)!.status, ClaimStatus.menunggu);
  });

  test('non-claimant cannot cancel', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-non-claimant',
      donorId: 'donor-1',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final r = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'real-claimant',
      claimantName: 'Real Claimant',
      quantity: 2,
    );

    final cancelRes = claimRepo.cancelClaim(
      r.claim!.id,
      actorId: 'other-user',
    );
    expect(cancelRes.ok, isFalse);
    expect(cancelRes.error, contains('pemohon'));
    expect(claimRepo.getById(r.claim!.id)!.status, ClaimStatus.menunggu);
  });

  test('cancelling an accepted claim refused', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-cancel-accepted',
      donorId: 'donor-1',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final r = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'claimant-1',
      claimantName: 'Claimant 1',
      quantity: 2,
    );

    claimRepo.acceptClaim(r.claim!.id, actorId: 'donor-1');
    expect(claimRepo.getById(r.claim!.id)!.status, ClaimStatus.diterima);

    final cancelRes = claimRepo.cancelClaim(
      r.claim!.id,
      actorId: 'claimant-1',
    );
    expect(cancelRes.ok, isFalse);
    expect(cancelRes.error, contains('tidak dapat dibatalkan'));
    expect(claimRepo.getById(r.claim!.id)!.status, ClaimStatus.diterima);
  });

  test('reconcile cancels claims of expired, deleted and sold-out listings', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    // 1. Expired listing
    final expiredListing = makeTestListing(
      id: 'listing-expired',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
      lifetime: const Duration(minutes: 20),
    );
    foodRepo.add(expiredListing);
    final claimExp = claimRepo.submitClaim(
      listing: expiredListing,
      claimantId: 'user-exp',
      claimantName: 'User Exp',
      quantity: 1,
    );
    expect(claimExp.claim!.status, ClaimStatus.menunggu);

    // 2. Deleted listing
    final deletedListing = makeTestListing(
      id: 'listing-deleted',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
    );
    foodRepo.add(deletedListing);
    final claimDel = claimRepo.submitClaim(
      listing: deletedListing,
      claimantId: 'user-del',
      claimantName: 'User Del',
      quantity: 1,
    );
    expect(claimDel.claim!.status, ClaimStatus.menunggu);

    // 3. Sold-out listing
    final soldOutListing = makeTestListing(
      id: 'listing-soldout',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
    );
    foodRepo.add(soldOutListing);
    final claimSold = claimRepo.submitClaim(
      listing: soldOutListing,
      claimantId: 'user-sold',
      claimantName: 'User Sold',
      quantity: 1,
    );
    expect(claimSold.claim!.status, ClaimStatus.menunggu);

    // Perform deletions and expiration
    foodRepo.delete(deletedListing.id);
    foodRepo.decreaseStock(soldOutListing.id, 5); // remaining becomes 0 (sold out)
    currentTime = currentTime.add(const Duration(minutes: 25)); // expires listing-expired

    claimRepo.reconcile();

    final cExp = claimRepo.getById(claimExp.claim!.id)!;
    expect(cExp.status, ClaimStatus.dibatalkan);
    expect(cExp.cancelReason, 'Waktu pengambilan sudah habis');

    final cDel = claimRepo.getById(claimDel.claim!.id)!;
    expect(cDel.status, ClaimStatus.dibatalkan);
    expect(cDel.cancelReason, 'Listing sudah dihapus');

    final cSold = claimRepo.getById(claimSold.claim!.id)!;
    expect(cSold.status, ClaimStatus.dibatalkan);
    expect(cSold.cancelReason, 'Makanan sudah habis diklaim');
  });

  test('reminder fires exactly once at the 30-minute boundary', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    // Listing expires in 30 minutes from currentTime
    final listing = makeTestListing(
      id: 'test-reminder',
      donorId: 'donor-1',
      total: 5,
      remaining: 5,
      createdAt: currentTime,
      lifetime: const Duration(minutes: 30),
    );
    foodRepo.add(listing);

    final r = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 1,
    );
    claimRepo.acceptClaim(r.claim!.id, actorId: 'donor-1');
    expect(claimRepo.getById(r.claim!.id)!.reminderSent, isFalse);

    final events = <ClaimEvent>[];
    claimRepo.onEvent = events.add;

    // Process reminders at exactly 30 minutes before expiry
    claimRepo.processReminders();

    expect(events.length, 1);
    expect(events.first.type, ClaimEventType.reminderDue);
    expect(events.first.claim.id, r.claim!.id);
    expect(claimRepo.getById(r.claim!.id)!.reminderSent, isTrue);

    // Process again -> should not fire again
    claimRepo.processReminders();
    expect(events.length, 1);
  });

  test('queuePosition values', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'test-queue-pos',
      total: 2,
      remaining: 2,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final c1 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-1',
      claimantName: 'User 1',
      quantity: 2,
    );
    expect(c1.claim!.status, ClaimStatus.menunggu);
    expect(claimRepo.queuePosition(c1.claim!.id), isNull);

    final c2 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-2',
      claimantName: 'User 2',
      quantity: 1,
    );
    final c3 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-3',
      claimantName: 'User 3',
      quantity: 1,
    );
    final c4 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'user-4',
      claimantName: 'User 4',
      quantity: 1,
    );

    expect(claimRepo.queuePosition(c2.claim!.id), 1);
    expect(claimRepo.queuePosition(c3.claim!.id), 2);
    expect(claimRepo.queuePosition(c4.claim!.id), 3);
    expect(claimRepo.queuePosition('unknown-claim-id'), isNull);
  });

  test('queries: getIncomingFor, getByClaimant, totalAcceptedQuantity', () {
    final foodRepo = FoodListingRepository();
    final claimRepo = ClaimRepository(foodRepo: foodRepo, clock: clock);

    final listing = makeTestListing(
      id: 'listing-query',
      donorId: 'donor-query',
      total: 10,
      remaining: 10,
      createdAt: currentTime,
    );
    foodRepo.add(listing);

    final r1 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'claimant-a',
      claimantName: 'Claimant A',
      quantity: 2,
    );
    final r2 = claimRepo.submitClaim(
      listing: listing,
      claimantId: 'claimant-b',
      claimantName: 'Claimant B',
      quantity: 3,
    );

    // getIncomingFor
    final incoming = claimRepo.getIncomingFor('donor-query');
    expect(incoming.length, 2);
    // newest first
    expect(incoming.first.id, r2.claim!.id);

    // getByClaimant
    final claimantAClaims = claimRepo.getByClaimant('claimant-a');
    expect(claimantAClaims.length, 1);
    expect(claimantAClaims.first.id, r1.claim!.id);

    // totalAcceptedQuantity
    expect(claimRepo.totalAcceptedQuantity('claimant-a'), 0);
    claimRepo.acceptClaim(r1.claim!.id, actorId: 'donor-query');
    expect(claimRepo.totalAcceptedQuantity('claimant-a'), 2);
  });
}
