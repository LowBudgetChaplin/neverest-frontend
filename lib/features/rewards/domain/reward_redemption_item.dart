import 'package:equatable/equatable.dart';

class RewardRedemptionItem extends Equatable {
  const RewardRedemptionItem({
    required this.id,
    required this.rewardId,
    required this.userId,
    required this.rewardTitle,
    required this.pointsSpent,
    required this.redemptionCode,
    required this.redeemedAt,
    required this.userAvailablePointsAfterRedemption,
  });

  factory RewardRedemptionItem.fromJson(Map<String, dynamic> json) {
    return RewardRedemptionItem(
      id: json['id'] as String? ?? '',
      rewardId: json['rewardId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      rewardTitle: json['rewardTitle'] as String? ?? '',
      pointsSpent: (json['pointsSpent'] as num?)?.toInt() ?? 0,
      redemptionCode: json['redemptionCode'] as String? ?? '',
      redeemedAt: _toDateText(json['redeemedAt']),
      userAvailablePointsAfterRedemption:
          (json['userAvailablePointsAfterRedemption'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String rewardId;
  final String userId;
  final String rewardTitle;
  final int pointsSpent;
  final String redemptionCode;
  final String? redeemedAt;
  final int userAvailablePointsAfterRedemption;

  static String? _toDateText(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is String) {
      return value;
    }
    if (value is List) {
      return value.join('-');
    }
    return value.toString();
  }

  @override
  List<Object?> get props => [
        id,
        rewardId,
        userId,
        rewardTitle,
        pointsSpent,
        redemptionCode,
        redeemedAt,
        userAvailablePointsAfterRedemption,
      ];
}
