import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../shell/presentation/design/neverest_design.dart';
import '../../data/reward_action_repository.dart';
import '../../domain/reward_redemption_item.dart';
import '../bloc/reward_action_bloc.dart';

class RewardDetailsScreen extends StatelessWidget {
  const RewardDetailsScreen({
    super.key,
    required this.reward,
  });

  final RewardSummary reward;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RewardActionBloc(
        repository: context.read<RewardActionRepository>(),
      ),
      child: _RewardDetailsView(reward: reward),
    );
  }
}

class _RewardDetailsView extends StatefulWidget {
  const _RewardDetailsView({required this.reward});

  final RewardSummary reward;

  @override
  State<_RewardDetailsView> createState() => _RewardDetailsViewState();
}

class _RewardDetailsViewState extends State<_RewardDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRedemptions());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stockLabel = widget.reward.stock == null
        ? l10n.rewardUnlimited
        : widget.reward.stock.toString();
    final accent = _rewardAccent(widget.reward);

    return Scaffold(
      body: BlocConsumer<RewardActionBloc, RewardActionState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage ||
            previous.lastRedemption != current.lastRedemption,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            context.read<RewardActionBloc>().add(const RewardMessagesCleared());
            return;
          }

          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty &&
              state.lastRedemption != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            context
                .read<DashboardBloc>()
                .add(const DashboardRefreshRequested());

            final currentName =
                context.read<ProfileBloc>().state.profile?.displayName ??
                    'Neverest User';
            context.read<ProfileBloc>().add(
                  ProfileLoadRequested(
                    suggestedDisplayName: currentName,
                    preferMeEndpoints: true,
                  ),
                );
            context.read<RewardActionBloc>().add(const RewardMessagesCleared());
            _showRedeemDialog(context, state.lastRedemption!, widget.reward, accent);
          }
        },
        builder: (context, state) {
          final points = context.select<ProfileBloc, int>(
            (bloc) => bloc.state.profile?.availablePoints ?? 1840,
          );
          final canRedeem = points >= widget.reward.pointsCost;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      height: 286,
                      decoration: BoxDecoration(
                        color: accent,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: NeverestRewardImage(
                              imageB64: widget.reward.imageB64,
                              fallbackColor: accent,
                              ringCount: 10,
                            ),
                          ),

                          if (widget.reward.imageB64 != null &&
                              widget.reward.imageB64!.isNotEmpty)
                            const Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.black26, Colors.black87],
                                  ),
                                ),
                              ),
                            ),
                          SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      NeverestGlassIconButton(
                                        icon: Icons.arrow_back_rounded,
                                        foreground: Colors.white,
                                        background: Colors.black.withOpacity(0.35),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_rewardCategory(widget.reward)} · ${l10n.rewardLocalPartner}'
                                        .toUpperCase(),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.white.withOpacity(0.76),
                                          letterSpacing: 1.4,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.reward.partnerName.toUpperCase(),
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          color: Colors.white,
                                          fontSize: 44,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.reward.title,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? NeverestPalette.inkRaised
                              : NeverestPalette.paperRaised,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? NeverestPalette.inkLine
                                : NeverestPalette.paperLine,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _CostBlock(
                                label: l10n.rewardCost,
                                value: '${widget.reward.pointsCost}',
                                suffix: 'PTS',
                                accent: true,
                              ),
                            ),
                            Expanded(
                              child: _CostBlock(
                                label: l10n.rewardYourBalance,
                                value: points.toString(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      child: Text(
                        l10n.rewardHowItWorks.toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _StepRow(
                            index: 1,
                            title: l10n.rewardStep1Title,
                            subtitle: l10n.rewardStep1Subtitle,
                          ),
                          const SizedBox(height: 10),
                          _StepRow(
                            index: 2,
                            title: l10n.rewardStep2Title,
                            subtitle: l10n.rewardStep2Subtitle,
                          ),
                          const SizedBox(height: 10),
                          _StepRow(
                            index: 3,
                            title: l10n.rewardStep3Title,
                            subtitle: l10n.rewardStep3Subtitle,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: (widget.reward.address != null &&
                                widget.reward.address!.trim().isNotEmpty)
                            ? () => _openInMaps(widget.reward.address!)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? NeverestPalette.inkRaised
                                : NeverestPalette.paperRaised,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? NeverestPalette.inkLine
                                  : NeverestPalette.paperLine,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.reward.address ?? l10n.rewardLocationAddress,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      l10n.rewardLocationSchedule(stockLabel),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_outward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (state.redemptions.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                        child: Text(
                          l10n.rewardsHistory.toUpperCase(),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                        ),
                      ),
                      ...state.redemptions.map(
                        (redemption) => Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          child: _RedemptionTile(item: redemption),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  MediaQuery.paddingOf(context).bottom > 0
                      ? MediaQuery.paddingOf(context).bottom + 8
                      : 18,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.surface.withOpacity(0),
                      Theme.of(context).colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: (widget.reward.couponUsed &&
                          widget.reward.couponCode != null)
                      ? FilledButton.icon(
                          onPressed: () => _showQrDialog(
                            context,
                            widget.reward.couponCode!,
                            widget.reward,
                            accent,
                          ),
                          icon: const Icon(Icons.qr_code_2_rounded),
                          label: Text(l10n.showQRCode),
                        )
                      : FilledButton(
                          onPressed: state.isRedeeming || !canRedeem
                              ? null
                              : _redeemReward,
                          child: Text(
                            canRedeem
                                ? l10n.rewardRedeemButton(widget.reward.pointsCost)
                                : l10n.rewardNeedMore(
                                    widget.reward.pointsCost - points),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _loadRedemptions() {
    context.read<RewardActionBloc>().add(
          RewardRedemptionsLoadRequested(userId: _profileUserId()),
        );
  }

  void _redeemReward() {
    context.read<RewardActionBloc>().add(
          RewardRedeemRequested(
            rewardId: widget.reward.id,
            userId: _profileUserId(),
          ),
        );
  }

  String? _profileUserId() {
    return context.read<ProfileBloc>().state.profile?.id;
  }

  Future<void> _openInMaps(String address) async {
    final query = Uri.encodeComponent(address.trim());
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _CostBlock extends StatelessWidget {
  const _CostBlock({
    required this.label,
    required this.value,
    this.suffix,
    this.accent = false,
  });

  final String label;
  final String value;
  final String? suffix;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.3),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            text: value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 30,
                  color: accent ? NeverestPalette.orange : null,
                ),
            children: [
              if (suffix != null)
                TextSpan(
                  text: ' $suffix',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  final int index;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: dark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: dark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            index.toString(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: NeverestPalette.orange,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RedemptionTile extends StatelessWidget {
  const _RedemptionTile({required this.item});

  final RewardRedemptionItem item;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.rewardTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            item.redemptionCode,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.2,
                ),
          ),
          Text(
            '-${item.pointsSpent} pts',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

void _showRedeemDialog(
  BuildContext context,
  RewardRedemptionItem redemption,
  RewardSummary reward,
  Color accent,
) {
  final l10n = AppLocalizations.of(context)!;
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: NeverestPalette.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.rewardRedeemedLabel.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: NeverestPalette.orange,
                      letterSpacing: 1.4,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                reward.partnerName.toUpperCase(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                reward.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.74),
                    ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: QrImageView(
                  data: redemption.redemptionCode,
                  version: QrVersions.auto,
                  size: 208,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: accent,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: NeverestPalette.ink,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                redemption.redemptionCode,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 2.2,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.rewardValidUntil,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonClose),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showQrDialog(
  BuildContext context,
  String code,
  RewardSummary reward,
  Color accent,
) {
  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: NeverestPalette.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reward.partnerName.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: QrImageView(
                  data: code,
                  version: QrVersions.auto,
                  size: 208,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: accent,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: NeverestPalette.ink,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                code,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 2.2,
                    ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.commonClose),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _rewardCategory(RewardSummary reward) {
  final partner = reward.partnerName.toLowerCase();
  final title = reward.title.toLowerCase();
  if (partner.contains('cartur') || title.contains('book') || title.contains('carte')) {
    return 'BOOKS';
  }
  if (partner.contains('tiny cup') || partner.contains('origo') || title.contains('coffee') || title.contains('cafea')) {
    return 'CAFÉ';
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
  return 'PARTNER';
}

Color _rewardAccent(RewardSummary reward) {
  return switch (_rewardCategory(reward)) {
    'BOOKS' => const Color(0xFFA85D3C),
    'CAFÉ' => const Color(0xFF3B2A1E),
    'MUSIC' => const Color(0xFF1E2C3B),
    'PRINT' => const Color(0xFF2A3B4A),
    'GOODS' => const Color(0xFF2B4733),
    _ => const Color(0xFF5A2D1E),
  };
}
