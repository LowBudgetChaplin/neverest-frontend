import '../../../app/services/api_client.dart';
import '../domain/reward_redemption_item.dart';

class RewardActionRepository {
  RewardActionRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<RewardRedemptionItem> redeem({
    required String rewardId,
    String? userId,
  }) async {
    try {
      final response =
          await _apiClient.post('/api/v1/rewards/$rewardId/redeem/me');
      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw ApiException('Invalid reward redemption payload.');
      }
      return RewardRedemptionItem.fromJson(payload);
    } on ApiException catch (error) {
      if (_shouldFallbackToUserId(error) &&
          userId != null &&
          userId.isNotEmpty) {
        final response = await _apiClient.post(
          '/api/v1/rewards/$rewardId/redeem',
          data: {'userId': userId},
        );
        final payload = response.data;
        if (payload is! Map<String, dynamic>) {
          throw ApiException('Invalid reward redemption payload.');
        }
        return RewardRedemptionItem.fromJson(payload);
      }
      rethrow;
    }
  }

  Future<List<RewardRedemptionItem>> getMyRedemptions({
    String? userId,
  }) async {
    try {
      final response = await _apiClient.get('/api/v1/rewards/redemptions/me');
      return _toRedemptionList(response.data);
    } on ApiException catch (error) {
      if (_shouldFallbackToUserId(error) &&
          userId != null &&
          userId.isNotEmpty) {
        final response = await _apiClient.get(
          '/api/v1/rewards/redemptions',
          queryParameters: {'userId': userId},
        );
        return _toRedemptionList(response.data);
      }
      rethrow;
    }
  }

  List<RewardRedemptionItem> _toRedemptionList(dynamic data) {
    if (data is! List) {
      throw ApiException('Invalid reward redemptions payload.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(RewardRedemptionItem.fromJson)
        .toList();
  }

  bool _shouldFallbackToUserId(ApiException error) {
    return error.statusCode == 400 ||
        error.statusCode == 401 ||
        error.statusCode == 403 ||
        error.statusCode == 404;
  }
}
