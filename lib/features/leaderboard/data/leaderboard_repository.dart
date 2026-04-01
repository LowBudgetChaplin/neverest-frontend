import '../../../app/services/api_client.dart';
import '../../dashboard/domain/dashboard_data.dart';

class LeaderboardRepository {
  LeaderboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<LeaderboardEntrySummary>> getActivityLeaderboard({
    required String activityType,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/leaderboard/activity/$activityType',
      queryParameters: {'limit': limit},
    );
    final payload = response.data;
    if (payload is! List) {
      throw ApiException('Invalid activity leaderboard payload.');
    }
    return payload
        .whereType<Map<String, dynamic>>()
        .map(LeaderboardEntrySummary.fromJson)
        .toList();
  }
}
