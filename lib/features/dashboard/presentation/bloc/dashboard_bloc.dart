import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/services/api_client.dart';
import '../../data/dashboard_repository.dart';
import '../../domain/dashboard_data.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required DashboardRepository repository})
      : _repository = repository,
        super(const DashboardState.initial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
    on<DashboardClearedRequested>(_onClearedRequested);
  }

  final DashboardRepository _repository;

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.status == DashboardStatus.loading) {
      return;
    }

    emit(state.copyWith(status: DashboardStatus.loading, clearError: true));
    await _fetch(emit);
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading, clearError: true));
    await _fetch(emit);
  }

  void _onClearedRequested(
    DashboardClearedRequested event,
    Emitter<DashboardState> emit,
  ) {
    emit(const DashboardState.initial());
  }

  Future<void> _fetch(Emitter<DashboardState> emit) async {
    try {
      final data = await _repository.fetchDashboardData();
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          data: data,
          clearError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: 'Failed to load dashboard data.',
        ),
      );
    }
  }
}
