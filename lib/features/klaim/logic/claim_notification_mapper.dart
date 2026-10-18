import '../../../core/app_session.dart';
import '../../donasi/data/food_listing.dart';
import '../../donasi/data/food_listing_repository.dart';
import '../../lokasi/data/pickup_point.dart';
import '../../lokasi/data/pickup_point_repository.dart';
import '../../notifikasi/data/app_notification.dart';
import '../data/claim.dart';

/// Pure function that maps a [ClaimEvent] to an [AppNotification] (or null).
AppNotification? mapClaimEventToNotification(
  ClaimEvent event, {
  FoodListingRepository? foodRepo,
  PickupPointRepository? pickupRepo,
  FoodListing? listing,
  PickupPoint? pickupPoint,
  DateTime? now,
}) {
  final claim = event.claim;

  // Return null when claim.claimantId != kCurrentUserId, because this app has a single in-memory user.
  if (claim.claimantId != kCurrentUserId) {
    return null;
  }

  final resolvedFood = listing ?? foodRepo?.getById(claim.listingId);
  final resolvedPickup = pickupPoint ??
      (resolvedFood != null ? pickupRepo?.getById(resolvedFood.pickupPointId) : null);
  final currentTime = now ?? DateTime.now();

  final foodName = resolvedFood?.name ?? 'Makanan Surplus';

  switch (event.type) {
    case ClaimEventType.submitted:
      return null;

    case ClaimEventType.accepted:
      final hour = resolvedFood?.expiresAt.hour.toString().padLeft(2, '0') ?? '18';
      final minute = resolvedFood?.expiresAt.minute.toString().padLeft(2, '0') ?? '00';
      final timeStr = '$hour:$minute';
      final unit = resolvedFood?.unit ?? 'porsi';
      return AppNotification(
        id: 'notif-${claim.id}-${event.type.name}-${currentTime.microsecondsSinceEpoch}',
        type: AppNotificationType.claimStatus,
        title: 'Klaim diterima!',
        body: 'Klaim ${claim.quantity} $unit $foodName diterima. Ambil sebelum $timeStr.',
        createdAt: currentTime,
        isRead: false,
        refId: claim.id,
      );

    case ClaimEventType.rejected:
      final reason = claim.rejectReason?.trim();
      final reasonSuffix = (reason != null && reason.isNotEmpty)
          ? (reason.toLowerCase().startsWith('alasan:') ? ' $reason' : ' Alasan: $reason')
          : '';
      return AppNotification(
        id: 'notif-${claim.id}-${event.type.name}-${currentTime.microsecondsSinceEpoch}',
        type: AppNotificationType.claimStatus,
        title: 'Klaim ditolak',
        body: 'Klaim $foodName ditolak pendonor.$reasonSuffix',
        createdAt: currentTime,
        isRead: false,
        refId: claim.id,
      );

    case ClaimEventType.promoted:
      return AppNotification(
        id: 'notif-${claim.id}-${event.type.name}-${currentTime.microsecondsSinceEpoch}',
        type: AppNotificationType.claimStatus,
        title: 'Klaimmu maju dari antrean',
        body: 'Klaim $foodName kini menunggu persetujuan pendonor.',
        createdAt: currentTime,
        isRead: false,
        refId: claim.id,
      );

    case ClaimEventType.cancelled:
      final isUserCancel = claim.cancelReason == null ||
          claim.cancelReason == 'Dibatalkan oleh pemohon' ||
          claim.cancelReason == 'Dibatalkan oleh mahasiswa';
      return AppNotification(
        id: 'notif-${claim.id}-${event.type.name}-${currentTime.microsecondsSinceEpoch}',
        type: AppNotificationType.claimStatus,
        title: 'Klaim dibatalkan',
        body: isUserCancel
            ? 'Kamu membatalkan klaim $foodName.'
            : (claim.cancelReason ?? 'Kamu membatalkan klaim $foodName.'),
        createdAt: currentTime,
        isRead: false,
        refId: claim.id,
      );

    case ClaimEventType.autoCancelled:
      return AppNotification(
        id: 'notif-${claim.id}-${event.type.name}-${currentTime.microsecondsSinceEpoch}',
        type: AppNotificationType.claimStatus,
        title: 'Klaim dibatalkan',
        body: claim.cancelReason ?? 'Kamu membatalkan klaim $foodName.',
        createdAt: currentTime,
        isRead: false,
        refId: claim.id,
      );

    case ClaimEventType.reminderDue:
      // TODO(stub): reminders are in-app only and fire only while the app is running; OS-level scheduled notifications are not implemented
      final minutesLeft = resolvedFood != null
          ? resolvedFood.expiresAt.difference(currentTime).inMinutes.clamp(0, 9999)
          : 30;
      final pickupName = resolvedPickup?.name ?? 'titik pengambilan';
      return AppNotification(
        id: 'notif-${claim.id}-${event.type.name}-${currentTime.microsecondsSinceEpoch}',
        type: AppNotificationType.reminder,
        title: 'Waktu pengambilan hampir habis',
        body: '$foodName: sisa $minutesLeft menit untuk mengambil di $pickupName.',
        createdAt: currentTime,
        isRead: false,
        refId: claim.id,
      );
  }
}

