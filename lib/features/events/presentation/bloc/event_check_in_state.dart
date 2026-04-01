part of 'event_check_in_bloc.dart';

enum EventCheckInStatus { initial, submitting, success, failure }

final class EventCheckInState extends Equatable {
  const EventCheckInState({
    required this.status,
    this.result,
    this.errorMessage,
  });

  const EventCheckInState.initial() : this(status: EventCheckInStatus.initial);

  final EventCheckInStatus status;
  final EventCheckInResult? result;
  final String? errorMessage;

  EventCheckInState copyWith({
    EventCheckInStatus? status,
    EventCheckInResult? result,
    String? errorMessage,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return EventCheckInState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, result, errorMessage];
}
