import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../resources/widgets/app_illustrated_state.dart';
import '../../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../profile/presentation/bloc/profile_bloc.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (!authState.isAuthenticated) {
          return const AppIllustratedState(
            icon: Icons.person_outline,
            title: 'Profile not loaded',
            subtitle: 'Sign in first to create and sync your profile.',
          );
        }

        return BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            if (profileState.status == ProfileStatus.loading) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(minHeight: 2),
                    ],
                  ),
                ),
              );
            }

            if (profileState.status == ProfileStatus.failure) {
              return AppIllustratedState(
                icon: Icons.error_outline,
                title: 'Profile sync failed',
                subtitle:
                    profileState.errorMessage ?? 'Could not load profile.',
                actionLabel: 'Retry profile sync',
                onActionTap: () => _retry(context, authState),
              );
            }

            final profile = profileState.profile;
            if (profile == null) {
              return AppIllustratedState(
                icon: Icons.sync_problem_outlined,
                title: 'Profile not synchronized',
                subtitle: 'Your profile is not loaded yet.',
                actionLabel: 'Sync now',
                onActionTap: () => _retry(context, authState),
              );
            }

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_pin_circle_outlined),
                        const SizedBox(width: 8),
                        Text(
                          'Profile',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${profile.displayName}'),
                    const SizedBox(height: 2),
                    Text('QR: ${profile.qrCode}'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.stacked_line_chart,
                            label: 'Total',
                            value: '${profile.totalPoints}p',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Available',
                            value: '${profile.availablePoints}p',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _retry(BuildContext context, AuthState authState) {
    final fallbackName = _suggestDisplayName(authState);
    context.read<ProfileBloc>().add(
          ProfileLoadRequested(
            suggestedDisplayName: fallbackName,
            preferMeEndpoints: true,
          ),
        );
  }

  String _suggestDisplayName(AuthState authState) {
    final session = authState.session;
    if (session == null) {
      return 'Neverest User';
    }

    if (session.displayName != null && session.displayName!.trim().isNotEmpty) {
      return session.displayName!.trim();
    }
    if (session.email != null && session.email!.trim().isNotEmpty) {
      final username = session.email!.trim().split('@').first;
      if (username.isNotEmpty) {
        return username;
      }
    }
    return 'Neverest User';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
