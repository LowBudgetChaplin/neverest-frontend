part of 'challenge_action_bloc.dart';

sealed class ChallengeActionEvent extends Equatable {
  const ChallengeActionEvent();

  @override
  List<Object?> get props => const [];
}

final class ChallengeSubmissionsLoadRequested extends ChallengeActionEvent {
  const ChallengeSubmissionsLoadRequested({
    required this.challengeId,
    required this.adminView,
    this.userId,
  });

  final String challengeId;
  final bool adminView;
  final String? userId;

  @override
  List<Object?> get props => [challengeId, adminView, userId];
}

final class ChallengeSubmissionSubmitRequested extends ChallengeActionEvent {
  const ChallengeSubmissionSubmitRequested({
    required this.challengeId,
    required this.proofText,
    required this.metricValue,
    this.userId,
  });

  final String challengeId;
  final String proofText;
  final double? metricValue;
  final String? userId;

  @override
  List<Object?> get props => [challengeId, proofText, metricValue, userId];
}

final class ChallengeSubmissionReviewRequested extends ChallengeActionEvent {
  const ChallengeSubmissionReviewRequested({
    required this.challengeId,
    required this.submissionId,
    required this.approved,
    this.reviewerNote,
    this.userId,
  });

  final String challengeId;
  final String submissionId;
  final bool approved;
  final String? reviewerNote;
  final String? userId;

  @override
  List<Object?> get props =>
      [challengeId, submissionId, approved, reviewerNote, userId];
}

final class ChallengeMessagesCleared extends ChallengeActionEvent {
  const ChallengeMessagesCleared();
}
