import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../rewards/presentation/screens/reward_details_screen.dart';
import '../../../rewards/presentation/screens/reward_edit_screen.dart';
import '../../../rewards/presentation/screens/reward_history_screen.dart';
import '../design/neverest_design.dart';

class RewardsTabScreen extends StatefulWidget {
  const RewardsTabScreen({super.key});

  @override
  State<RewardsTabScreen> createState() => _RewardsTabScreenState();
}

class _RewardsTabScreenState extends State<RewardsTabScreen> {
  String _category = 'ALL';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final points = context.select<ProfileBloc, int>(
      (bloc) => bloc.state.profile?.availablePoints ?? 0,
    );
    final isAdmin = context.select<AccessCubit, bool>(
      (cubit) => cubit.state.canOpenAdminCenter,
    );
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final source = state.data?.rewards ?? const <RewardSummary>[];
        final categories = <String>{
          'ALL',
          ...source.map(_rewardCategory),
        }.toList();
        final filtered = _category == 'ALL'
            ? source
            : source.where((reward) => _rewardCategory(reward) == _category).toList();

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
                l10n.rewardsTitle.toUpperCase(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 38,
                    ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _WalletCard(
                points: points,
                walletLabel: l10n.rewardsWallet,
                historyLabel: l10n.rewardsHistory,
                onHistoryTap: () => Navigator.of(context).push(
                  AppPageRoute.fadeSlide(const RewardHistoryScreen()),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final label = category == 'ALL'
                      ? l10n.commonAll
                      : _localizedCategoryLabel(l10n, category);
                  return NeverestFilterChip(
                    label: label,
                    selected: _category == category,
                    onTap: () => setState(() => _category = category),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: categories.length,
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: filtered.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 220,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final reward = filtered[index];
                  return _RewardGridCard(
                    reward: reward,
                    myPoints: points,
                    categoryLabel: _localizedCategoryLabel(
                      l10n,
                      _rewardCategory(reward),
                    ),
                    redeemLabel: l10n.rewardsRedeem,
                    pointsLabel: l10n.commonPointsShort,
                    onTap: () {
                      Navigator.of(context).push(
                        AppPageRoute.fadeSlide(
                          RewardDetailsScreen(reward: reward),
                        ),
                      );
                    },
                    onEdit: isAdmin
                        ? () {
                            Navigator.of(context).push(
                              AppPageRoute.fadeSlide(
                                RewardEditScreen(reward: reward),
                              ),
                            );
                          }
                        : null,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.points,
    required this.walletLabel,
    required this.historyLabel,
    required this.onHistoryTap,
  });

  final int points;
  final String walletLabel;
  final String historyLabel;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NeverestPalette.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: NeverestTopographicLines(
              color: NeverestPalette.orange,
              density: 8,
              opacity: 0.6,
              withPeak: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        walletLabel.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 1.5,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$points PTS',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontSize: 34,
                            ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: onHistoryTap,
                  icon: const Icon(Icons.history_rounded, size: 16),
                  label: Text(historyLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardGridCard extends StatelessWidget {
  const _RewardGridCard({
    required this.reward,
    required this.myPoints,
    required this.categoryLabel,
    required this.redeemLabel,
    required this.pointsLabel,
    required this.onTap,
    this.onEdit,
  });

  final RewardSummary reward;
  final int myPoints;
  final String categoryLabel;
  final String redeemLabel;
  final String pointsLabel;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canRedeem = myPoints >= reward.pointsCost;
    final accent = _rewardAccent(reward);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 98,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NeverestRewardImage(
                    imageB64: reward.imageB64,
                    fallbackColor: accent,
                    ringCount: 6,
                  ),
                  // gradient pentru lizibilitatea numelui peste o poza
                  if (reward.imageB64 != null && reward.imageB64!.isNotEmpty)
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        reward.partnerName.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                  ),
                  if (onEdit != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.black.withOpacity(0.45),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onEdit,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.edit_rounded,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categoryLabel, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 3),
                  Text(
                    reward.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        reward.pointsCost.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: canRedeem
                                  ? NeverestPalette.orange
                                  : Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(width: 2),
                      Text(pointsLabel, style: Theme.of(context).textTheme.labelSmall),
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

String _rewardCategory(RewardSummary reward) {
  final partner = reward.partnerName.toLowerCase();
  final title = reward.title.toLowerCase();
  if (partner.contains('cartur') || title.contains('book') || title.contains('carte')) {
    return 'BOOKS';
  }
  if (partner.contains('tiny cup') || partner.contains('origo') || title.contains('coffee') || title.contains('cafea')) {
    return 'CAFE';
  }
  if (partner.contains('bazar') || partner.contains('muzic') || title.contains('vinyl') || title.contains('music')) {
    return 'MUSIC';
  }
  if (partner.contains('print') || title.contains('print')) {
    return 'PRINT';
  }
  if (partner.contains('moca') || title.contains('order')) {
    return 'GOODS';
  }
  return 'ALL';
}

String _localizedCategoryLabel(AppLocalizations l10n, String category) {
  return switch (category) {
    'BOOKS' => l10n.rewardsCategoryBooks,
    'CAFE' => l10n.rewardsCategoryCafe,
    'MUSIC' => l10n.rewardsCategoryMusic,
    'GOODS' => l10n.rewardsCategoryGoods,
    'PRINT' => l10n.rewardsCategoryPrint,
    _ => l10n.commonAll,
  };
}

Color _rewardAccent(RewardSummary reward) {
  return switch (_rewardCategory(reward)) {
    'BOOKS' => const Color(0xFFA85D3C),
    'CAFE' => const Color(0xFF3B2A1E),
    'MUSIC' => const Color(0xFF1E2C3B),
    'PRINT' => const Color(0xFF2A3B4A),
    'GOODS' => const Color(0xFF2B4733),
    _ => const Color(0xFF5A2D1E),
  };
}

