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
}
