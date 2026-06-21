import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../app/services/api_client.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../challenges/data/challenge_action_repository.dart';
import '../../../challenges/presentation/screens/challenge_details_screen.dart';
import '../../../challenges/presentation/screens/challenge_edit_screen.dart';
import '../design/neverest_design.dart';

class ChallengesTabScreen extends StatefulWidget {
  const ChallengesTabScreen({super.key});

  @override
  State<ChallengesTabScreen> createState() => _ChallengesTabScreenState();
}

class _ChallengesTabScreenState extends State<ChallengesTabScreen> {
  static const int _pageSize = 10;
  static const int _maxArchive = 100;

  bool _showCompleted = false;
  bool _partnerOnly = false;
  bool _showExpired = false;
  int _expiredPage = 0;

  Future<void> _confirmDeleteChallenge(ChallengeSummary challenge) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Șterge obiectivul'),
        content: Text('Sigur ștergi „${challenge.title}”? Acțiunea nu poate fi anulată.'),
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
      await context.read<ChallengeActionRepository>().deleteChallenge(challenge.id);
      if (!mounted) return;
      context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Obiectiv șters.')));
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
        final active = items
            .where((item) => !item.done && !_challengeExpired(item.summary))
            .toList();
        final done = items.where((item) => item.done).toList();
        // Obiectivele expirate (neterminate) raman doar pentru admin, ca arhiva.
        final expired = items
            .where((item) => !item.done && _challengeExpired(item.summary))
            .toList()
          ..sort((a, b) =>
              (b.summary.endsAt ?? '').compareTo(a.summary.endsAt ?? ''));
        final showingExpired = isAdmin && _showExpired;

        var list = showingExpired
            ? expired
            : (_showCompleted ? done : active);
        if (_partnerOnly) {
          list = list
              .where((item) => item.summary.isPartnerChallenge)
              .toList();
        }

        // Arhiva expirata: plafon 100, paginare 10/pagina (max 10 pagini).
        final cappedArchive =
            list.length > _maxArchive ? list.sublist(0, _maxArchive) : list;
        final totalPages = showingExpired
            ? (cappedArchive.length / _pageSize).ceil().clamp(1, 10)
            : 1;
        final safePage =
            showingExpired ? _expiredPage.clamp(0, totalPages - 1) : 0;
        if (showingExpired) {
          list = cappedArchive
              .skip(safePage * _pageSize)
              .take(_pageSize)
              .toList();
        }

