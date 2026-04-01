import 'package:equatable/equatable.dart';

class ChallengeSubmissionItem extends Equatable {
  const ChallengeSubmissionItem({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.proofText,
    required this.metricValue,
    required this.status,
    required this.awardedPoints,
    required this.submittedAt,
    required this.reviewedAt,
    required this.reviewerNote,
  });

  factory ChallengeSubmissionItem.fromJson(Map<String, dynamic> json) {
    return ChallengeSubmissionItem(
      id: json['id'] as String? ?? '',
      challengeId: json['challengeId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      proofText: json['proofText'] as String? ?? '',
      metricValue: (json['metricValue'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'UNKNOWN',
      awardedPoints: (json['awardedPoints'] as num?)?.toInt() ?? 0,
      submittedAt: _toDateText(json['submittedAt']),
      reviewedAt: _toDateText(json['reviewedAt']),
      reviewerNote: json['reviewerNote'] as String?,
    );
  }

  final String id;
  final String challengeId;
  final String userId;
  final String proofText;
  final double? metricValue;
  final String status;
  final int awardedPoints;
  final String? submittedAt;
  final String? reviewedAt;
  final String? reviewerNote;

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
        challengeId,
        userId,
        proofText,
        metricValue,
        status,
        awardedPoints,
        submittedAt,
        reviewedAt,
        reviewerNote,
      ];
}
