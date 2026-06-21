class EventCheckInResult {
  const EventCheckInResult({
    required this.eventId,
    required this.userId,
    required this.pointsAwarded,
    required this.updatedTotalPoints,
    this.userName,
    this.userAvatarB64,
    this.checkInCount,
    this.capacity,
  });

  factory EventCheckInResult.fromJson(Map<String, dynamic> json) {
    return EventCheckInResult(
      eventId: json['eventId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      pointsAwarded: (json['pointsAwarded'] as num?)?.toInt() ?? 0,
      updatedTotalPoints: (json['updatedTotalPoints'] as num?)?.toInt() ?? 0,
      userName: json['userName'] as String?,
      userAvatarB64: json['userAvatarB64'] as String?,
      checkInCount: (json['checkInCount'] as num?)?.toInt(),
      capacity: (json['capacity'] as num?)?.toInt(),
    );
  }

  final String eventId;
  final String userId;
  final int pointsAwarded;
  final int updatedTotalPoints;

  final String? userName;

  final String? userAvatarB64;

  final int? checkInCount;

  final int? capacity;
}
