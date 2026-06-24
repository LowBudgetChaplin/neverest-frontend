import '../../../app/services/api_client.dart';
import '../domain/event_check_in_result.dart';

class EventParticipant {
  const EventParticipant({
    required this.userId,
    required this.name,
    this.avatarB64,
    this.checkedIn = false,
  });

  factory EventParticipant.fromJson(Map<String, dynamic> json) {
    return EventParticipant(
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '—',
      avatarB64: json['avatarB64'] as String?,
      checkedIn: json['checkedIn'] as bool? ?? false,
    );
  }

  final String userId;
  final String name;
  final String? avatarB64;
  final bool checkedIn;
}

class EventParticipants {
  const EventParticipants({
    required this.going,
    required this.count,
    required this.checkedInCount,
    required this.participants,
  });

  factory EventParticipants.fromJson(Map<String, dynamic> json) {
    final rawList = json['participants'] as List<dynamic>? ?? const [];
    final parsed = rawList
        .whereType<Map<String, dynamic>>()
        .map(EventParticipant.fromJson)
        .toList();
    return EventParticipants(
      going: json['going'] as bool? ?? false,
      count: (json['count'] as num?)?.toInt() ?? parsed.length,
      checkedInCount: (json['checkedInCount'] as num?)?.toInt() ??
          parsed.where((p) => p.checkedIn).length,
      participants: parsed,
    );
  }

  final bool going;
  final int count;
  final int checkedInCount;
  final List<EventParticipant> participants;
}

class EventActionRepository {
  EventActionRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<EventCheckInResult> checkIn({
    required String eventId,
    required String userQrCode,
  }) async {
    final normalizedQr = userQrCode.trim();
    if (normalizedQr.isEmpty) {
      throw ApiException('User QR code is required.');
    }

    final response = await _apiClient.post(
      '/api/v1/events/$eventId/check-ins',
      data: {'userQrCode': normalizedQr},
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw ApiException('Invalid check-in response payload.');
    }

    return EventCheckInResult.fromJson(payload);
  }

  Future<void> deleteEvent(String eventId) async {
    await _apiClient.delete('/api/v1/events/$eventId');
  }

  Future<EventParticipants> getParticipants(String eventId) async {
    final response = await _apiClient.get('/api/v1/events/$eventId/participants');
    return EventParticipants.fromJson(_asMap(response.data));
  }

  Future<EventParticipants> joinEvent(String eventId) async {
    final response =
        await _apiClient.post('/api/v1/events/$eventId/participants/me');
    return EventParticipants.fromJson(_asMap(response.data));
  }

  Future<EventParticipants> leaveEvent(String eventId) async {
    final response =
        await _apiClient.delete('/api/v1/events/$eventId/participants/me');
    return EventParticipants.fromJson(_asMap(response.data));
  }

  Map<String, dynamic> _asMap(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      throw ApiException('Invalid participants response payload.');
    }
    return payload;
  }

  Future<void> updateEvent({
    required String eventId,
    String? title,
    String? activityType,
    String? location,
    String? startsAtIso,
    int? pointsReward,
    int? capacity,
    bool clearCapacity = false,
    String? description,
    String? recurrence,
    String? routeMapUrl,
    String? stravaClubUrl,
    String? whatsappGroupUrl,
  }) async {
    await _apiClient.patch(
      '/api/v1/events/$eventId',
      data: {
        if (title != null) 'title': title.trim(),
        if (activityType != null) 'activityType': activityType,
        if (location != null) 'location': location.trim(),
        if (startsAtIso != null) 'startsAt': startsAtIso,
        if (pointsReward != null) 'pointsReward': pointsReward,
        if (capacity != null) 'capacity': capacity,
        if (clearCapacity) 'clearCapacity': true,
        if (description != null) 'description': description.trim(),
        if (recurrence != null) 'recurrence': recurrence,
        if (routeMapUrl != null) 'routeMapUrl': routeMapUrl.trim(),
        if (stravaClubUrl != null) 'stravaClubUrl': stravaClubUrl.trim(),
        if (whatsappGroupUrl != null) 'whatsappGroupUrl': whatsappGroupUrl.trim(),
      },
    );
  }
}
