import '../../../app/services/api_client.dart';
import '../../dashboard/domain/dashboard_data.dart';
import '../domain/admin_models.dart';

class AdminRepository {
  AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthMeInfo> getAuthMe() async {
    final response = await _apiClient.get('/api/v1/auth/me');
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw ApiException('Invalid auth profile payload.');
    }
    return AuthMeInfo.fromJson(payload);
  }

  Future<List<UserAdminItem>> getUsers() async {
    final response = await _apiClient.get('/api/v1/users');
    return _toList<UserAdminItem>(
      response.data,
      mapper: UserAdminItem.fromJson,
      errorMessage: 'Invalid users payload.',
    );
  }

  Future<UserAdminItem> createUser({
    required String displayName,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/users',
      data: {'displayName': displayName.trim()},
    );
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw ApiException('Invalid user creation payload.');
    }
    return UserAdminItem.fromJson(payload);
  }

  Future<EventCreationResult> createEvent({
    required String title,
    required String activityType,
    required String location,
    required String startsAtIso,
    required int pointsReward,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/events',
      data: {
        'title': title.trim(),
        'activityType': activityType,
        'location': location.trim(),
        'startsAt': startsAtIso,
        'pointsReward': pointsReward,
      },
    );
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw ApiException('Invalid event creation payload.');
    }
    return EventCreationResult.fromJson(payload);
  }

  Future<List<AnnouncementDispatchItem>> retryAnnouncements({
    required String eventId,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/events/$eventId/announcements/retry',
    );
    return _toList<AnnouncementDispatchItem>(
      response.data,
      mapper: AnnouncementDispatchItem.fromJson,
      errorMessage: 'Invalid announcement retry payload.',
    );
  }

  Future<void> createChallenge({
    required String title,
    required String description,
    required String activityType,
    required String mode,
    required String frequency,
    required String startsAtIso,
    required String endsAtIso,
    required int pointsReward,
    required double? targetValue,
    required String? targetUnit,
  }) async {
    await _apiClient.post(
      '/api/v1/challenges',
      data: {
        'title': title.trim(),
        'description': description.trim(),
        'activityType': activityType,
        'mode': mode,
        'frequency': frequency,
        'startsAt': startsAtIso,
        'endsAt': endsAtIso,
        'pointsReward': pointsReward,
        'targetValue': targetValue,
        'targetUnit':
            (targetUnit ?? '').trim().isEmpty ? null : targetUnit!.trim(),
      },
    );
  }

  Future<void> createReward({
    required String title,
    required String partnerName,
    required String description,
    required int pointsCost,
    required int? stock,
  }) async {
    await _apiClient.post(
      '/api/v1/rewards',
      data: {
        'title': title.trim(),
        'partnerName': partnerName.trim(),
        'description': description.trim(),
        'pointsCost': pointsCost,
        'stock': stock,
      },
    );
  }

  Future<List<AuditLogItem>> getAuditLogs({
    int limit = 50,
    String? action,
    String? actor,
    bool? success,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/admin/audit-logs',
      queryParameters: {
        'limit': limit,
        if (action != null && action.trim().isNotEmpty) 'action': action.trim(),
        if (actor != null && actor.trim().isNotEmpty) 'actor': actor.trim(),
        if (success != null) 'success': success,
      },
    );
    return _toList<AuditLogItem>(
      response.data,
      mapper: AuditLogItem.fromJson,
      errorMessage: 'Invalid audit logs payload.',
    );
  }

  Future<List<LeaderboardEntrySummary>> getActivityLeaderboard({
    required String activityType,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/api/v1/leaderboard/activity/$activityType',
      queryParameters: {'limit': limit},
    );
    return _toList<LeaderboardEntrySummary>(
      response.data,
      mapper: LeaderboardEntrySummary.fromJson,
      errorMessage: 'Invalid activity leaderboard payload.',
    );
  }

  List<T> _toList<T>(
    dynamic payload, {
    required T Function(Map<String, dynamic> json) mapper,
    required String errorMessage,
  }) {
    if (payload is! List) {
      throw ApiException(errorMessage);
    }

    return payload.whereType<Map<String, dynamic>>().map(mapper).toList();
  }
}
