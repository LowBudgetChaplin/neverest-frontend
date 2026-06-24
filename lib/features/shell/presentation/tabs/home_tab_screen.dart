import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../partner/presentation/screens/partner_center_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../events/presentation/screens/event_details_screen.dart';
import '../../../profile/domain/app_profile.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/screens/my_qr_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../rewards/presentation/screens/reward_details_screen.dart';
import '../design/neverest_design.dart';
import 'rewards_tab_screen.dart' show OfferCard;

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({
    super.key,
    required this.onSelectTab,
    this.onOpenAdmin,
  });

  final ValueChanged<int> onSelectTab;
  final VoidCallback? onOpenAdmin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profile = context.select<ProfileBloc, AppProfile?>(
      (bloc) => bloc.state.profile,
    );

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final data = state.data;
        final events = (data?.events ?? const <EventSummary>[])
            .where((event) => !event.isPast)
            .toList();
        final challenges = (data?.challenges ?? const <ChallengeSummary>[])
            .where((challenge) => !challenge.isExpired)
            .toList();
        final rewards = data?.rewards ?? const <RewardSummary>[];
        final totalPoints = profile?.totalPoints ?? 0;
        final availablePoints = profile?.availablePoints ?? 0;
        final affordableRewards = rewards
            .where((reward) =>
                reward.pointsCost <= availablePoints && !reward.couponUsed)
            .toList();

        return ListView(
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            top: MediaQuery.paddingOf(context).top + 8,
            bottom: 110,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const NeverestLogo(compact: true),
                  const Spacer(),
                  _NotificationBell(
                    onTap: () => Navigator.of(context)
                        .push(
                          AppPageRoute.fadeSlide(const NotificationsScreen()),
                        )
                        .then((_) => context
                            .read<NotificationCubit>()
                            .refreshUnreadCount()),
                  ),
                  const SizedBox(width: 8),
                  NeverestGlassIconButton(
                    icon: Icons.settings_outlined,
                    onPressed: () {
                      Navigator.of(context).push(
                        AppPageRoute.fadeSlide(const ProfileScreen()),
                      );
                    },
                  ),
                  if (onOpenAdmin != null) ...[
                    const SizedBox(width: 8),
                    NeverestGlassIconButton(
                      icon: Icons.admin_panel_settings_rounded,
                      onPressed: onOpenAdmin,
                    ),
                  ],
                  if (context.select<AccessCubit, bool>(
                      (c) => c.state.canOpenPartnerCenter)) ...[
                    const SizedBox(width: 8),
                    NeverestGlassIconButton(
                      icon: Icons.storefront_rounded,
                      onPressed: () => Navigator.of(context).push(
                        AppPageRoute.fadeSlide(const PartnerCenterScreen()),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            _HomeHeroCard(
              points: totalPoints,
              onShowQr: () {
                Navigator.of(context).push(
                  AppPageRoute.fadeSlide(const MyQrScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.bolt_rounded,
                      title: l10n.homeStartChallenge,
                      subtitle: l10n.homeActiveCount(challenges.length),
                      highlighted: true,
                      onTap: () => onSelectTab(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.calendar_month_rounded,
                      title: l10n.homeFindEvents,
                      subtitle: l10n.homeThisWeekCount(events.length),
                      onTap: () => onSelectTab(1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if ((data?.offers ?? const <OfferSummary>[]).isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  l10n.offersSectionTitle.toUpperCase(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 132,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: data!.offers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) =>
                      OfferCard(offer: data.offers[index]),
                ),
              ),
              const SizedBox(height: 18),
            ],
            // if (liveChallenge != null) ...[
            //   NeverestSectionHeader(
            //     title: l10n.homeLiveNow,
            //     trailing: TextButton(
            //       onPressed: () => onSelectTab(2),
            //       child: Text(l10n.commonAll),
            //     ),
            //   ),
            //   const SizedBox(height: 10),
            //   Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: _LiveCard(
            //       challenge: liveChallenge,
            //       trackingLabel: l10n.homeTrackingLive,
            //       onTap: () {
            //         Navigator.of(context).push(
            //           AppPageRoute.fadeSlide(
            //             ChallengeDetailsScreen(challenge: liveChallenge),
            //           ),
            //         );
            //       },
            //     ),
            //   ),
            // ],
            const SizedBox(height: 22),
            NeverestSectionHeader(
              title: l10n.homeThisWeek,
              trailing: TextButton(
                onPressed: () => onSelectTab(1),
                child: Text(l10n.homeSeeAll),
              ),
            ),
            const SizedBox(height: 10),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.eventsEmptyState,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: events.take(3).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _EventSmallCard(
                      event: event,
                      onTap: () {
                        Navigator.of(context).push(
                          AppPageRoute.fadeSlide(EventDetailsScreen(event: event)),
                        );
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            NeverestSectionHeader(title: l10n.homeSpendPoints),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    availablePoints.toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: NeverestPalette.orange,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.homeAvailableToSpend.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (affordableRewards.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  rewards.isEmpty
                      ? l10n.eventsEmptyState
                      : l10n.homeNothingAffordable,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ...affordableRewards.map(
                (reward) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _RewardSpotlight(
                    reward: reward,
                    pointsLabel: l10n.commonPointsShort,
                    onTap: () {
                      Navigator.of(context).push(
                        AppPageRoute.fadeSlide(
                          RewardDetailsScreen(reward: reward),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (state.status == DashboardStatus.failure) ...[
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Text(
                      state.errorMessage ?? l10n.dashboardLoadFailed,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard({
    required this.points,
    required this.onShowQr,
  });

  final int points;
  final VoidCallback onShowQr;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: NeverestPalette.ink,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: NeverestTopographicLines(
              color: NeverestPalette.orange,
              density: 14,
              opacity: 0.7,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.yourPointsHome,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white.withOpacity(0.66),
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        points.toString(),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 62,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.commonPoints.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: NeverestPalette.orange,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onShowQr,
                  child: Ink(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: NeverestPalette.orange,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 22),
                        const SizedBox(height: 2),
                        Text(
                          'MY\nQR',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = highlighted
        ? NeverestPalette.orange
        : (isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised);
    final foreground = highlighted
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        height: 102,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: highlighted
              ? null
              : Border.all(
                  color: isDark
                      ? NeverestPalette.inkLine
                      : NeverestPalette.paperLine,
                ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: foreground, size: 22),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: highlighted
                        ? Colors.white.withOpacity(0.82)
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.65),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveCard extends StatelessWidget {
  const _LiveCard({
    required this.challenge,
    required this.trackingLabel,
    required this.onTap,
  });

  final ChallengeSummary challenge;
  final String trackingLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
          ),
        ),
        child: Column(
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
                  trackingLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: NeverestPalette.orange,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                Text(
                  '+${challenge.pointsReward}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: NeverestPalette.orange,
                        fontSize: 22,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                challenge.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            if (challenge.description != null && challenge.description!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  challenge.description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventSmallCard extends StatelessWidget {
  const _EventSmallCard({
    required this.event,
    required this.onTap,
  });

  final EventSummary event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activityColor = neverestActivityColor(event.activityType);
    final date = DateTime.tryParse(event.startsAt);
    final weekday = date == null
        ? 'SAT'
        : ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'][date.weekday - 1];
    final day = date?.day.toString().padLeft(2, '0') ?? '11';
    final time = date == null
        ? '07:00'
        : '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final location = event.location.split('·').first.trim();

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        width: 220,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? NeverestPalette.inkRaised
              : NeverestPalette.paperRaised,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? NeverestPalette.inkLine
                : NeverestPalette.paperLine,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 92,
              width: double.infinity,
              decoration: BoxDecoration(
                color: NeverestPalette.ink,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: NeverestTopographicLines(
                      color: activityColor,
                      density: 10,
                      opacity: 0.75,
                      withPeak: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                            const SizedBox(width: 4),
                            Text(
                              event.activityType.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 1.1,
                                  ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          day,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                        ),
                        Text(
                          '$weekday · $time',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.74),
                                letterSpacing: 0.9,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '+${event.pointsReward}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: NeverestPalette.orange,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardSpotlight extends StatelessWidget {
  const _RewardSpotlight({
    required this.reward,
    required this.pointsLabel,
    required this.onTap,
  });

  final RewardSummary reward;
  final String pointsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? NeverestPalette.inkRaised
              : NeverestPalette.paperRaised,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? NeverestPalette.inkLine
                : NeverestPalette.paperLine,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF5A2D1E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: NeverestTopographicRings(color: Colors.white, count: 6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.partnerName.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reward.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${reward.pointsCost} $pointsLabel',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: NeverestPalette.orange,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = context.select<NotificationCubit, int>(
      (cubit) => cubit.state.unreadCount,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        NeverestGlassIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: onTap,
        ),
        if (unread > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: NeverestPalette.orange,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                unread > 9 ? '9+' : '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

