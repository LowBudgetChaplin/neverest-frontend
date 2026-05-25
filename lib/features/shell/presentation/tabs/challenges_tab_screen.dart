import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../challenges/presentation/screens/challenge_details_screen.dart';
import '../design/neverest_design.dart';

class ChallengesTabScreen extends StatefulWidget {
  const ChallengesTabScreen({super.key});

  @override
  State<ChallengesTabScreen> createState() => _ChallengesTabScreenState();
}

class _ChallengesTabScreenState extends State<ChallengesTabScreen> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final source = state.data?.challenges ?? const <ChallengeSummary>[];
        if (source.isEmpty) {
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
                  l10n.challengesTitle.toUpperCase(),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 38,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.challengesSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.eventsEmptyState,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        }
        final items = _toChallengeItems(source, l10n);
        final active = items.where((item) => !item.done).toList();
        final done = items.where((item) => item.done).toList();
        final list = _showCompleted ? done : active;
        final featured = active.isNotEmpty ? active.first : items.first;

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
                l10n.challengesTitle.toUpperCase(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 38,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.challengesSubtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  NeverestFilterChip(
                    label: l10n.challengesActiveCount(active.length),
                    selected: !_showCompleted,
                    onTap: () => setState(() => _showCompleted = false),
                  ),
                  const SizedBox(width: 8),
                  NeverestFilterChip(
                    label: l10n.challengesCompletedCount(done.length),
                    selected: _showCompleted,
                    onTap: () => setState(() => _showCompleted = true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FeaturedChallengeCard(
                challenge: featured,
                liveLabel: l10n.challengeLiveTracking,
                onTap: () {
                  Navigator.of(context).push(
                    AppPageRoute.fadeSlide(
                      ChallengeDetailsScreen(challenge: featured.summary),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            ...list
                .where((item) => item.id != featured.id || _showCompleted)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _ChallengeRow(
                      item: item,
                      onTap: () {
                        Navigator.of(context).push(
                          AppPageRoute.fadeSlide(
                            ChallengeDetailsScreen(challenge: item.summary),
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

class _FeaturedChallengeCard extends StatelessWidget {
  const _FeaturedChallengeCard({
    required this.challenge,
    required this.liveLabel,
    required this.onTap,
  });

  final _ChallengeItem challenge;
  final String liveLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        height: 232,
        decoration: BoxDecoration(
          color: NeverestPalette.ink,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: NeverestTopographicLines(
                color: NeverestPalette.orange,
                density: 16,
                opacity: 0.7,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: NeverestPalette.orange,
                          borderRadius: BorderRadius.circular(99),
                          boxShadow: [
                            BoxShadow(
                              color: NeverestPalette.orange.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        liveLabel.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: NeverestPalette.orange,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        challenge.deadline.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white.withOpacity(0.62),
                            ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    challenge.summary.title.toUpperCase(),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 34,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.72),
                        ),
                  ),
                  const SizedBox(height: 12),
                  NeverestProgressBar(value: challenge.progress),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '3.1 / 7.4 km',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.74),
                            ),
                      ),
                      const Spacer(),
                      Text(
                        '+${challenge.summary.pointsReward} PTS',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: NeverestPalette.orange,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  const _ChallengeRow({
    required this.item,
    required this.onTap,
  });

  final _ChallengeItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = item.done
        ? Icons.check_rounded
        : switch (item.summary.mode.toUpperCase()) {
            'ONLINE' => Icons.route_rounded,
            'OFFLINE' => Icons.flag_rounded,
            _ => Icons.bolt_rounded,
          };
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.done
                    ? (isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine)
                    : NeverestPalette.orangeSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: item.done ? NeverestPalette.inkMuted : NeverestPalette.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.summary.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.subtitle} · ${item.deadline}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (!item.done) ...[
                    const SizedBox(height: 8),
                    NeverestProgressBar(value: item.progress),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${item.summary.pointsReward}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: item.done
                            ? Theme.of(context).textTheme.bodySmall?.color
                            : NeverestPalette.orange,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                Text(
                  item.done
                      ? AppLocalizations.of(context)!.challengesEarned
                      : AppLocalizations.of(context)!.commonPoints,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<_ChallengeItem> _toChallengeItems(
  List<ChallengeSummary> source,
  AppLocalizations l10n,
) {
  final defaults = [
    (0.46, false, true, l10n.challengeRouteSubtitle, l10n.challengeDeadlineSun),
    (
      0.49,
      false,
      false,
      l10n.challengeDistanceSubtitle,
      l10n.challengeDeadlineDays(6)
    ),
    (0.66, false, false, l10n.challengeMorningSubtitle, l10n.challengeProgress23),
    (
      0.60,
      false,
      false,
      l10n.challengePadelSubtitle,
      l10n.challengeDeadlineJune
    ),
    (1.0, true, false, l10n.challengeForestSubtitle, l10n.challengeAlwaysOn),
  ];

  return List.generate(source.length, (index) {
    final template = defaults[index % defaults.length];
    return _ChallengeItem(
      summary: source[index],
      progress: template.$1,
      done: template.$2,
      live: template.$3,
      subtitle: template.$4,
      deadline: template.$5,
    );
  });
}

class _ChallengeItem {
  const _ChallengeItem({
    required this.summary,
    required this.progress,
    required this.done,
    required this.live,
    required this.subtitle,
    required this.deadline,
  });

  final ChallengeSummary summary;
  final double progress;
  final bool done;
  final bool live;
  final String subtitle;
  final String deadline;

  String get id => summary.id;
}

