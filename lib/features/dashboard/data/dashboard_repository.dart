import '../../../app/services/api_client.dart';
import '../domain/dashboard_data.dart';

class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DashboardData> fetchDashboardData() async {
    final backendMessage = await _fetchBackendMessage();
    final responses = await Future.wait<dynamic>([
      _apiClient.get('/api/v1/events'),
      _apiClient.get('/api/v1/challenges'),
      _apiClient.get('/api/v1/rewards'),
      _apiClient.get(
        '/api/v1/leaderboard/general',
        queryParameters: {'limit': 20},
      ),
    ]);

    final eventsResponse = responses[0].data as List<dynamic>? ?? const [];
    final challengesResponse = responses[1].data as List<dynamic>? ?? const [];
    final rewardsResponse = responses[2].data as List<dynamic>? ?? const [];
    final leaderboardResponse = responses[3].data as List<dynamic>? ?? const [];

    return DashboardData(
      backendMessage: backendMessage,
      events: eventsResponse
          .whereType<Map<String, dynamic>>()
          .map(EventSummary.fromJson)
          .toList(),
      challenges: challengesResponse
          .whereType<Map<String, dynamic>>()
          .map(ChallengeSummary.fromJson)
          .toList(),
      rewards: rewardsResponse
          .whereType<Map<String, dynamic>>()
          .map(RewardSummary.fromJson)
          .toList(),
      leaderboard: leaderboardResponse
          .whereType<Map<String, dynamic>>()
          .map(LeaderboardEntrySummary.fromJson)
          .toList(),
    );
  }

  Future<String> _fetchBackendMessage() async {
    try {
      final response = await _apiClient.get(
        '/hello',
        skipAuthFailureHandling: true,
      );
      final payload = response.data;
      if (payload is String && payload.trim().isNotEmpty) {
        return payload;
      }
      if (payload is Map<String, dynamic>) {
        final message = payload['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
    } catch (_) {
      // Keep dashboard resilient even if optional health endpoint is absent.
    }
    return 'Backend reachable';
  }
}
