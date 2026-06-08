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
  });

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    return EventSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled event',
      activityType: json['activityType'] as String? ?? 'UNKNOWN',
      location: json['location'] as String? ?? '-',
      startsAt: json['startsAt'] as String? ?? '',
      pointsReward: (json['pointsReward'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String title;
  final String activityType;
  final String location;
  final String startsAt;
  final int pointsReward;
}

class ChallengeSummary {
  const ChallengeSummary({
    required this.id,
    required this.title,
    required this.activityType,
    required this.frequency,
    required this.mode,
    required this.pointsReward,
  });

  factory ChallengeSummary.fromJson(Map<String, dynamic> json) {
    return ChallengeSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled challenge',
      activityType: json['activityType'] as String? ?? 'UNKNOWN',
      frequency: json['frequency'] as String? ?? 'UNKNOWN',
      mode: json['mode'] as String? ?? 'UNKNOWN',
      pointsReward: (json['pointsReward'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String title;
  final String activityType;
  final String frequency;
  final String mode;
  final int pointsReward;
}

class RewardSummary {
  const RewardSummary({
    required this.id,
    required this.title,
    required this.partnerName,
    required this.pointsCost,
    required this.stock,
    this.address,
  });

  factory RewardSummary.fromJson(Map<String, dynamic> json) {
    return RewardSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled reward',
      partnerName: json['partnerName'] as String? ?? 'Local partner',
      pointsCost: (json['pointsCost'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt(),
      address: json['address'] as String?,
    );
  }

  final String id;
  final String title;
  final String partnerName;
  final int pointsCost;
  final int? stock;
  final String? address;
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
