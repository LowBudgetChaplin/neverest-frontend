import '../../../app/services/api_client.dart';
import '../domain/strava_models.dart';

class StravaRepository {
  StravaRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<StravaStatus> getStatus() async {
    final response = await _apiClient.get('/api/v1/strava/status');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return StravaStatus(
        connected: data['connected'] as bool? ?? false,
        athleteName: data['athleteName'] as String?,
        athleteCity: data['athleteCity'] as String?,
      );
    }
    return const StravaStatus(connected: false);
  }

  Future<String> getConnectUrl() async {
    final response = await _apiClient.get('/api/v1/strava/connect-url');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data['url'] as String? ?? '';
    }
    return '';
  }

  Future<StravaChallengeVerification> verifyChallengeOnStrava(String challengeId) async {
    final response = await _apiClient.get('/api/v1/strava/verify/challenge/$challengeId');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return StravaChallengeVerification.fromJson(data);
    }
    return const StravaChallengeVerification(
      stravaConnected: false,
      verified: false,
      verificationMessage: 'Eroare la verificare.',
      matchingActivities: [],
      requiredDistanceKm: 0,
    );
  }

  Future<void> disconnect() async {
    await _apiClient.delete('/api/v1/strava/disconnect');
  }
}
