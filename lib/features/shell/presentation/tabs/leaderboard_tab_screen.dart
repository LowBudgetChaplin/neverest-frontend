import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../design/neverest_design.dart';

class LeaderboardTabScreen extends StatefulWidget {
  const LeaderboardTabScreen({super.key});

  @override
  State<LeaderboardTabScreen> createState() => _LeaderboardTabScreenState();
}

class _LeaderboardTabScreenState extends State<LeaderboardTabScreen> {
  String _selectedActivity = 'ALL';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final rows = state.data?.leaderboard ?? const <LeaderboardEntrySummary>[];
        final normalized = rows
            .map(
              (entry) => _LeaderboardRow(
                name: entry.displayName,
                points: entry.points,
                delta: _weeklyDeltaFor(entry.userId + entry.displayName),
              ),
            )
            .toList()
          ..sort((a, b) => b.points.compareTo(a.points));
        final top3 = normalized.length >= 3 ? normalized.take(3).toList() : <_LeaderboardRow>[];
        final others = normalized.skip(3).toList();

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
                l10n.leaderboardTitle.toUpperCase(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 36,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.leaderboardSubtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  NeverestFilterChip(
                    label: l10n.commonOverall,
                    selected: _selectedActivity == 'ALL',
                    onTap: () => setState(() => _selectedActivity = 'ALL'),
                  ),
                  const SizedBox(width: 8),
                  NeverestFilterChip(
                    label: l10n.activityRunning,
                    selected: _selectedActivity == 'RUNNING',
                    icon: Icons.directions_run_rounded,
                    onTap: () => setState(() => _selectedActivity = 'RUNNING'),
                  ),
                  const SizedBox(width: 8),
                  NeverestFilterChip(
                    label: l10n.activityMountain,
                    selected: _selectedActivity == 'MOUNTAIN',
                    icon: Icons.terrain_rounded,
                    onTap: () => setState(() => _selectedActivity = 'MOUNTAIN'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _Podium(top3: top3),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _LeaderboardList(rows: others),
            ),
          ],
        );
      },
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top3});

  final List<_LeaderboardRow> top3;

  @override
  Widget build(BuildContext context) {
    if (top3.length < 3) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _PodiumBlock(
              place: 2,
              row: top3[1],
              height: 105,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PodiumBlock(
              place: 1,
              row: top3[0],
              height: 142,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PodiumBlock(
              place: 3,
              row: top3[2],
              height: 86,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumBlock extends StatelessWidget {
  const _PodiumBlock({
    required this.place,
    required this.row,
    required this.height,
  });

  final int place;
  final _LeaderboardRow row;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isFirst = place == 1;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        NeverestAvatar(name: row.name, size: isFirst ? 56 : 44),
        const SizedBox(height: 8),
        Text(
          row.name.split(' ').first,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 11,
              ),
        ),
        Text(
          row.points.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isFirst ? NeverestPalette.orange : null,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: isFirst
                ? NeverestPalette.orange
                : Theme.of(context).brightness == Brightness.dark
                    ? NeverestPalette.inkRaised
                    : NeverestPalette.paperRaised,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            border: isFirst
                ? null
                : Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? NeverestPalette.inkLine
                        : NeverestPalette.paperLine,
                  ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (isFirst)
                const Positioned.fill(
                  child: NeverestTopographicRings(color: Colors.white, count: 5),
                ),
              Center(
                child: Text(
                  place.toString(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: isFirst ? Colors.white : null,
                        fontSize: 48,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({required this.rows});

  final List<_LeaderboardRow> rows;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
        ),
      ),
      child: Column(
        children: List.generate(rows.length, (index) {
          final row = rows[index];
          final rank = index + 4;
          final isMe = row.name.toLowerCase().contains('andrei');
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              border: index == rows.length - 1
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: isDark
                            ? NeverestPalette.inkLine
                            : NeverestPalette.paperLine,
                      ),
                    ),
              color: isMe ? NeverestPalette.orange.withOpacity(0.11) : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    rank.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isMe ? NeverestPalette.orange : null,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                const SizedBox(width: 10),
                NeverestAvatar(name: row.name, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: isMe ? FontWeight.w800 : FontWeight.w700,
                            ),
                      ),
                      Text(
                        row.delta,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  row.points.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _LeaderboardRow {
  const _LeaderboardRow({
    required this.name,
    required this.points,
    required this.delta,
  });

  final String name;
  final int points;
  final String delta;
}

String _weeklyDeltaFor(String source) {
  final value = source.runes.fold<int>(17, (seed, rune) => seed + rune) % 280;
  return '+$value this week';
}

