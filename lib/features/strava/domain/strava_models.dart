class StravaChallengeVerification {
  const StravaChallengeVerification({
    required this.stravaConnected,
    required this.verified,
    required this.verificationMessage,
    required this.matchingActivities,
    required this.requiredDistanceKm,
  });

  factory StravaChallengeVerification.fromJson(Map<String, dynamic> json) {
    final activitiesRaw = json['matchingActivities'] as List? ?? [];
    return StravaChallengeVerification(
      stravaConnected: json['stravaConnected'] as bool? ?? false,
      verified: json['verified'] as bool? ?? false,
      verificationMessage: json['verificationMessage'] as String? ?? '',
      matchingActivities: activitiesRaw
          .whereType<Map<String, dynamic>>()
          .map(StravaActivity.fromJson)
          .toList(),
      requiredDistanceKm: (json['requiredDistanceKm'] as num?)?.toDouble() ?? 0,
    );
  }

  final bool stravaConnected;
  final bool verified;
  final String verificationMessage;
  final List<StravaActivity> matchingActivities;
  final double requiredDistanceKm;
}

class StravaStatus {
  const StravaStatus({
    required this.connected,
    this.athleteName,
    this.athleteCity,
  });

  final bool connected;
  final String? athleteName;
  final String? athleteCity;
}

class StravaActivity {
  const StravaActivity({
    required this.stravaId,
    required this.name,
    required this.type,
    required this.distanceMeters,
    required this.movingTimeSeconds,
    required this.startDateLocal,
    required this.averageSpeedMs,
    required this.totalElevationGain,
    this.startLatLng,
    this.endLatLng,
  });

  factory StravaActivity.fromJson(Map<String, dynamic> json) {
    List<double>? parseLatLng(dynamic v) {
      if (v is List && v.length >= 2) {
        return [
          (v[0] as num).toDouble(),
          (v[1] as num).toDouble(),
        ];
      }
      return null;
    }

    return StravaActivity(
      stravaId: (json['stravaId'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Activity',
      type: json['type'] as String? ?? 'Run',
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      movingTimeSeconds: (json['movingTimeSeconds'] as num?)?.toInt() ?? 0,
      startDateLocal: json['startDateLocal'] as String? ?? '',
      averageSpeedMs: (json['averageSpeedMs'] as num?)?.toDouble() ?? 0,
      totalElevationGain: (json['totalElevationGain'] as num?)?.toDouble() ?? 0,
      startLatLng: parseLatLng(json['startLatLng']),
      endLatLng: parseLatLng(json['endLatLng']),
    );
  }

  final int stravaId;
  final String name;
  final String type;
  final double distanceMeters;
  final int movingTimeSeconds;
  final String startDateLocal;
  final double averageSpeedMs;
  final double totalElevationGain;
  final List<double>? startLatLng;
  final List<double>? endLatLng;

  double get distanceKm => distanceMeters / 1000;

  String get formattedPace {
    if (averageSpeedMs <= 0) return '-';
    final secsPerKm = (1000 / averageSpeedMs).round();
    final min = secsPerKm ~/ 60;
    final sec = secsPerKm % 60;
    return '$min:${sec.toString().padLeft(2, '0')} /km';
  }

  String get formattedDuration {
    final h = movingTimeSeconds ~/ 3600;
    final m = (movingTimeSeconds % 3600) ~/ 60;
    final s = movingTimeSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m ${s}s';
  }
}
