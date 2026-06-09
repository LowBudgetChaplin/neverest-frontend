class DashboardData {
  const DashboardData({
    required this.backendMessage,
    required this.events,
    required this.challenges,
    required this.rewards,
    required this.leaderboard,
  });

  final String backendMessage;
  final List<EventSummary> events;
  final List<ChallengeSummary> challenges;
  final List<RewardSummary> rewards;
  final List<LeaderboardEntrySummary> leaderboard;
}

class EventSummary {
  const EventSummary({
    required this.id,
    required this.title,
    required this.activityType,
    required this.location,
    required this.startsAt,
    required this.pointsReward,
    this.capacity,
    this.attendeeCount = 0,
    this.description,
    this.recurrence,
    this.routeMapUrl,
    this.stravaClubUrl,
    this.whatsappGroupUrl,
  });

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled event',
      activityType: json['activityType'] as String? ?? 'UNKNOWN',
      location: json['location'] as String? ?? '-',
      startsAt: json['startsAt'] as String? ?? '',
      pointsReward: (json['pointsReward'] as num?)?.toInt() ?? 0,
      capacity: (json['capacity'] as num?)?.toInt(),
      attendeeCount: (json['attendeeCount'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      recurrence: json['recurrence'] as String?,
      routeMapUrl: json['routeMapUrl'] as String?,
      stravaClubUrl: json['stravaClubUrl'] as String?,
      whatsappGroupUrl: json['whatsappGroupUrl'] as String?,
    );
  }

  final String id;
  final String title;
  final String activityType;
  final String location;
  final String startsAt;
  final int pointsReward;
  final int? capacity;
  final int attendeeCount;
  final String? description;
  final String? recurrence;

  /// Locuri ramase, daca evenimentul are capacitate setata.
  int? get spotsLeft {
    final cap = capacity;
    if (cap == null) return null;
    final left = cap - attendeeCount;
    return left < 0 ? 0 : left;
  }
  final String? routeMapUrl;
  final String? stravaClubUrl;
  final String? whatsappGroupUrl;
}

class ChallengeSummary {
  const ChallengeSummary({
    required this.id,
    required this.title,
    required this.activityType,
    required this.frequency,
    required this.mode,
    required this.pointsReward,
    this.description,
    this.startsAt,
    this.endsAt,
    this.targetValue,
    this.targetUnit,
    this.completed = false,
  });

  factory ChallengeSummary.fromJson(Map<String, dynamic> json) {
    return ChallengeSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled challenge',
      activityType: json['activityType'] as String? ?? 'UNKNOWN',
      frequency: json['frequency'] as String? ?? 'UNKNOWN',
      mode: json['mode'] as String? ?? 'UNKNOWN',
      pointsReward: (json['pointsReward'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      startsAt: json['startsAt'] as String?,
      endsAt: json['endsAt'] as String?,
      targetValue: (json['targetValue'] as num?)?.toDouble(),
      targetUnit: json['targetUnit'] as String?,
      completed: json['completed'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String activityType;
  final String frequency;
  final String mode;
  final int pointsReward;
  final String? description;
  final String? startsAt;
  final String? endsAt;
  final double? targetValue;
  final String? targetUnit;
  final bool completed;
}

class RewardSummary {
  const RewardSummary({
    required this.id,
    required this.title,
    required this.partnerName,
    required this.pointsCost,
    required this.stock,
    this.address,
    this.description,
    this.imageB64,
  });

  factory RewardSummary.fromJson(Map<String, dynamic> json) {
    return RewardSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled reward',
      partnerName: json['partnerName'] as String? ?? 'Local partner',
      pointsCost: (json['pointsCost'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt(),
      address: json['address'] as String?,
      description: json['description'] as String?,
      imageB64: json['imageB64'] as String?,
    );
  }

  final String id;
  final String title;
  final String partnerName;
  final int pointsCost;
  final int? stock;
  final String? address;
  final String? description;

  /// Imaginea recompensei ca data URI base64 (null = se folosesc cercurile default).
  final String? imageB64;
}

class LeaderboardEntrySummary {
  const LeaderboardEntrySummary({
    required this.userId,
    required this.displayName,
    required this.points,
  });

  factory LeaderboardEntrySummary.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntrySummary(
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Unknown user',
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }

  final String userId;
  final String displayName;
  final int points;
}
