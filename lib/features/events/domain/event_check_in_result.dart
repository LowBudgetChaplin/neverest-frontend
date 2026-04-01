class EventCheckInResult {
  const EventCheckInResult({
    required this.eventId,
    required this.userId,
    required this.pointsAwarded,
    required this.updatedTotalPoints,
  });

  factory EventCheckInResult.fromJson(Map<String, dynamic> json) {
    return EventCheckInResult(
      eventId: json['eventId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      pointsAwarded: (json['pointsAwarded'] as num?)?.toInt() ?? 0,
      updatedTotalPoints: (json['updatedTotalPoints'] as num?)?.toInt() ?? 0,
    );
  }

  final String eventId;
  final String userId;
  final int pointsAwarded;
  final int updatedTotalPoints;
}
