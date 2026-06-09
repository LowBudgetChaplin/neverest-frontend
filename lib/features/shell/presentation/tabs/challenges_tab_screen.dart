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
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: Text(
              //     l10n.challengesSubtitle,
              //     style: Theme.of(context).textTheme.bodySmall,
              //   ),
              // ),
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
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20),
            //   child: Text(
            //     l10n.challengesSubtitle,
            //     style: Theme.of(context).textTheme.bodySmall,
            //   ),
            // ),
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
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _showCompleted
                      ? l10n.challengesNoCompleted
                      : l10n.eventsEmptyState,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ...list.map(
                (item) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: _ChallengeCard(
                    item: item,
                    featured: true,
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

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.item,
    required this.featured,
    required this.onTap,
  });

  final _ChallengeItem item;
  final bool featured;
  final VoidCallback onTap;

  static IconData _activityIcon(String type) => switch (type.toUpperCase()) {
        'RUNNING' => Icons.directions_run_rounded,
        'CYCLING' => Icons.directions_bike_rounded,
        'SWIMMING' => Icons.pool_rounded,
        'MOUNTAIN' => Icons.terrain_rounded,
        _ => Icons.bolt_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = _activityIcon(item.summary.activityType);

    // ── culoare per sport ─────────────────────────────────────────────────────
    final sportColor = neverestActivityColor(item.summary.activityType);
    final accent = item.done
        ? (isDark ? NeverestPalette.inkMuted : NeverestPalette.paperMuted)
        : sportColor;

    // ── badge tip activitate ──────────────────────────────────────────────────
    final activityBadge = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: accent),
        const SizedBox(width: 4),
        Text(
          item.summary.activityType.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: accent,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );

    // ── deadline ─────────────────────────────────────────────────────────────
    final deadlineText = Text(
      item.deadline.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: featured
                ? Colors.white.withOpacity(0.55)
                : (isDark ? NeverestPalette.inkMuted : NeverestPalette.paperMuted),
            letterSpacing: 0.8,
          ),
    );

    // ── punkte ───────────────────────────────────────────────────────────────
    final pointsWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '+${item.summary.pointsReward}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w900,
              ),
        ),
        Text(
          item.done
              ? AppLocalizations.of(context)!.challengesEarned
              : AppLocalizations.of(context)!.commonPoints,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isDark ? NeverestPalette.inkMuted : NeverestPalette.paperMuted,
              ),
        ),
      ],
    );

    if (featured) {
      // ── CARD MINIMALIST ── fundal plat cu tentă subtilă pe sport, fără
      //    wave-uri, fără cutie de iconiță, fără divider. Doar tipografie
      //    aerisită + un accent discret de culoare în spate.
      final muted =
          isDark ? NeverestPalette.inkMuted : NeverestPalette.paperMuted;
      final base =
          isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised;
      // tenta de fundal preia culoarea sportului (sau gri pentru cele done)
      final lineColor =
          isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine;
      // fundal minimalist specific sportului: o iconita mare, foarte discreta
      // (gri pentru provocarile finalizate)
      final watermark =
          (item.done ? muted : sportColor).withOpacity(isDark ? 0.08 : 0.06);

      return InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: lineColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned(
                  right: -14,
                  bottom: -20,
                  child: Icon(icon, size: 140, color: watermark),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 18, 18),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header: punct + sport ····· deadline / finalizat
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(icon, size: 14, color: accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.summary.activityType.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: accent,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (item.done)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              size: 14, color: NeverestPalette.success),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context)!
                                .challengesCompletedTag
                                .toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: NeverestPalette.success,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      )
                    else
                      Text(
                        item.deadline.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: muted,
                              letterSpacing: 0.8,
                            ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                // titlu
                Text(
                  item.summary.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                      ),
                ),
                const SizedBox(height: 6),
                // subtitlu / descriere
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: muted, height: 1.35),
                ),
                const SizedBox(height: 20),
                // footer: puncte ····· buton săgeată rotund
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '+${item.summary.pointsReward}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        AppLocalizations.of(context)!.commonPoints.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(isDark ? 0.18 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 18, color: accent),
                    ),
                  ],
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

    // ── CARD COMPACT (row) ── aceeași structură, layout orizontal ─────────
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
            // icoana activitate
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
                item.done ? Icons.check_rounded : icon,
                color: item.done ? NeverestPalette.inkMuted : NeverestPalette.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // titlu + badge + deadline
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
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      activityBadge,
                      Text(
                        '  ·  ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? NeverestPalette.inkMuted
                                  : NeverestPalette.paperMuted,
                            ),
                      ),
                      deadlineText,
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? NeverestPalette.inkMuted
                              : NeverestPalette.paperMuted,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // puncte
            pointsWidget,
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
  return source.map((summary) {
    final subtitle = _subtitleFor(summary);
    final deadline = _deadlineLabelFor(summary, l10n);
    return _ChallengeItem(
      summary: summary,
      subtitle: subtitle,
      deadline: deadline,
    );
  }).toList();
}

String _subtitleFor(ChallengeSummary summary) {
  if (summary.description != null && summary.description!.isNotEmpty) {
    return summary.description!;
  }
  if (summary.targetValue != null && summary.targetUnit != null) {
    return '${summary.targetValue!.toStringAsFixed(1)} ${summary.targetUnit}';
  }
  return '${summary.activityType} · ${summary.frequency}';
}

String _deadlineLabelFor(ChallengeSummary summary, AppLocalizations l10n) {
  final endsAt = summary.endsAt;
  if (endsAt == null || endsAt.isEmpty) {
    return summary.frequency.toUpperCase();
  }
  final date = DateTime.tryParse(endsAt);
  if (date == null) return endsAt;
  final diff = date.difference(DateTime.now()).inDays;
  if (diff < 0) return l10n.challengeAlwaysOn;
  if (diff == 0) return 'TODAY';
  if (diff <= 7) return l10n.challengeDeadlineDays(diff);
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

class _ChallengeItem {
  const _ChallengeItem({
    required this.summary,
    required this.subtitle,
    required this.deadline,
  });

  final ChallengeSummary summary;
  final String subtitle;
  final String deadline;
  bool get done => summary.completed;
  String get id => summary.id;
}

