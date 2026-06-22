import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/notification_repository.dart';
import '../../domain/notification_models.dart';

class NotificationState extends Equatable {
  const NotificationState({
    this.items = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  final List<AppNotification> items;
  final int unreadCount;
  final bool isLoading;

  NotificationState copyWith({
    List<AppNotification>? items,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [items, unreadCount, isLoading];
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this._repository) : super(const NotificationState());

  final NotificationRepository _repository;

  Future<void> refreshUnreadCount() async {
    try {
      final count = await _repository.unreadCount();
      emit(state.copyWith(unreadCount: count));
    } catch (_) {
    }
  }

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await _repository.list();
      final count = await _repository.unreadCount();
      emit(state.copyWith(items: items, unreadCount: count, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> markAllRead() async {
    if (state.unreadCount == 0) return;
    try {
      await _repository.markAllRead();
    } catch (_) {
    }
    emit(state.copyWith(unreadCount: 0));
  }

  void clear() => emit(const NotificationState());
}
