import '../../../app/services/api_client.dart';
import '../domain/event_check_in_result.dart';

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
