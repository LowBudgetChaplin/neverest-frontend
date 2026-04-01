import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/widgets/app_illustrated_state.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../data/reward_action_repository.dart';
import '../bloc/reward_action_bloc.dart';

class RewardDetailsScreen extends StatelessWidget {
  const RewardDetailsScreen({
    super.key,
    required this.reward,
  });

  final RewardSummary reward;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RewardActionBloc(
        repository: context.read<RewardActionRepository>(),
      ),
      child: _RewardDetailsView(reward: reward),
    );
  }
}

class _RewardDetailsView extends StatefulWidget {
  const _RewardDetailsView({required this.reward});

  final RewardSummary reward;

  @override
  State<_RewardDetailsView> createState() => _RewardDetailsViewState();
}

class _RewardDetailsViewState extends State<_RewardDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRedemptions());
  }

  @override
  Widget build(BuildContext context) {
    final stockLabel = widget.reward.stock == null
        ? 'Unlimited'
        : widget.reward.stock.toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Reward details')),
      body: BlocConsumer<RewardActionBloc, RewardActionState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            context.read<RewardActionBloc>().add(const RewardMessagesCleared());
            return;
          }

          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            context.read<RewardActionBloc>().add(const RewardMessagesCleared());
            context
                .read<DashboardBloc>()
                .add(const DashboardRefreshRequested());
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reward.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Partner: ${widget.reward.partnerName}'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('${widget.reward.pointsCost}p')),
                        Chip(label: Text('Stock: $stockLabel')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: state.isRedeeming ? null : _redeemReward,
                icon: const Icon(Icons.redeem),
                label: const Text('Redeem reward'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: state.isLoading ? null : _loadRedemptions,
                child: const Text('Refresh my redemptions'),
              ),
              if (state.isRedeeming) ...[
                const SizedBox(height: 10),
                const LinearProgressIndicator(minHeight: 2),
              ],
              const SizedBox(height: 14),
              if (state.lastRedemption != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.verified),
                    title: const Text('Latest redemption code'),
                    subtitle: Text(state.lastRedemption!.redemptionCode),
                  ),
                ),
              if (state.isLoading && state.redemptions.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (state.redemptions.isEmpty)
                const AppIllustratedState(
                  icon: Icons.redeem_outlined,
                  title: 'No redemptions yet',
                  subtitle: 'Redeem this reward to receive your first code.',
                )
              else
                ...state.redemptions.map(
                  (redemption) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.card_giftcard),
                      title: Text(redemption.rewardTitle),
                      subtitle: Text(
                        'Code: ${redemption.redemptionCode}\n'
                        'Spent: ${redemption.pointsSpent}p\n'
                        'Remaining: ${redemption.userAvailablePointsAfterRedemption}p',
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _loadRedemptions() {
    context.read<RewardActionBloc>().add(
          RewardRedemptionsLoadRequested(userId: _profileUserId()),
        );
  }

  void _redeemReward() {
    context.read<RewardActionBloc>().add(
          RewardRedeemRequested(
            rewardId: widget.reward.id,
            userId: _profileUserId(),
          ),
        );
  }

  String? _profileUserId() {
    return context.read<ProfileBloc>().state.profile?.id;
  }
}
