import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../events/presentation/screens/event_details_screen.dart';
import '../design/neverest_design.dart';

class EventsTabScreen extends StatefulWidget {
  const EventsTabScreen({super.key});

  @override
  State<EventsTabScreen> createState() => _EventsTabScreenState();
}

class _EventsTabScreenState extends State<EventsTabScreen> {
  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final dashboardState = context.read<DashboardBloc>().state;
      if (dashboardState.status == DashboardStatus.initial) {
        context.read<DashboardBloc>().add(const DashboardLoadRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final sourceEvents = state.data?.events ?? const <EventSummary>[];
        final filtered = _filter == 'ALL'
            ? sourceEvents
            : sourceEvents
                .where((event) => event.activityType.toUpperCase() == _filter)
                .toList();

        return ListView(
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            top: MediaQuery.paddingOf(context).top + 10,
            bottom: 106,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.eventsTitle.toUpperCase(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 38,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.eventsSubtitle(sourceEvents.length, 65),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 34,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                children: [
                  NeverestFilterChip(
                    label: l10n.commonAll,
                    selected: _filter == 'ALL',
                    onTap: () => setState(() => _filter = 'ALL'),
                  ),
                  const SizedBox(width: 8),
                  NeverestFilterChip(
                    label: l10n.activityRunning,
                    selected: _filter == 'RUNNING',
                    icon: Icons.directions_run_rounded,
                    onTap: () => setState(() => _filter = 'RUNNING'),
                  ),
                  const SizedBox(width: 8),
                  NeverestFilterChip(
                    label: l10n.activityPadel,
                    selected: _filter == 'PADEL',
                    icon: Icons.sports_tennis_rounded,
                    onTap: () => setState(() => _filter = 'PADEL'),
                  ),
                  const SizedBox(width: 8),
                  NeverestFilterChip(
                    label: l10n.activityMountain,
                    selected: _filter == 'MOUNTAIN',
                    icon: Icons.terrain_rounded,
                    onTap: () => setState(() => _filter = 'MOUNTAIN'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (state.status == DashboardStatus.loading && sourceEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Se incarca evenimente...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )
            else if (state.status == DashboardStatus.failure &&
                sourceEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.errorMessage ?? l10n.dashboardLoadFailed,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<DashboardBloc>()
                          .add(const DashboardRefreshRequested()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              )
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.eventsEmptyState,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ...filtered.map(
                (event) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _EventLargeCard(
                    event: event,
                    onTap: () {
                      Navigator.of(context).push(
                        AppPageRoute.fadeSlide(
                          EventDetailsScreen(event: event),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EventLargeCard extends StatelessWidget {
  const _EventLargeCard({
    required this.event,
    required this.onTap,
  });

  final EventSummary event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activityColor = neverestActivityColor(event.activityType);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = DateTime.tryParse(event.startsAt);
    final weekday = date == null
        ? 'SAT'
        : ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][date.weekday - 1];
    final day = date?.day.toString().padLeft(2, '0') ?? '11';
    final time = date == null
        ? '07:00'
        : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 78,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: isDark
                            ? NeverestPalette.inkLine
                            : NeverestPalette.paperLine,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        weekday,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        day,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontSize: 34,
                            ),
                      ),
                      Text(
                        time,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: activityColor,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _tagFor(event),
                                style: Theme.of(context).textTheme.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.location,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color:
                        isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
                  ),
                ),
              ),
              child: Row(
                children: [
                  _AttendeesStack(isDark: isDark),
                  const SizedBox(width: 8),
                  Text(
                    '28/40 ${AppLocalizations.of(context)!.eventsGoingLabel}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '+${event.pointsReward} PTS',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: NeverestPalette.orange,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tagFor(EventSummary event) {
    final type = event.activityType.toUpperCase();
    if (type == 'PADEL') {
      return 'MIXED LEVELS · ROUND-ROBIN';
    }
    if (type == 'MOUNTAIN') {
      return '14 KM · 900M GAIN';
    }
    return 'GROUP RUN · 8 KM';
  }
}

class _AttendeesStack extends StatelessWidget {
  const _AttendeesStack({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 24,
      child: Stack(
        children: List.generate(3, (index) {
          final hues = [42.0, 180.0, 285.0];
          final bg = HSLColor.fromAHSL(1, hues[index], 0.55, 0.55).toColor();
          return Positioned(
            left: index * 16,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: bg,
                border: Border.all(
                  color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paper,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          );
        }),
      ),
    );
  }
}

