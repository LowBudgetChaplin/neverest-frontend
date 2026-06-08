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

final class ProfileUpdateRequested extends ProfileEvent {
  const ProfileUpdateRequested({
    this.displayName,
    this.phoneNumber,
    this.avatarB64,
  });

  final String? displayName;
  final String? phoneNumber;
  final String? avatarB64;

  @override
  List<Object?> get props => [displayName, phoneNumber, avatarB64];
}
