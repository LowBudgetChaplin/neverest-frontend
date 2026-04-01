import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/services/api_client.dart';
import '../../data/reward_action_repository.dart';
import '../../domain/reward_redemption_item.dart';

part 'reward_action_event.dart';
part 'reward_action_state.dart';

class RewardActionBloc extends Bloc<RewardActionEvent, RewardActionState> {
  RewardActionBloc({required RewardActionRepository repository})
      : _repository = repository,
        super(const RewardActionState.initial()) {
    on<RewardRedemptionsLoadRequested>(_onLoadRequested);
    on<RewardRedeemRequested>(_onRedeemRequested);
    on<RewardMessagesCleared>(_onMessagesCleared);
  }

  final RewardActionRepository _repository;

  Future<void> _onLoadRequested(
    RewardRedemptionsLoadRequested event,
    Emitter<RewardActionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearMessages: true));
    try {
      final redemptions =
          await _repository.getMyRedemptions(userId: event.userId);
      emit(
        state.copyWith(
          isLoading: false,
          redemptions: redemptions,
          clearMessages: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load reward redemptions.',
        ),
      );
    }
  }

  Future<void> _onRedeemRequested(
    RewardRedeemRequested event,
    Emitter<RewardActionState> emit,
  ) async {
    emit(state.copyWith(isRedeeming: true, clearMessages: true));
    try {
      final redemption = await _repository.redeem(
        rewardId: event.rewardId,
        userId: event.userId,
      );
      final redemptions =
          await _repository.getMyRedemptions(userId: event.userId);
      emit(
        state.copyWith(
          isRedeeming: false,
          redemptions: redemptions,
          lastRedemption: redemption,
          successMessage: 'Reward redeemed successfully.',
        ),
      );
    } on ApiException catch (error) {
      emit(
        state.copyWith(
          isRedeeming: false,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isRedeeming: false,
          errorMessage: 'Could not redeem reward.',
        ),
      );
    }
  }

  void _onMessagesCleared(
    RewardMessagesCleared event,
    Emitter<RewardActionState> emit,
  ) {
    emit(state.copyWith(clearMessages: true));
  }
}
