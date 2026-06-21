import '../../../app/services/api_client.dart';
import '../domain/challenge_submission_item.dart';

class ChallengeActionRepository {
  ChallengeActionRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ChallengeSubmissionItem>> getSubmissions({
    required String challengeId,
    required bool adminView,
    String? userId,
  }) async {
    if (adminView) {
      final response =
          await _apiClient.get('/api/v1/challenges/$challengeId/submissions');
      return _toSubmissionList(response.data);
    }

    try {
      final response = await _apiClient
          .get('/api/v1/challenges/$challengeId/submissions/me');
      return _toSubmissionList(response.data);
    } on ApiException catch (error) {
      if (_shouldFallbackToUserId(error) &&
          userId != null &&
          userId.isNotEmpty) {
        final response = await _apiClient.get(
          '/api/v1/challenges/$challengeId/submissions',
          queryParameters: {'userId': userId},
        );
        return _toSubmissionList(response.data);
      }
      rethrow;
    }
  }

  Future<ChallengeSubmissionItem> submit({
    required String challengeId,
    required String proofText,
    required double? metricValue,
    String? userId,
  }) async {
    final normalizedProof = proofText.trim();
    if (normalizedProof.isEmpty) {
      throw ApiException('Proof text is required.');
    }

    try {
      final response = await _apiClient.post(
        '/api/v1/challenges/$challengeId/submissions/me',
        data: {
          'proofText': normalizedProof,
          'metricValue': metricValue,
        },
      );
      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw ApiException('Invalid challenge submission payload.');
      }
      return ChallengeSubmissionItem.fromJson(payload);
    } on ApiException catch (error) {
      if (_shouldFallbackToUserId(error) &&
          userId != null &&
          userId.isNotEmpty) {
        final response = await _apiClient.post(
          '/api/v1/challenges/$challengeId/submissions',
          data: {
            'userId': userId,
            'proofText': normalizedProof,
            'metricValue': metricValue,
          },
        );
        final payload = response.data;
        if (payload is! Map<String, dynamic>) {
          throw ApiException('Invalid challenge submission payload.');
        }
        return ChallengeSubmissionItem.fromJson(payload);
      }
      rethrow;
    }
  }

  Future<ChallengeSubmissionItem> reviewSubmission({
    required String challengeId,
    required String submissionId,
    required bool approved,
    String? reviewerNote,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/challenges/$challengeId/submissions/$submissionId/review',
      data: {
        'approved': approved,
        'reviewerNote':
            reviewerNote?.trim().isEmpty ?? true ? null : reviewerNote!.trim(),
      },
    );
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw ApiException('Invalid challenge review payload.');
    }
    return ChallengeSubmissionItem.fromJson(payload);
  }

  Future<void> deleteChallenge(String challengeId) async {
    await _apiClient.delete('/api/v1/challenges/$challengeId');
  }

  Future<void> updateChallenge({
    required String challengeId,
    String? title,
    String? description,
    String? activityType,
    int? pointsReward,
    double? targetValue,
    String? targetUnit,
    String? startsAtIso,
    String? endsAtIso,
  }) async {
    await _apiClient.patch(
      '/api/v1/challenges/$challengeId',
      data: {
        if (title != null) 'title': title.trim(),
        if (description != null) 'description': description.trim(),
        if (activityType != null) 'activityType': activityType,
        if (pointsReward != null) 'pointsReward': pointsReward,
        if (targetValue != null) 'targetValue': targetValue,
        if (targetUnit != null) 'targetUnit': targetUnit.trim(),
        if (startsAtIso != null) 'startsAt': startsAtIso,
        if (endsAtIso != null) 'endsAt': endsAtIso,
      },
    );
  }

  List<ChallengeSubmissionItem> _toSubmissionList(dynamic data) {
    if (data is! List) {
      throw ApiException('Invalid challenge submissions payload.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(ChallengeSubmissionItem.fromJson)
        .toList();
  }

  bool _shouldFallbackToUserId(ApiException error) {
    return error.statusCode == 400 ||
        error.statusCode == 401 ||
        error.statusCode == 403 ||
        error.statusCode == 404;
  }
}
