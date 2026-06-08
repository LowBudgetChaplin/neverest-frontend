import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/strava_repository.dart';
import '../../domain/strava_models.dart';

class StravaState {
  const StravaState({
    this.status,
    this.isLoading = false,
    this.isVerifying = false,
    this.verification,
    this.error,
  });

  final StravaStatus? status;
  final bool isLoading;
  final bool isVerifying;
  final StravaChallengeVerification? verification;
  final String? error;

  StravaState copyWith({
    StravaStatus? status,
    bool? isLoading,
    bool? isVerifying,
    StravaChallengeVerification? verification,
    String? error,
  }) {
    return StravaState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isVerifying: isVerifying ?? this.isVerifying,
      verification: verification ?? this.verification,
      error: error,
    );
  }

  StravaState clearVerification() => StravaState(
        status: status,
        isLoading: isLoading,
        isVerifying: false,
        verification: null,
        error: null,
      );
}

class StravaCubit extends Cubit<StravaState> {
  StravaCubit(this._repo) : super(const StravaState());

  final StravaRepository _repo;

  Future<void> loadStatus() async {
    emit(state.copyWith(isLoading: true));
    try {
      final status = await _repo.getStatus();
      emit(state.copyWith(status: status, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<String> getConnectUrl() async {
    return _repo.getConnectUrl();
  }

  Future<void> verifyChallenge(String challengeId) async {
    emit(state.copyWith(isVerifying: true, verification: null));
    try {
      final result = await _repo.verifyChallengeOnStrava(challengeId);
      emit(state.copyWith(isVerifying: false, verification: result));
    } catch (e) {
      emit(state.copyWith(isVerifying: false, error: e.toString()));
    }
  }

  void clearVerification() {
    emit(state.clearVerification());
  }

  Future<void> disconnect() async {
    await _repo.disconnect();
    emit(const StravaState());
  }
}
