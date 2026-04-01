import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/leaderboard/data/leaderboard_repository.dart';
import '../../../../features/leaderboard/presentation/cubit/activity_leaderboard_cubit.dart';
import '../../../../resources/widgets/app_illustrated_state.dart';
import 'widgets/dashboard_tab_container.dart';

class LeaderboardTabScreen extends StatefulWidget {
  const LeaderboardTabScreen({super.key});

  @override
  State<LeaderboardTabScreen> createState() => _LeaderboardTabScreenState();
}

class _LeaderboardTabScreenState extends State<LeaderboardTabScreen> {
  String _selectedActivity = 'RUNNING';
  static const _activityTypes = ['RUNNING', 'MOUNTAIN', 'PADEL'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivityLeaderboardCubit(
        repository: context.read<LeaderboardRepository>(),
      )..load(_selectedActivity),
      child: DashboardTabContainer(
        emptyLabel: 'No leaderboard data.',
        contentBuilder: (context, data) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'General leaderboard',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (data.leaderboard.isEmpty)
                const AppIllustratedState(
                  icon: Icons.emoji_events_outlined,
                  title: 'No leaderboard entries yet',
                  subtitle:
                      'Once users earn points, rankings will be shown here.',
                )
              else
                ...data.leaderboard.asMap().entries.map(
                      (entry) => _LeaderboardTile(
                        rank: entry.key + 1,
                        displayName: entry.value.displayName,
                        subtitle: 'User ID: ${entry.value.userId}',
                        points: entry.value.points,
                      ),
                    ),
              const SizedBox(height: 16),
              Text(
                'Activity leaderboard',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _activityTypes
                    .map(
                      (activityType) => ChoiceChip(
                        label: Text(activityType),
                        selected: _selectedActivity == activityType,
                        onSelected: (selected) {
                          if (!selected) {
                            return;
                          }
                          setState(() => _selectedActivity = activityType);
                          context
                              .read<ActivityLeaderboardCubit>()
                              .load(activityType);
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              BlocBuilder<ActivityLeaderboardCubit, ActivityLeaderboardState>(
                builder: (context, activityState) {
                  if (activityState.isLoading &&
                      activityState.entries.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (activityState.errorMessage != null &&
                      activityState.errorMessage!.isNotEmpty &&
                      activityState.entries.isEmpty) {
                    return AppIllustratedState(
                      icon: Icons.error_outline,
                      title: 'Activity leaderboard unavailable',
                      subtitle: activityState.errorMessage!,
                      actionLabel: 'Retry',
                      onActionTap: () => context
                          .read<ActivityLeaderboardCubit>()
                          .load(_selectedActivity),
                    );
                  }

                  if (activityState.entries.isEmpty) {
                    return const AppIllustratedState(
                      icon: Icons.emoji_events_outlined,
                      title: 'No entries for this activity',
                      subtitle:
                          'Ask members to participate to generate rankings.',
                    );
                  }

                  return Column(
                    children: activityState.entries
                        .asMap()
                        .entries
                        .map(
                          (entry) => _LeaderboardTile(
                            rank: entry.key + 1,
                            displayName: entry.value.displayName,
                            subtitle: 'User ID: ${entry.value.userId}',
                            points: entry.value.points,
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.displayName,
    required this.subtitle,
    required this.points,
  });

  final int rank;
  final String displayName;
  final String subtitle;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            child: Text('$rank'),
          ),
          title: Text(displayName),
          subtitle: Text(subtitle),
          trailing: Text(
            '${points}p',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
