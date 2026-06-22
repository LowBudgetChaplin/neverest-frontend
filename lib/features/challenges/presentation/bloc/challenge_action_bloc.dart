import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/services/api_client.dart';
import '../../data/challenge_action_repository.dart';
import '../../domain/challenge_submission_item.dart';

part 'challenge_action_event.dart';
part 'challenge_action_state.dart';

class ChallengeActionBloc
    extends Bloc<ChallengeActionEvent, ChallengeActionState> {
  ChallengeActionBloc({required ChallengeActionRepository repository})
      : _repository = repository,
        super(const ChallengeActionState.initial()) {
    on<ChallengeSubmissionsLoadRequested>(_onLoadRequested);
    on<ChallengeSubmissionSubmitRequested>(_onSubmitRequested);
    on<ChallengeSubmissionReviewRequested>(_onReviewRequested);
    on<ChallengeMessagesCleared>(_onMessagesCleared);
  }

  final ChallengeActionRepository _repository;

  Future<void> _onLoadRequested(
    ChallengeSubmissionsLoadRequested event,
    Emitter<ChallengeActionState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        adminView: event.adminView,
        clearMessages: true,
      ),
    );

    try {
      final submissions = await _repository.getSubmissions(
        challengeId: event.challengeId,
        adminView: event.adminView,
        userId: event.userId,
      );

      emit(
        state.copyWith(
          isLoading: false,
          submissions: submissions,
          adminView: event.adminView,
          clearMessages: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          feedback: ChallengeFeedback.loadFailed,
        ),
      );
    }
  }

  Future<void> _onSubmitRequested(
    ChallengeSubmissionSubmitRequested event,
    Emitter<ChallengeActionState> emit,
  ) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));

    try {
      final result = await _repository.submit(
        challengeId: event.challengeId,
        proofText: event.proofText,
        metricValue: event.metricValue,
        userId: event.userId,
      );

      final submissions = await _repository.getSubmissions(
        challengeId: event.challengeId,
        adminView: false,
        userId: event.userId,
      );

      final approved = result.status.toUpperCase() == 'APPROVED';
      emit(
        state.copyWith(
          isSubmitting: false,
          submissions: submissions,
          adminView: false,
          feedback: approved
              ? ChallengeFeedback.submitApproved
              : ChallengeFeedback.submitPending,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          feedback: ChallengeFeedback.submitFailed,
        ),
      );
    }
  }

  Future<void> _onReviewRequested(
    ChallengeSubmissionReviewRequested event,
    Emitter<ChallengeActionState> emit,
  ) async {
    emit(state.copyWith(isReviewing: true, clearMessages: true));

    try {
      await _repository.reviewSubmission(
        challengeId: event.challengeId,
        submissionId: event.submissionId,
        approved: event.approved,
        reviewerNote: event.reviewerNote,
      );

      final submissions = await _repository.getSubmissions(
        challengeId: event.challengeId,
        adminView: true,
        userId: event.userId,
      );

      emit(
        state.copyWith(
          isReviewing: false,
          submissions: submissions,
          adminView: true,
          feedback: event.approved
              ? ChallengeFeedback.reviewApproved
              : ChallengeFeedback.reviewRejected,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isReviewing: false,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isReviewing: false,
          feedback: ChallengeFeedback.reviewFailed,
        ),
      );
    }
  }

  void _onMessagesCleared(
    ChallengeMessagesCleared event,
    Emitter<ChallengeActionState> emit,
  ) {
    emit(state.copyWith(clearMessages: true));
  }
}
