enum AppNotificationType { newListing, claimStatus, reminder }

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.refId,
  });

  final String id;
  final AppNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? refId;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      refId: refId,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>?;
    AppNotificationType parseType(String? t) {
      if (t == 'NEW_DONATION') return AppNotificationType.newListing;
      if (t == 'PICKUP_REMINDER_30M') return AppNotificationType.reminder;
      return AppNotificationType.claimStatus;
    }

    final createdAtRaw = json['createdAt'] ?? json['created_at'];

    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: parseType(metadata?['type']?.toString()),
      title: json['title']?.toString() ?? 'Notifikasi BagiRasa',
      body: json['body']?.toString() ?? '',
      createdAt: createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw.toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] == true || json['is_read'] == true,
      refId: metadata?['claimId']?.toString() ?? metadata?['donationId']?.toString(),
    );
  }
}