        final hasPartnerChallenges =
            items.any((item) => item.summary.isPartnerChallenge);

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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  NeverestFilterChip(
                    label: l10n.challengesActiveCount(active.length),
                    selected: !_showCompleted && !_showExpired,
                    onTap: () => setState(() {
                      _showCompleted = false;
                      _showExpired = false;
                    }),
                  ),
                  const SizedBox(width: 8),
                  NeverestFilterChip(
                    label: l10n.challengesCompletedCount(done.length),
                    selected: _showCompleted && !_showExpired,
                    onTap: () => setState(() {
                      _showCompleted = true;
                      _showExpired = false;
                    }),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(width: 8),
                    NeverestFilterChip(
                      label: 'Expirate (${expired.length})',
                      icon: Icons.history_rounded,
                      selected: _showExpired,
                      onTap: () => setState(() {
                        _showExpired = true;
                        _showCompleted = false;
                        _expiredPage = 0;
                      }),
                    ),
                  ],
                  if (hasPartnerChallenges) ...[
                    const SizedBox(width: 8),
                    NeverestFilterChip(
                      label: l10n.challengesPartnerFilter,
                      selected: _partnerOnly,
                      icon: Icons.storefront_rounded,
                      onTap: () =>
                          setState(() => _partnerOnly = !_partnerOnly),
                    ),
                  ],
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
            else ...[
              ...list.map(
                (item) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: showingExpired ? 0.55 : 1,
                        child: _ChallengeCard(
                          item: item,
                          featured: true,
                          onDelete: isAdmin
                              ? () => _confirmDeleteChallenge(item.summary)
                              : null,
                          onEdit: isAdmin
                              ? () => Navigator.of(context).push(
                                    AppPageRoute.fadeSlide(
                                      ChallengeEditScreen(
                                          challenge: item.summary),
                                    ),
                                  )
                              : null,
                          onTap: () {
                            Navigator.of(context).push(
                              AppPageRoute.fadeSlide(
                                ChallengeDetailsScreen(challenge: item.summary),
                              ),
                            );
                          },
                        ),
                      ),
                      if (showingExpired)
                        const Positioned(
                          top: 12,
                          right: 12,
                          child: _ExpiredBadge(),
                        ),
                    ],
                  ),
                ),
              ),
              if (showingExpired && totalPages > 1)
                _Pager(
                  page: safePage,
                  totalPages: totalPages,
                  onPrev: safePage > 0
                      ? () => setState(() => _expiredPage = safePage - 1)
                      : null,
                  onNext: safePage < totalPages - 1
                      ? () => setState(() => _expiredPage = safePage + 1)
                      : null,
                ),
            ],
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
    this.onDelete,
    this.onEdit,
  });

  final _ChallengeItem item;
  final bool featured;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

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

    final sportColor = neverestActivityColor(item.summary.activityType);
    final accent = item.done
        ? (isDark ? NeverestPalette.inkMuted : NeverestPalette.paperMuted)
        : sportColor;

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

    final deadlineText = Text(
      item.deadline.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: featured
                ? Colors.white.withOpacity(0.55)
                : (isDark ? NeverestPalette.inkMuted : NeverestPalette.paperMuted),
            letterSpacing: 0.8,
          ),
    );

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
      final muted =
          isDark ? NeverestPalette.inkMuted : NeverestPalette.paperMuted;
      final base =
          isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised;
      // tenta de fundal preia culoarea sportului (sau gri pentru cele done)
      final lineColor =
          isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine;
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
                    if (onEdit != null || onDelete != null)
                      const SizedBox(width: 72),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  item.summary.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: muted, height: 1.35),
                ),
                if (item.summary.isPartnerChallenge) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront_rounded, size: 13, color: accent),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'POWERED BY ${item.summary.brand!.toUpperCase()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (item.summary.isPartnerChallenge) ...[
                      Icon(Icons.card_giftcard_rounded, size: 18, color: accent),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item.summary.rewardLabel ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ] else ...[
                      Text(
                        '+${item.summary.pointsReward}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          AppLocalizations.of(context)!.commonPoints.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: muted,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                        ),
                      ),
                    ],
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
                if (onEdit != null)
                  Positioned(
                    top: 8,
                    right: onDelete != null ? 48 : 8,
                    child: Material(
                      color: NeverestPalette.orange.withOpacity(0.12),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onEdit,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.edit_outlined,
                              size: 18, color: NeverestPalette.orange),
                        ),
                      ),
                    ),
                  ),
                if (onDelete != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: NeverestPalette.danger.withOpacity(0.12),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: onDelete,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.delete_outline_rounded,
                              size: 18, color: NeverestPalette.danger),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

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
                item.done ? Icons.check_rounded : icon,
                color: item.done ? NeverestPalette.inkMuted : NeverestPalette.orange,
                size: 20,
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
            pointsWidget,
          ],
        ),
      ),
    );
  }
}

bool _challengeExpired(ChallengeSummary summary) {
  final endsAt = summary.endsAt;
  if (endsAt == null || endsAt.isEmpty) return false;
  final date = DateTime.tryParse(endsAt);
  if (date == null) return false;
  final endDay = DateTime(date.year, date.month, date.day);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return endDay.isBefore(today);
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

class _ExpiredBadge extends StatelessWidget {
  const _ExpiredBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: NeverestPalette.danger,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'EXPIRAT',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
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

