import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/services/api_client.dart';
import '../../../../core/navigation/app_page_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../partner/data/partner_repository.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../rewards/presentation/screens/offer_edit_screen.dart';
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

  Future<void> _confirmDeleteOffer(OfferSummary offer) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.offerDeleteTitle),
        content: Text(l10n.offerDeleteConfirm(offer.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<PartnerRepository>().adminDeleteOffer(offer.id);
      if (!mounted) return;
      context.read<DashboardBloc>().add(const DashboardRefreshRequested());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.offerDeletedToast)));
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

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
        final dbCategories =
            state.data?.rewardCategories ?? const <RewardCategory>[];
        final localeCode = Localizations.localeOf(context).languageCode;
        final categories = <String>['ALL', ...dbCategories.map((c) => c.code)];
        final filtered = _category == 'ALL'
            ? source
            : source.where((reward) => _rewardCategory(reward) == _category).toList();
        String labelFor(String code) {
          if (code == 'ALL') return l10n.commonAll;
          for (final c in dbCategories) {
            if (c.code == code) return c.label(localeCode);
          }
          return code;
        }

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
            if ((state.data?.offers ?? const <OfferSummary>[]).isNotEmpty) ...[
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
              const SizedBox(height: 8),
              SizedBox(
                height: 132,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.data!.offers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final offer = state.data!.offers[index];
                    return OfferCard(
                      offer: offer,
                      onEdit: isAdmin
                          ? () => Navigator.of(context).push(
                                AppPageRoute.fadeSlide(
                                  OfferEditScreen(offer: offer),
                                ),
                              )
                          : null,
                      onDelete:
                          isAdmin ? () => _confirmDeleteOffer(offer) : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return NeverestFilterChip(
                    label: labelFor(category),
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
                    categoryLabel: labelFor(_rewardCategory(reward)),
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

    return Opacity(
      opacity: reward.couponUsed ? 0.5 : 1.0,
      child: InkWell(
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
                  if (reward.couponUsed)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: NeverestPalette.success.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 13, color: NeverestPalette.success),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  reward.couponCode ?? '—',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: NeverestPalette.success,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (reward.availableAgainAt != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            '↻ ${_shortDate(reward.availableAgainAt!)}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ],
                    )
                  else
                    Row(
                      children: [
                        Text(
                          reward.pointsCost.toString(),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: canRedeem
                                        ? NeverestPalette.orange
                                        : Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(width: 2),
                        Text(pointsLabel,
                            style: Theme.of(context).textTheme.labelSmall),
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
}

String _shortDate(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

String _rewardCategory(RewardSummary reward) {
  final c = reward.category;
  if (c == null || c.trim().isEmpty) return 'PARTNER';
  return c.toUpperCase();
}

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, this.onEdit, this.onDelete});

  final OfferSummary offer;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  Future<void> _open() async {
    final url = offer.linkUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget? image;
    if (offer.imageB64 != null && offer.imageB64!.isNotEmpty) {
      try {
        final raw = offer.imageB64!.contains(',')
            ? offer.imageB64!.split(',').last
            : offer.imageB64!;
        image = Image.memory(base64Decode(raw), fit: BoxFit.cover);
      } catch (_) {}
    }

    final card = InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: offer.linkUrl != null && offer.linkUrl!.isNotEmpty ? _open : null,
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(
              width: 84,
              color: NeverestPalette.orangeSoft,
              child: image ??
                  const Icon(Icons.local_offer_rounded,
                      color: NeverestPalette.orange, size: 30),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      offer.brand.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: NeverestPalette.orange,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      offer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (offer.discountLabel != null &&
                        offer.discountLabel!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: NeverestPalette.orange,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          offer.discountLabel!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onEdit == null && onDelete == null) {
      return card;
    }
    return Stack(
      children: [
        card,
        Positioned(
          top: 6,
          right: 6,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                _OfferAdminButton(
                  icon: Icons.edit_outlined,
                  color: NeverestPalette.orange,
                  onTap: onEdit!,
                ),
              if (onDelete != null) ...[
                const SizedBox(width: 6),
                _OfferAdminButton(
                  icon: Icons.delete_outline_rounded,
                  color: NeverestPalette.danger,
                  onTap: onDelete!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OfferAdminButton extends StatelessWidget {
  const _OfferAdminButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
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

