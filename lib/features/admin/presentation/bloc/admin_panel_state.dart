part of 'admin_panel_cubit.dart';

class AdminPanelState extends Equatable {
  const AdminPanelState({
    required this.isBusy,
    required this.selectedActivityType,
    required this.users,
    required this.auditLogs,
    required this.activityLeaderboard,
    required this.lastAnnouncementRetry,
    this.authMe,
    this.lastCreatedEvent,
    this.errorMessage,
    this.successMessage,
  });

  const AdminPanelState.initial()
      : this(
          isBusy: false,
          selectedActivityType: 'RUNNING',
          users: const [],
          auditLogs: const [],
          activityLeaderboard: const [],
          lastAnnouncementRetry: const [],
        );

  final bool isBusy;
  final String selectedActivityType;
  final AuthMeInfo? authMe;
  final List<UserAdminItem> users;
  final List<AuditLogItem> auditLogs;
  final List<LeaderboardEntrySummary> activityLeaderboard;
  final EventCreationResult? lastCreatedEvent;
  final List<AnnouncementDispatchItem> lastAnnouncementRetry;
  final String? errorMessage;
  final String? successMessage;

  AdminPanelState copyWith({
    bool? isBusy,
    String? selectedActivityType,
    AuthMeInfo? authMe,
    List<UserAdminItem>? users,
    List<AuditLogItem>? auditLogs,
    List<LeaderboardEntrySummary>? activityLeaderboard,
    EventCreationResult? lastCreatedEvent,
    List<AnnouncementDispatchItem>? lastAnnouncementRetry,
    String? errorMessage,
    String? successMessage,
    bool clearMessage = false,
  }) {
    return AdminPanelState(
      isBusy: isBusy ?? this.isBusy,
      selectedActivityType: selectedActivityType ?? this.selectedActivityType,
      authMe: authMe ?? this.authMe,
      users: users ?? this.users,
      auditLogs: auditLogs ?? this.auditLogs,
      activityLeaderboard: activityLeaderboard ?? this.activityLeaderboard,
      lastCreatedEvent: lastCreatedEvent ?? this.lastCreatedEvent,
      lastAnnouncementRetry:
          lastAnnouncementRetry ?? this.lastAnnouncementRetry,
      errorMessage: clearMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        isBusy,
        selectedActivityType,
        authMe,
        users,
        auditLogs,
        activityLeaderboard,
        lastCreatedEvent,
        lastAnnouncementRetry,
        errorMessage,
        successMessage,
      ];
}
