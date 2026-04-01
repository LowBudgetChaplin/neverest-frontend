import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../access/presentation/cubit/access_cubit.dart';
import '../../../../../resources/widgets/app_illustrated_state.dart';

class AccessProfileCard extends StatelessWidget {
  const AccessProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccessCubit, AccessState>(
      builder: (context, state) {
        if (state.isLoading && state.profile == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Access profile'),
                  SizedBox(height: 8),
                  LinearProgressIndicator(minHeight: 2),
                ],
              ),
            ),
          );
        }

        final profile = state.profile;
        if (profile == null) {
          return AppIllustratedState(
            icon: Icons.security_outlined,
            title: 'Access profile unavailable',
            subtitle:
                state.errorMessage ?? 'Could not load access information.',
            actionLabel: 'Retry',
            onActionTap: () => context.read<AccessCubit>().refresh(),
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
                    const Icon(Icons.security_outlined),
                    const SizedBox(width: 8),
                    Text(
                      'Access profile',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    Chip(
                      label: Text(
                        profile.canOpenAdminCenter
                            ? 'ADMIN ACCESS'
                            : 'USER ACCESS',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Subject: ${profile.subject}'),
                Text('Authenticated: ${profile.authenticated}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: profile.authorities.isEmpty
                      ? [const Chip(label: Text('No authorities'))]
                      : profile.authorities
                          .map((authority) => Chip(label: Text(authority)))
                          .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
