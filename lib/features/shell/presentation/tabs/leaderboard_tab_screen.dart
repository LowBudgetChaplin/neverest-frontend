import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../leaderboard/presentation/cubit/activity_leaderboard_cubit.dart';
import '../../../profile/domain/app_profile.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../design/neverest_design.dart';

class LeaderboardTabScreen extends StatefulWidget {
  const LeaderboardTabScreen({super.key});

  @override
  State<LeaderboardTabScreen> createState() => _LeaderboardTabScreenState();
}

class _LeaderboardTabScreenState extends State<LeaderboardTabScreen> {
  String _selectedActivity = 'ALL';

  void _selectActivity(String activity) {
    setState(() => _selectedActivity = activity);
    if (activity != 'ALL') {
      context.read<ActivityLeaderboardCubit>().load(activity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final myProfile = context.select<ProfileBloc, AppProfile?>(
      (bloc) => bloc.state.profile,
    );

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, dashState) {
        return BlocBuilder<ActivityLeaderboardCubit, ActivityLeaderboardState>(
          builder: (context, activityState) {
            final List<LeaderboardEntrySummary> rawRows;
            final bool isLoadingActivity;
            if (_selectedActivity == 'ALL') {
              rawRows = dashState.data?.leaderboard ?? const [];
              isLoadingActivity = false;
            } else {
              rawRows = activityState.activityType == _selectedActivity
                  ? activityState.entries
                  : const [];
              isLoadingActivity = activityState.isLoading;
            }

            final normalized = rawRows
                .map(
                  (entry) => _LeaderboardRow(
                    userId: entry.userId,
                    name: entry.displayName,
                    points: entry.points,
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
                        onTap: () => _selectActivity('ALL'),
                      ),
                      const SizedBox(width: 8),
                      NeverestFilterChip(
                        label: l10n.activityRunning,
                        selected: _selectedActivity == 'RUNNING',
                        icon: Icons.directions_run_rounded,
                        onTap: () => _selectActivity('RUNNING'),
                      ),
                      const SizedBox(width: 8),
                      NeverestFilterChip(
                        label: l10n.activityMountain,
                        selected: _selectedActivity == 'MOUNTAIN',
                        icon: Icons.terrain_rounded,
                        onTap: () => _selectActivity('MOUNTAIN'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (isLoadingActivity)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (activityState.errorMessage != null && _selectedActivity != 'ALL')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Text(
                      activityState.errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _Podium(top3: top3, myUserId: myProfile?.id),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _LeaderboardList(rows: others, myUserId: myProfile?.id),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.top3, this.myUserId});

  final List<_LeaderboardRow> top3;
  final String? myUserId;

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
          Expanded(child: _PodiumBlock(place: 2, row: top3[1], height: 105, isMe: top3[1].userId == myUserId)),
          const SizedBox(width: 8),
          Expanded(child: _PodiumBlock(place: 1, row: top3[0], height: 142, isMe: top3[0].userId == myUserId)),
          const SizedBox(width: 8),
          Expanded(child: _PodiumBlock(place: 3, row: top3[2], height: 86, isMe: top3[2].userId == myUserId)),
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
    this.isMe = false,
  });

  final int place;
  final _LeaderboardRow row;
  final double height;
  final bool isMe;

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
  const _LeaderboardList({required this.rows, this.myUserId});

  final List<_LeaderboardRow> rows;
  final String? myUserId;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
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
          final isMe = myUserId != null && row.userId == myUserId;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              border: index == rows.length - 1
                  ? null
                  : Border(
                      bottom: BorderSide(
                        color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
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
                  child: Text(
                    row.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: isMe ? FontWeight.w800 : FontWeight.w700,
                        ),
                  ),
                ),
                Text(
                  row.points.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isMe ? NeverestPalette.orange : null,
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
    required this.userId,
    required this.name,
    required this.points,
  });

  final String userId;
  final String name;
  final int points;
}

