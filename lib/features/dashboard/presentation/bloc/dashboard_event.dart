part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => const [];
}

final class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

final class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

final class DashboardClearedRequested extends DashboardEvent {
  const DashboardClearedRequested();
}
