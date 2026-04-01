import 'package:flutter/material.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../resources/widgets/app_illustrated_state.dart';
import '../../../rewards/presentation/screens/reward_details_screen.dart';
import 'widgets/dashboard_tab_container.dart';

class RewardsTabScreen extends StatelessWidget {
  const RewardsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardTabContainer(
      emptyLabel: 'No rewards available.',
      contentBuilder: (context, data) {
        if (data.rewards.isEmpty) {
          return const AppIllustratedState(
            icon: Icons.card_giftcard_outlined,
            title: 'No rewards yet',
            subtitle: 'Rewards from local partners will appear here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.rewards.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final reward = data.rewards[index];
            final stockLabel =
                reward.stock == null ? 'Unlimited' : reward.stock.toString();
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.card_giftcard,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                title: Text(reward.title),
                subtitle: Text('${reward.partnerName} • Stock: $stockLabel'),
                trailing: Chip(label: Text('${reward.pointsCost}p')),
                onTap: () {
                  Navigator.of(context).push(
                    AppPageRoute.fadeSlide(
                      RewardDetailsScreen(reward: reward),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
