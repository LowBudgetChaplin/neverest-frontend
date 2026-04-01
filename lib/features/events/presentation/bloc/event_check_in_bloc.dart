import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/services/api_client.dart';
import '../../data/event_action_repository.dart';
import '../../domain/event_check_in_result.dart';

part 'event_check_in_event.dart';
part 'event_check_in_state.dart';

class EventCheckInBloc extends Bloc<EventCheckInEvent, EventCheckInState> {
  EventCheckInBloc({required EventActionRepository repository})
      : _repository = repository,
        super(const EventCheckInState.initial()) {
    on<EventCheckInSubmitted>(_onSubmitted);
    on<EventCheckInResetRequested>(_onResetRequested);
  }

  final EventActionRepository _repository;

  Future<void> _onSubmitted(
    EventCheckInSubmitted event,
    Emitter<EventCheckInState> emit,
  ) async {
    emit(state.copyWith(
        status: EventCheckInStatus.submitting, clearError: true));
    try {
      final result = await _repository.checkIn(
        eventId: event.eventId,
        userQrCode: event.userQrCode,
      );
      emit(
        state.copyWith(
          status: EventCheckInStatus.success,
          result: result,
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          status: EventCheckInStatus.failure,
          clearResult: true,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: EventCheckInStatus.failure,
          clearResult: true,
          errorMessage: 'Check-in failed.',
        ),
      );
    }
  }

  void _onResetRequested(
    EventCheckInResetRequested event,
    Emitter<EventCheckInState> emit,
  ) {
    emit(const EventCheckInState.initial());
  }
}
