part of 'challenge_action_bloc.dart';

final class ChallengeActionState extends Equatable {
  const ChallengeActionState({
    required this.isLoading,
    required this.isSubmitting,
    required this.isReviewing,
    required this.adminView,
    required this.submissions,
    this.errorMessage,
    this.successMessage,
  });

  const ChallengeActionState.initial()
      : this(
          isLoading: false,
          isSubmitting: false,
          isReviewing: false,
          adminView: false,
          submissions: const [],
        );

  final bool isLoading;
  final bool isSubmitting;
  final bool isReviewing;
  final bool adminView;
  final List<ChallengeSubmissionItem> submissions;
  final String? errorMessage;
  final String? successMessage;

  ChallengeActionState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isReviewing,
    bool? adminView,
    List<ChallengeSubmissionItem>? submissions,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ChallengeActionState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isReviewing: isReviewing ?? this.isReviewing,
      adminView: adminView ?? this.adminView,
      submissions: submissions ?? this.submissions,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        isReviewing,
        adminView,
        submissions,
        errorMessage,
        successMessage,
      ];
}
