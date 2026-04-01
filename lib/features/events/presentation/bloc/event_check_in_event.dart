part of 'event_check_in_bloc.dart';

sealed class EventCheckInEvent extends Equatable {
  const EventCheckInEvent();

  @override
  List<Object?> get props => const [];
}

final class EventCheckInSubmitted extends EventCheckInEvent {
  const EventCheckInSubmitted({
    required this.eventId,
    required this.userQrCode,
  });

  final String eventId;
  final String userQrCode;

  @override
  List<Object?> get props => [eventId, userQrCode];
}

final class EventCheckInResetRequested extends EventCheckInEvent {
  const EventCheckInResetRequested();
}
