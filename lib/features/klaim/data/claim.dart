enum ClaimStatus { menunggu, antre, diterima, ditolak, dibatalkan }

class Claim {
  const Claim({
    required this.id,
    required this.listingId,
    required this.claimantId,
    required this.claimantName,
    required this.quantity,
    required this.status,
    required this.seq,
    required this.createdAt,
    this.decidedAt,
    this.rejectReason,
    this.cancelReason,
    this.reminderSent = false,
  });

  final String id;
  final String listingId;
  final String claimantId;
  final String claimantName;
  final int quantity;
  final ClaimStatus status;
  final int seq;
  final DateTime createdAt;
  final DateTime? decidedAt;
  final String? rejectReason;
  final String? cancelReason;
  final bool reminderSent;

  Claim copyWith({
    String? id,
    String? listingId,
    String? claimantId,
    String? claimantName,
    int? quantity,
    ClaimStatus? status,
    int? seq,
    DateTime? createdAt,
    DateTime? decidedAt,
    String? rejectReason,
    String? cancelReason,
    bool? reminderSent,
  }) {
    return Claim(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      claimantId: claimantId ?? this.claimantId,
      claimantName: claimantName ?? this.claimantName,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      seq: seq ?? this.seq,
      createdAt: createdAt ?? this.createdAt,
      decidedAt: decidedAt ?? this.decidedAt,
      rejectReason: rejectReason ?? this.rejectReason,
      cancelReason: cancelReason ?? this.cancelReason,
      reminderSent: reminderSent ?? this.reminderSent,
    );
  }
}

enum ClaimEventType {
  submitted,
  accepted,
  rejected,
  promoted,
  cancelled,
  autoCancelled,
  reminderDue,
}

class ClaimEvent {
  const ClaimEvent({
    required this.type,
    required this.claim,
  });

  final ClaimEventType type;
  final Claim claim;
}

class ClaimResult {
  const ClaimResult({
    required this.ok,
    this.error,
    this.claim,
  });

  factory ClaimResult.success(Claim claim) =>
      ClaimResult(ok: true, claim: claim);

  factory ClaimResult.failure(String error) =>
      ClaimResult(ok: false, error: error);

  final bool ok;
  final String? error;
  final Claim? claim;
}

