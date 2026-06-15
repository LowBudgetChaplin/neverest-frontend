part of 'access_cubit.dart';

class AccessState extends Equatable {
  const AccessState({
    required this.isLoading,
    this.profile,
    this.errorMessage,
  });

  const AccessState.initial() : this(isLoading: false);

  final bool isLoading;
  final AccessProfile? profile;
  final String? errorMessage;

  bool get canOpenAdminCenter => profile?.canOpenAdminCenter ?? false;

  bool get canOpenPartnerCenter => profile?.isPartner ?? false;

  AccessState copyWith({
    bool? isLoading,
    AccessProfile? profile,
    String? errorMessage,
    bool clearMessage = false,
  }) {
    return AccessState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: clearMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, profile, errorMessage];
}
