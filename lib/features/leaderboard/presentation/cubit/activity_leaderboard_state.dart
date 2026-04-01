part of 'activity_leaderboard_cubit.dart';

class ActivityLeaderboardState extends Equatable {
  const ActivityLeaderboardState({
    required this.activityType,
    required this.isLoading,
    required this.entries,
    this.errorMessage,
  });

  const ActivityLeaderboardState.initial()
      : this(
          activityType: 'RUNNING',
          isLoading: false,
          entries: const [],
        );

  final String activityType;
  final bool isLoading;
  final List<LeaderboardEntrySummary> entries;
  final String? errorMessage;

  ActivityLeaderboardState copyWith({
    String? activityType,
    bool? isLoading,
    List<LeaderboardEntrySummary>? entries,
    String? errorMessage,
    bool clearMessage = false,
  }) {
    return ActivityLeaderboardState(
      activityType: activityType ?? this.activityType,
      isLoading: isLoading ?? this.isLoading,
      entries: entries ?? this.entries,
      errorMessage: clearMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [activityType, isLoading, entries, errorMessage];
}
