import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/profile_repository.dart';
import '../../domain/app_profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState.initial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileClearedRequested>(_onClearedRequested);
  }

  final ProfileRepository _repository;

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    try {
      final profile = await _repository.loadOrCreateProfile(
        suggestedDisplayName: event.suggestedDisplayName,
        preferMeEndpoints: event.preferMeEndpoints,
      );
      emit(
        state.copyWith(
          status: ProfileStatus.ready,
          profile: profile,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          clearProfile: true,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onClearedRequested(
    ProfileClearedRequested event,
    Emitter<ProfileState> emit,
  ) {
    emit(const ProfileState.initial());
  }
}
