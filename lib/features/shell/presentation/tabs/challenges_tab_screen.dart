import 'package:flutter/material.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../resources/widgets/app_illustrated_state.dart';
import '../../../challenges/presentation/screens/challenge_details_screen.dart';
import 'widgets/dashboard_tab_container.dart';

class ChallengesTabScreen extends StatelessWidget {
  const ChallengesTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardTabContainer(
      emptyLabel: 'No challenges available.',
      contentBuilder: (context, data) {
        if (data.challenges.isEmpty) {
          return const AppIllustratedState(
            icon: Icons.flag_outlined,
            title: 'No challenges yet',
            subtitle: 'Weekly and monthly challenges will appear here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.challenges.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final challenge = data.challenges[index];
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
                    Icons.flag,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                title: Text(challenge.title),
                subtitle: Text(
                  '${challenge.activityType} • ${challenge.frequency} • ${challenge.mode}',
                ),
                trailing: Chip(label: Text('+${challenge.pointsReward}p')),
                onTap: () {
                  Navigator.of(context).push(
                    AppPageRoute.fadeSlide(
                      ChallengeDetailsScreen(challenge: challenge),
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
