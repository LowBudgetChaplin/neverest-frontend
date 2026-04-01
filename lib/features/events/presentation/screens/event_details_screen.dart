import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../profile/presentation/screens/my_qr_screen.dart';
import 'event_check_in_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  final EventSummary event;

  @override
  Widget build(BuildContext context) {
    final canUseAdminFeatures = context.select<AccessCubit, bool>(
      (cubit) => cubit.state.canOpenAdminCenter,
    );
    final parsedDate = DateTime.tryParse(event.startsAt);
    final formattedDate = parsedDate == null
        ? '-'
        : DateFormat('dd MMM yyyy, HH:mm').format(parsedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Event details')),
      body: ListView(
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
                  event.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(event.activityType)),
                    Chip(label: Text(formattedDate)),
                    Chip(label: Text('+${event.pointsReward}p')),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Location: ${event.location}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                AppPageRoute.fadeSlide(const MyQrScreen()),
              );
            },
            icon: const Icon(Icons.qr_code),
            label: const Text('Show my QR'),
          ),
          const SizedBox(height: 10),
          if (canUseAdminFeatures) ...[
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  AppPageRoute.fadeSlide(
                    EventCheckInScreen(event: event),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Admin check-in'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Admin check-in requires ADMIN role when backend auth provider is Firebase.',
            ),
          ] else ...[
            const Card(
              child: ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Admin check-in locked'),
                subtitle: Text(
                  'Available only for organizer accounts with admin role.',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
