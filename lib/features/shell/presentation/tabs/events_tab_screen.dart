import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../events/presentation/screens/event_details_screen.dart';
import '../../../../resources/widgets/app_illustrated_state.dart';
import 'widgets/dashboard_tab_container.dart';

class EventsTabScreen extends StatelessWidget {
  const EventsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardTabContainer(
      emptyLabel: 'No events available.',
      contentBuilder: (context, data) {
        if (data.events.isEmpty) {
          return const AppIllustratedState(
            icon: Icons.event_busy_outlined,
            title: 'No events yet',
            subtitle: 'Create or sync events and they will appear here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: data.events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final event = data.events[index];
            final parsedDate = DateTime.tryParse(event.startsAt);
            final formattedDate = parsedDate == null
                ? '-'
                : DateFormat('dd MMM yyyy, HH:mm').format(parsedDate);

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
                    Icons.event,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                title: Text(event.title),
                subtitle: Text(
                  '${event.activityType} • $formattedDate\n${event.location}',
                ),
                isThreeLine: true,
                trailing: Chip(label: Text('+${event.pointsReward}p')),
                onTap: () {
                  Navigator.of(context).push(
                    AppPageRoute.fadeSlide(
                      EventDetailsScreen(event: event),
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
