import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dashboard/domain/dashboard_data.dart';
import '../../data/leaderboard_repository.dart';

part 'activity_leaderboard_state.dart';

class ActivityLeaderboardCubit extends Cubit<ActivityLeaderboardState> {
  ActivityLeaderboardCubit({required LeaderboardRepository repository})
      : _repository = repository,
        super(const ActivityLeaderboardState.initial());

  final LeaderboardRepository _repository;

  Future<void> load(String activityType) async {
    emit(
      state.copyWith(
        isLoading: true,
        activityType: activityType,
        clearMessage: true,
      ),
    );
    try {
      final entries = await _repository.getActivityLeaderboard(
        activityType: activityType,
        limit: 20,
      );
      emit(
        state.copyWith(
          isLoading: false,
          activityType: activityType,
          entries: entries,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          activityType: activityType,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
