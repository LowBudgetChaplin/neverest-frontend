part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => const [];
}

final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested({
    required this.suggestedDisplayName,
    required this.preferMeEndpoints,
  });

  final String suggestedDisplayName;
  final bool preferMeEndpoints;

  @override
  List<Object?> get props => [suggestedDisplayName, preferMeEndpoints];
}

final class ProfileClearedRequested extends ProfileEvent {
  const ProfileClearedRequested();
}
