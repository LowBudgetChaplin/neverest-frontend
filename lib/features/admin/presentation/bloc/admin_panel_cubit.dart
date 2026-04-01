import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dashboard/domain/dashboard_data.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_models.dart';

part 'admin_panel_state.dart';

class AdminPanelCubit extends Cubit<AdminPanelState> {
  AdminPanelCubit({required AdminRepository repository})
      : _repository = repository,
        super(const AdminPanelState.initial());

  final AdminRepository _repository;

  Future<void> loadInitial() async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    try {
      final authMeFuture = _repository.getAuthMe();
      final usersFuture = _repository.getUsers();
      final auditLogsFuture = _repository.getAuditLogs(limit: 25);
      final leaderboardFuture = _repository.getActivityLeaderboard(
        activityType: state.selectedActivityType,
        limit: 20,
      );

      final results = await Future.wait([
        authMeFuture,
        usersFuture,
        auditLogsFuture,
        leaderboardFuture,
      ]);

      emit(
        state.copyWith(
          isBusy: false,
          authMe: results[0] as AuthMeInfo,
          users: results[1] as List<UserAdminItem>,
          auditLogs: results[2] as List<AuditLogItem>,
          activityLeaderboard: results[3] as List<LeaderboardEntrySummary>,
          clearMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refreshAuditLogs({
    int limit = 50,
    String? action,
    String? actor,
    bool? success,
  }) async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    try {
      final logs = await _repository.getAuditLogs(
        limit: limit,
        action: action,
        actor: actor,
        success: success,
      );
      emit(
        state.copyWith(
          isBusy: false,
          auditLogs: logs,
          successMessage: 'Audit logs refreshed.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refreshUsers() async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    try {
      final users = await _repository.getUsers();
      emit(
        state.copyWith(
          isBusy: false,
          users: users,
          successMessage: 'Users refreshed.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> createUser(String displayName) async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    try {
      await _repository.createUser(displayName: displayName);
      final users = await _repository.getUsers();
      emit(
        state.copyWith(
          isBusy: false,
          users: users,
          successMessage: 'User created successfully.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> createEvent({
    required String title,
    required String activityType,
    required String location,
    required String startsAtIso,
    required int pointsReward,
  }) async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    try {
      final created = await _repository.createEvent(
        title: title,
        activityType: activityType,
        location: location,
        startsAtIso: startsAtIso,
        pointsReward: pointsReward,
      );
      emit(
        state.copyWith(
          isBusy: false,
          lastCreatedEvent: created,
          lastAnnouncementRetry: const [],
          successMessage: 'Event created successfully.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> retryAnnouncements(String eventId) async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    try {
      final retries = await _repository.retryAnnouncements(eventId: eventId);
      emit(
        state.copyWith(
          isBusy: false,
          lastAnnouncementRetry: retries,
          successMessage: 'Announcement retry finished.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> createChallenge({
    required String title,
    required String description,
    required String activityType,
    required String mode,
    required String frequency,
    required String startsAtIso,
    required String endsAtIso,
    required int pointsReward,
    required double? targetValue,
    required String? targetUnit,
  }) async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    try {
      await _repository.createChallenge(
        title: title,
        description: description,
        activityType: activityType,
        mode: mode,
        frequency: frequency,
        startsAtIso: startsAtIso,
        endsAtIso: endsAtIso,
        pointsReward: pointsReward,
        targetValue: targetValue,
        targetUnit: targetUnit,
      );
      emit(
        state.copyWith(
          isBusy: false,
          successMessage: 'Challenge created successfully.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> createReward({
    required String title,
    required String partnerName,
    required String description,
    required int pointsCost,
    required int? stock,
  }) async {
    emit(state.copyWith(isBusy: true, clearMessage: true));
    try {
      await _repository.createReward(
        title: title,
        partnerName: partnerName,
        description: description,
        pointsCost: pointsCost,
        stock: stock,
      );
      emit(
        state.copyWith(
          isBusy: false,
          successMessage: 'Reward created successfully.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> refreshActivityLeaderboard(String activityType) async {
    emit(
      state.copyWith(
        isBusy: true,
        selectedActivityType: activityType,
        clearMessage: true,
      ),
    );
    try {
      final items = await _repository.getActivityLeaderboard(
        activityType: activityType,
        limit: 20,
      );
      emit(
        state.copyWith(
          isBusy: false,
          selectedActivityType: activityType,
          activityLeaderboard: items,
          successMessage: 'Leaderboard refreshed for $activityType.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isBusy: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearMessage: true));
  }
}
