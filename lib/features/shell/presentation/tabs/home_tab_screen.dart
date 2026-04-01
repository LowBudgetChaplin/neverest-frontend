import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import 'widgets/access_profile_card.dart';
import 'widgets/auth_session_card.dart';
import 'widgets/profile_summary_card.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final data = state.data;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroPanel(dataLoaded: data != null),
            const SizedBox(height: 12),
            _BackendStatusCard(
              status: state.status,
              message: state.errorMessage,
              backendMessage: data?.backendMessage,
            ),
            if (data != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Events',
                      value: data.events.length.toString(),
                      icon: Icons.event,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Challenges',
                      value: data.challenges.length.toString(),
                      icon: Icons.flag,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Rewards',
                      value: data.rewards.length.toString(),
                      icon: Icons.card_giftcard,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Top Users',
                      value: data.leaderboard.length.toString(),
                      icon: Icons.emoji_events,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const AccessProfileCard(),
            const SizedBox(height: 16),
            const AuthSessionCard(),
            const SizedBox(height: 16),
            const ProfileSummaryCard(),
            const SizedBox(height: 16),
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Design refresh'),
                subtitle: Text(
                  'UI polished for a cleaner, modern and consistent experience.',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.dataLoaded});

  final bool dataLoaded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.terrain_outlined,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Neverest',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  dataLoaded
                      ? 'All sections synced and ready.'
                      : 'Sign in to start syncing your data.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackendStatusCard extends StatelessWidget {
  const _BackendStatusCard({
    required this.status,
    required this.message,
    required this.backendMessage,
  });

  final DashboardStatus status;
  final String? message;
  final String? backendMessage;

  @override
  Widget build(BuildContext context) {
    if (status == DashboardStatus.initial && backendMessage == null) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.cloud_queue_outlined),
          title: Text('Backend connection'),
          subtitle: Text('Sign in to start syncing dashboard data.'),
        ),
      );
    }

    if (status == DashboardStatus.loading && backendMessage == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Backend connection',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(minHeight: 2),
            ],
          ),
        ),
      );
    }

    if (status == DashboardStatus.failure && backendMessage == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.cloud_off_outlined),
          title: const Text('Backend connection'),
          subtitle: Text(message ?? 'Could not load backend data yet.'),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.cloud_done_outlined),
        title: const Text('Backend connection'),
        subtitle: Text(backendMessage ?? 'Connected'),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 2),
            Text(label),
          ],
        ),
      ),
    );
  }
}
