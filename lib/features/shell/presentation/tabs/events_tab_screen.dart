import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../app/services/api_client.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../events/data/event_action_repository.dart';
import '../../../events/presentation/screens/event_details_screen.dart';
import '../../../events/presentation/screens/event_edit_screen.dart';
import '../design/neverest_design.dart';

class EventsTabScreen extends StatefulWidget {
  const EventsTabScreen({super.key});

  @override
  State<EventsTabScreen> createState() => _EventsTabScreenState();
}

class _EventsTabScreenState extends State<EventsTabScreen> {
  static const int _pageSize = 10;
  static const int _maxArchive = 100;

  String _filter = 'ALL';
  bool _showPast = false;
  int _pastPage = 0;

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

  Future<void> _confirmDeleteEvent(EventSummary event) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Șterge evenimentul'),
        content: Text('Sigur ștergi „${event.title}”? Acțiunea nu poate fi anulată.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<EventActionRepository>().deleteEvent(event.id);
      if (!mounted) return;
      context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Eveniment șters.')));
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = context.select<AccessCubit, bool>(
      (cubit) => cubit.state.canOpenAdminCenter,
    );
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final sourceEvents = state.data?.events ?? const <EventSummary>[];
        // Non-adminii nu vad evenimentele trecute; adminul le vede ca arhiva.
        final upcoming =
            sourceEvents.where((event) => !event.isPast).toList();
        final past = sourceEvents.where((event) => event.isPast).toList()
          ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
        final showingPast = isAdmin && _showPast;

        final sportCodes = <String>[
          'ALL',
          ...{
            for (final e in sourceEvents) e.activityType.toUpperCase(),
          },
        ];

        List<EventSummary> applySport(List<EventSummary> list) =>
            _filter == 'ALL'
                ? list
                : list
                    .where(
                        (event) => event.activityType.toUpperCase() == _filter)
                    .toList();

        final baseList = applySport(showingPast ? past : upcoming);
        final cappedArchive =
            baseList.length > _maxArchive ? baseList.sublist(0, _maxArchive) : baseList;
        final totalPages = showingPast
            ? (cappedArchive.length / _pageSize).ceil().clamp(1, 10)
            : 1;
        final safePage = showingPast ? _pastPage.clamp(0, totalPages - 1) : 0;
        final filtered = showingPast
            ? cappedArchive
                .skip(safePage * _pageSize)
                .take(_pageSize)
                .toList()
            : baseList;

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
                l10n.eventsSubtitle(
                  sourceEvents.length,
                  sourceEvents.fold<int>(
                    0,
                    (sum, event) => sum + event.participantCount,
                  ),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 34,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: sportCodes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final code = sportCodes[index];
                  return NeverestFilterChip(
                    label: _sportLabel(l10n, code),
                    selected: _filter == code,
                    icon: _sportIcon(code),
                    onTap: () => setState(() => _filter = code),
                  );
                },
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    NeverestFilterChip(
                      label: 'Viitoare (${upcoming.length})',
                      selected: !_showPast,
                      onTap: () => setState(() {
                        _showPast = false;
                        _pastPage = 0;
                      }),
                    ),
                    const SizedBox(width: 8),
                    NeverestFilterChip(
                      label: 'Trecute (${past.length})',
                      icon: Icons.history_rounded,
                      selected: _showPast,
                      onTap: () => setState(() {
                        _showPast = true;
                        _pastPage = 0;
                      }),
                    ),
                  ],
                ),
              ),
            ],
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
            else ...[
              ...filtered.map(
                (event) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _EventLargeCard(
                    event: event,
                    past: showingPast,
                    onDelete: isAdmin ? () => _confirmDeleteEvent(event) : null,
                    onEdit: isAdmin
                        ? () => Navigator.of(context).push(
                              AppPageRoute.fadeSlide(
                                EventEditScreen(event: event),
                              ),
                            )
                        : null,
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
              if (showingPast && totalPages > 1)
                _Pager(
                  page: safePage,
                  totalPages: totalPages,
                  onPrev: safePage > 0
                      ? () => setState(() => _pastPage = safePage - 1)
                      : null,
                  onNext: safePage < totalPages - 1
                      ? () => setState(() => _pastPage = safePage + 1)
                      : null,
                ),
            ],
          ],
        );
      },
    );
  }
}

String _sportLabel(AppLocalizations l10n, String code) {
  return switch (code) {
    'ALL' => l10n.commonAll,
    'RUNNING' => l10n.activityRunning,
    'PADEL' => l10n.activityPadel,
    'MOUNTAIN' => l10n.activityMountain,
    _ => code[0] + code.substring(1).toLowerCase(),
  };
}

IconData? _sportIcon(String code) {
  return switch (code) {
    'RUNNING' => Icons.directions_run_rounded,
    'PADEL' => Icons.sports_tennis_rounded,
    'MOUNTAIN' => Icons.terrain_rounded,
    _ => null,
  };
}

class _EventLargeCard extends StatelessWidget {
  const _EventLargeCard({
    required this.event,
    required this.onTap,
    this.onDelete,
    this.onEdit,
    this.past = false,
  });

  final EventSummary event;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool past;

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

    return Opacity(
      opacity: past ? 0.55 : 1,
      child: InkWell(
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
                                event.description?.isNotEmpty == true
                                    ? event.description!
                                    : event.activityType.toUpperCase(),
                                style: Theme.of(context).textTheme.labelSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                event.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                            if (past) ...[
                              const SizedBox(width: 8),
                              const _PastBadge(),
                            ],
                          ],
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_alt_outlined,
                        size: 14,
                        color: isDark
                            ? NeverestPalette.inkMuted
                            : NeverestPalette.paperMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${event.participantCount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark
                                  ? NeverestPalette.inkMuted
                                  : NeverestPalette.paperMuted,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                  if (event.spotsLeft != null) ...[
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          event.spotsLeft! > 0
                              ? Icons.event_seat_outlined
                              : Icons.block_rounded,
                          size: 14,
                          color: event.spotsLeft! > 0
                              ? (isDark
                                  ? NeverestPalette.inkMuted
                                  : NeverestPalette.paperMuted)
                              : NeverestPalette.danger,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          event.spotsLeft! > 0
                              ? AppLocalizations.of(context)!
                                  .eventSpotsLeft(event.spotsLeft!)
                              : AppLocalizations.of(context)!.eventFull,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: event.spotsLeft! > 0
                                    ? (isDark
                                        ? NeverestPalette.inkMuted
                                        : NeverestPalette.paperMuted)
                                    : NeverestPalette.danger,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ],
                  const Spacer(),
                  Text(
                    '+${event.pointsReward} PTS',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: NeverestPalette.orange,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.only(left: 8),
                      constraints: const BoxConstraints(),
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined,
                          size: 18, color: NeverestPalette.orange),
                    ),
                  if (onDelete != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.only(left: 8),
                      constraints: const BoxConstraints(),
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: NeverestPalette.danger),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

}

class _PastBadge extends StatelessWidget {
  const _PastBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: NeverestPalette.danger.withOpacity(0.16),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'TRECUT',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: NeverestPalette.danger,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({
    required this.page,
    required this.totalPages,
    this.onPrev,
    this.onNext,
  });

  final int page;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Text(
            '${page + 1} / $totalPages',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

