part of 'profile_bloc.dart';

enum ProfileStatus { initial, loading, ready, failure }

final class ProfileState extends Equatable {
  const ProfileState({
    required this.status,
    this.profile,
    this.errorMessage,
  });

  const ProfileState.initial() : this(status: ProfileStatus.initial);

  final ProfileStatus status;
  final AppProfile? profile;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    AppProfile? profile,
    String? errorMessage,
    bool clearError = false,
    bool clearProfile = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
