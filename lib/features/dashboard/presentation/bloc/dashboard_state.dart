part of 'dashboard_bloc.dart';

enum DashboardStatus { initial, loading, success, failure }

final class DashboardState extends Equatable {
  const DashboardState({
    required this.status,
    this.data,
    this.errorMessage,
  });

  const DashboardState.initial() : this(status: DashboardStatus.initial);

  final DashboardStatus status;
  final DashboardData? data;
  final String? errorMessage;

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardData? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
