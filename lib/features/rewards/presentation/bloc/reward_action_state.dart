part of 'reward_action_bloc.dart';

final class RewardActionState extends Equatable {
  const RewardActionState({
    required this.isLoading,
    required this.isRedeeming,
    required this.redemptions,
    this.lastRedemption,
    this.errorMessage,
    this.successMessage,
  });

  const RewardActionState.initial()
      : this(
          isLoading: false,
          isRedeeming: false,
          redemptions: const [],
        );

  final bool isLoading;
  final bool isRedeeming;
  final List<RewardRedemptionItem> redemptions;
  final RewardRedemptionItem? lastRedemption;
  final String? errorMessage;
  final String? successMessage;

  RewardActionState copyWith({
    bool? isLoading,
    bool? isRedeeming,
    List<RewardRedemptionItem>? redemptions,
    RewardRedemptionItem? lastRedemption,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return RewardActionState(
      isLoading: isLoading ?? this.isLoading,
      isRedeeming: isRedeeming ?? this.isRedeeming,
      redemptions: redemptions ?? this.redemptions,
      lastRedemption: lastRedemption ?? this.lastRedemption,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isRedeeming,
        redemptions,
        lastRedemption,
        errorMessage,
        successMessage,
      ];
}
