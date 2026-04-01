part of 'reward_action_bloc.dart';

sealed class RewardActionEvent extends Equatable {
  const RewardActionEvent();

  @override
  List<Object?> get props => const [];
}

final class RewardRedemptionsLoadRequested extends RewardActionEvent {
  const RewardRedemptionsLoadRequested({this.userId});

  final String? userId;

  @override
  List<Object?> get props => [userId];
}

final class RewardRedeemRequested extends RewardActionEvent {
  const RewardRedeemRequested({
    required this.rewardId,
    this.userId,
  });

  final String rewardId;
  final String? userId;

  @override
  List<Object?> get props => [rewardId, userId];
}

final class RewardMessagesCleared extends RewardActionEvent {
  const RewardMessagesCleared();
}
