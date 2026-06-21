import '../../../app/services/api_client.dart';
import '../../dashboard/domain/dashboard_data.dart';

class PartnerRepository {
  PartnerRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<OfferSummary>> getMyOffers() async {
    final response = await _apiClient.get('/api/v1/offers/mine');
    final data = response.data;
    if (data is! List) {
      throw ApiException('Invalid offers payload.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(OfferSummary.fromJson)
        .toList();
  }

  Future<OfferSummary> createOffer({
    required String brand,
    required String title,
    String? description,
    String? discountLabel,
    String? imageB64,
    String? linkUrl,
    String? validFromIso,
    String? validUntilIso,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/offers',
      data: {
        'brand': brand.trim(),
        'title': title.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        if (discountLabel != null && discountLabel.trim().isNotEmpty)
          'discountLabel': discountLabel.trim(),
        if (imageB64 != null) 'imageB64': imageB64,
        if (linkUrl != null && linkUrl.trim().isNotEmpty) 'linkUrl': linkUrl.trim(),
        if (validFromIso != null) 'validFrom': validFromIso,
        if (validUntilIso != null) 'validUntil': validUntilIso,
        'active': true,
      },
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException('Invalid offer creation payload.');
    }
    return OfferSummary.fromJson(data);
  }

  Future<OfferSummary> updateOffer({
    required String offerId,
    required String brand,
    required String title,
    String? description,
    String? discountLabel,
    String? imageB64,
    String? linkUrl,
    String? validFromIso,
    String? validUntilIso,
  }) async {
    final response = await _apiClient.patch(
      '/api/v1/offers/$offerId',
      data: {
        'brand': brand.trim(),
        'title': title.trim(),
        'description': description?.trim() ?? '',
        'discountLabel': discountLabel?.trim() ?? '',
        'linkUrl': linkUrl?.trim() ?? '',
        if (imageB64 != null) 'imageB64': imageB64,
        if (validFromIso != null) 'validFrom': validFromIso,
        if (validUntilIso != null) 'validUntil': validUntilIso,
        'active': true,
      },
    );
    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw ApiException('Invalid offer update payload.');
    }
    return OfferSummary.fromJson(data);
  }

  Future<void> deleteOffer(String offerId) async {
    await _apiClient.delete('/api/v1/offers/$offerId');
  }

  Future<List<ChallengeSummary>> getMyChallenges() async {
    final response = await _apiClient.get('/api/v1/partner-challenges/mine');
    final data = response.data;
    if (data is! List) {
      throw ApiException('Invalid challenges payload.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(ChallengeSummary.fromJson)
        .toList();
  }

  Future<void> createChallenge({
    required String title,
    required String description,
    required String activityType,
    required String rewardLabel,
    String rewardKind = 'DISCOUNT',
    String? brand,
    String? startsAtIso,
    String? endsAtIso,
  }) async {
    await _apiClient.post(
      '/api/v1/partner-challenges',
      data: {
        'title': title.trim(),
        'description': description.trim(),
        'activityType': activityType,
        'rewardKind': rewardKind,
        'rewardLabel': rewardLabel.trim(),
        if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
        if (startsAtIso != null) 'startsAt': startsAtIso,
        if (endsAtIso != null) 'endsAt': endsAtIso,
      },
    );
  }

  Future<void> updateChallenge({
    required String challengeId,
    required String title,
    required String description,
    required String activityType,
    required String rewardLabel,
    String rewardKind = 'DISCOUNT',
    String? brand,
    String? startsAtIso,
    String? endsAtIso,
  }) async {
    await _apiClient.patch(
      '/api/v1/partner-challenges/$challengeId',
      data: {
        'title': title.trim(),
        'description': description.trim(),
        'activityType': activityType,
        'rewardKind': rewardKind,
        'rewardLabel': rewardLabel.trim(),
        if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
        if (startsAtIso != null) 'startsAt': startsAtIso,
        if (endsAtIso != null) 'endsAt': endsAtIso,
      },
    );
  }

  Future<void> deleteChallenge(String challengeId) async {
    await _apiClient.delete('/api/v1/partner-challenges/$challengeId');
  }

  Future<List<RewardSummary>> getMyRewards() async {
    final response = await _apiClient.get('/api/v1/partner-rewards/mine');
    final data = response.data;
    if (data is! List) {
      throw ApiException('Invalid rewards payload.');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(RewardSummary.fromJson)
        .toList();
  }

  Future<void> createReward({
    required String title,
    required String partnerName,
    required String description,
    required int pointsCost,
    int? stock,
    int? rotationDays,
  }) async {
    await _apiClient.post(
      '/api/v1/partner-rewards',
      data: {
        'title': title.trim(),
        'partnerName': partnerName.trim(),
        'description': description.trim(),
        'pointsCost': pointsCost,
        if (stock != null) 'stock': stock,
        if (rotationDays != null) 'rotationDays': rotationDays,
      },
    );
  }

  Future<void> updateReward({
    required String rewardId,
    String? title,
    String? partnerName,
    String? description,
    int? pointsCost,
    int? stock,
    int? rotationDays,
  }) async {
    await _apiClient.patch(
      '/api/v1/partner-rewards/$rewardId',
      data: {
        if (title != null) 'title': title.trim(),
        if (partnerName != null) 'partnerName': partnerName.trim(),
        if (description != null) 'description': description.trim(),
        if (pointsCost != null) 'pointsCost': pointsCost,
        if (stock != null) 'stock': stock,
        if (rotationDays != null) 'rotationDays': rotationDays,
      },
    );
  }

  Future<void> deleteReward(String rewardId) async {
    await _apiClient.delete('/api/v1/partner-rewards/$rewardId');
  }

  Future<RedemptionValidation> validateCode(String code) async {
    final response = await _apiClient.post(
      '/api/v1/rewards/redemptions/validate',
      data: {'code': code.trim()},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return RedemptionValidation.fromJson(data);
    }
    throw ApiException('Invalid validation payload.');
  }
}

class RedemptionValidation {
  const RedemptionValidation({
    required this.valid,
    required this.status,
    this.rewardTitle,
    this.userName,
    this.code,
  });

  factory RedemptionValidation.fromJson(Map<String, dynamic> json) {
    return RedemptionValidation(
      valid: json['valid'] as bool? ?? false,
      status: json['status'] as String? ?? 'UNKNOWN',
      rewardTitle: json['rewardTitle'] as String?,
      userName: json['userName'] as String?,
      code: json['code'] as String?,
    );
  }

  final bool valid;
  final String status;
  final String? rewardTitle;
  final String? userName;
  final String? code;
}
