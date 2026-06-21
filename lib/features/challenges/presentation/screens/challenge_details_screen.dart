import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../shell/presentation/design/neverest_design.dart';
import '../../../strava/domain/strava_models.dart';
import '../../../strava/presentation/cubit/strava_cubit.dart';
import '../../data/challenge_action_repository.dart';
import '../../domain/challenge_submission_item.dart';
import '../bloc/challenge_action_bloc.dart';

class ChallengeDetailsScreen extends StatelessWidget {
  const ChallengeDetailsScreen({
    super.key,
    required this.challenge,
  });

  final ChallengeSummary challenge;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChallengeActionBloc(
        repository: context.read<ChallengeActionRepository>(),
      ),
      child: _ChallengeDetailsView(challenge: challenge),
    );
  }
}

class _ChallengeDetailsView extends StatefulWidget {
  const _ChallengeDetailsView({required this.challenge});

  final ChallengeSummary challenge;

  @override
  State<_ChallengeDetailsView> createState() => _ChallengeDetailsViewState();
}

class _ChallengeDetailsViewState extends State<_ChallengeDetailsView> {
  final TextEditingController _proofController = TextEditingController();
  final TextEditingController _metricController = TextEditingController();
  bool _adminView = false;
  int? _selectedStravaActivityId;

  @override
  void initState() {
    super.initState();
    // Strava e partajat, altfel activitățile vechi rămân afișate (și validabile)
    context.read<StravaCubit>().clearVerification();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubmissions();
      context.read<StravaCubit>().loadStatus();
    });
  }

  @override
  void dispose() {
    _proofController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canUseAdminFeatures = context.select<AccessCubit, bool>(
      (cubit) => cubit.state.canOpenAdminCenter,
    );
    final effectiveAdminView = _adminView && canUseAdminFeatures;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<ChallengeActionBloc, ChallengeActionState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            context
                .read<ChallengeActionBloc>()
                .add(const ChallengeMessagesCleared());
            return;
          }
          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            context
                .read<ChallengeActionBloc>()
                .add(const ChallengeMessagesCleared());
          }
        },
        builder: (context, state) {
          final isBusy = state.isSubmitting || state.isReviewing;
          return ListView(
            padding: EdgeInsets.only(
              left: 0,
              right: 0,
              top: MediaQuery.paddingOf(context).top + 8,
              bottom: 30,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  children: [
                    NeverestGlassIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.challenge.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          Text(
                            '${widget.challenge.activityType} · +${widget.challenge.pointsReward} pct',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: NeverestPalette.orange,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _StravaActivitySection(
                challenge: widget.challenge,
                selectedActivityId: _selectedStravaActivityId,
                onActivitySelected: _onStravaActivitySelected,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _SubmissionComposer(
                  isBusy: isBusy,
                  isLoading: state.isLoading,
                  proofController: _proofController,
                  metricController: _metricController,
                  onSubmit: _submitChallenge,
                  onRefresh: _loadSubmissions,
                  showProgress: state.isSubmitting,
                  metricReadOnly: true,
                ),
              ),
              const SizedBox(height: 10),
              if (canUseAdminFeatures)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SwitchListTile.adaptive(
                    value: _adminView,
                    onChanged: state.isLoading
                        ? null
                        : (value) {
                            setState(() => _adminView = value);
                            _loadSubmissions();
                          },
                    title: Text(l10n.challengeAdminReviewMode),
                    subtitle: Text(l10n.challengeAdminReviewSubtitle),
                  ),
                ),
              const SizedBox(height: 4),
              if (state.isLoading && state.submissions.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (state.submissions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    effectiveAdminView
                        ? l10n.challengeNoSubmissions
                        : l10n.challengeNoPersonalSubmissions,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                ...state.submissions.map(
                  (submission) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: _SubmissionCard(
                      submission: submission,
                      adminView: effectiveAdminView,
                      isReviewing: state.isReviewing,
                      onApprove: () => _reviewSubmission(submission, approved: true),
                      onReject: () => _reviewSubmission(submission, approved: false),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _onStravaActivitySelected(StravaActivity activity) {
    final metric = _metricForActivity(activity);
    setState(() {
      _selectedStravaActivityId = activity.stravaId;
      _proofController.text = activity.name;
      _metricController.text = metric;
    });
  }

  String _metricForActivity(StravaActivity activity) {
    final unit = (widget.challenge.targetUnit ?? '').toLowerCase();
    final isElevation = unit.contains('elev') ||
        unit.contains('d+') ||
        (widget.challenge.activityType.toUpperCase() == 'MOUNTAIN' &&
            (unit == 'm' || unit.contains('metri')));
    if (isElevation) {
      return activity.totalElevationGain.toStringAsFixed(0);
    }
    if (unit.contains('km')) {
      return activity.distanceKm.toStringAsFixed(2);
    }
    if (unit.contains('m')) {
      return activity.distanceMeters.toStringAsFixed(0);
    }
    return activity.distanceKm.toStringAsFixed(2);
  }

  void _loadSubmissions() {
    context.read<ChallengeActionBloc>().add(
          ChallengeSubmissionsLoadRequested(
            challengeId: widget.challenge.id,
            adminView: _isAdminModeEnabled(),
            userId: _profileUserId(),
          ),
        );
  }

  void _submitChallenge() {
    final l10n = AppLocalizations.of(context)!;
    final proof = _proofController.text.trim();
    if (proof.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.challengeProofRequired)),
      );
      return;
    }

    final metricRaw = _metricController.text.trim().replaceAll(',', '.');
    final metricValue = metricRaw.isEmpty ? null : double.tryParse(metricRaw);
    if (metricRaw.isNotEmpty && metricValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.challengeMetricMustBeNumeric)),
      );
      return;
    }

    context.read<ChallengeActionBloc>().add(
          ChallengeSubmissionSubmitRequested(
            challengeId: widget.challenge.id,
            proofText: proof,
            metricValue: metricValue,
            userId: _profileUserId(),
          ),
        );
  }

  Future<void> _reviewSubmission(
    ChallengeSubmissionItem submission, {
    required bool approved,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_isAdminModeEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.challengeAdminRequired)),
      );
      return;
    }

    final noteController = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            approved
                ? l10n.challengeApproveSubmission
                : l10n.challengeRejectSubmission,
          ),
          content: TextField(
            controller: noteController,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.challengeReviewerNoteOptional,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(noteController.text),
              child: Text(l10n.commonConfirm),
            ),
          ],
        );
      },
    );
    noteController.dispose();

    if (!mounted || note == null) {
      return;
    }

    context.read<ChallengeActionBloc>().add(
          ChallengeSubmissionReviewRequested(
            challengeId: widget.challenge.id,
            submissionId: submission.id,
            approved: approved,
            reviewerNote: note,
            userId: _profileUserId(),
          ),
        );
  }

  String? _profileUserId() {
    return context.read<ProfileBloc>().state.profile?.id;
  }

  bool _isAdminModeEnabled() {
    final hasAdminAccess = context.read<AccessCubit>().state.canOpenAdminCenter;
    return _adminView && hasAdminAccess;
  }

}

class _SubmissionComposer extends StatelessWidget {
  const _SubmissionComposer({
    required this.isBusy,
    required this.isLoading,
    required this.proofController,
    required this.metricController,
    required this.onSubmit,
    required this.onRefresh,
    required this.showProgress,
    this.metricReadOnly = false,
  });

  final bool isBusy;
  final bool isLoading;
  final TextEditingController proofController;
  final TextEditingController metricController;
  final VoidCallback onSubmit;
  final VoidCallback onRefresh;
  final bool showProgress;
  final bool metricReadOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.challengeSubmitProgress,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: proofController,
            enabled: !isBusy,
            minLines: 1,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.challengeActivityNameLabel),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: metricController,
            enabled: !isBusy,
            readOnly: metricReadOnly,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.challengeMetricLabel,
              suffixIcon: metricReadOnly
                  ? const Icon(Icons.lock_outline_rounded, size: 16)
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton(
                onPressed: isBusy ? null : onSubmit,
                child: Text(l10n.challengeSubmit),
              ),
              OutlinedButton(
                onPressed: isLoading ? null : onRefresh,
                child: Text(l10n.commonRefresh),
              ),
            ],
          ),
          if (showProgress) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(minHeight: 2),
          ],
        ],
      ),
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  const _SubmissionCard({
    required this.submission,
    required this.adminView,
    required this.isReviewing,
    required this.onApprove,
    required this.onReject,
  });

  final ChallengeSubmissionItem submission;
  final bool adminView;
  final bool isReviewing;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPending = submission.status.toUpperCase() == 'PENDING';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Expanded(
              //   child: Text(
              //     l10n.challengeSubmissionId(submission.id),
              //     style: Theme.of(context).textTheme.titleSmall?.copyWith(
              //           fontWeight: FontWeight.w800,
              //         ),
              //   ),
              // ),
              NeverestFilterChip(
                label: submission.status,
                selected: isPending,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${l10n.challengeProofField}: ${submission.proofText}'),
          if (submission.metricValue != null)
            Text('${l10n.challengeMetricField}: ${submission.metricValue}'),
          Text('${l10n.challengeAwardedPoints}: ${submission.awardedPoints}'),
          if (submission.reviewerNote != null &&
              submission.reviewerNote!.isNotEmpty)
            Text('${l10n.challengeReviewerNote}: ${submission.reviewerNote}'),
          if (adminView && isPending) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: isReviewing ? null : onApprove,
                  child: Text(l10n.challengeApprove),
                ),
                OutlinedButton(
                  onPressed: isReviewing ? null : onReject,
                  child: Text(l10n.challengeReject),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StravaActivitySection extends StatelessWidget {
  const _StravaActivitySection({
    required this.challenge,
    required this.selectedActivityId,
    required this.onActivitySelected,
  });
  final ChallengeSummary challenge;
  final int? selectedActivityId;
  final ValueChanged<StravaActivity> onActivitySelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stravaState = context.watch<StravaCubit>().state;
    final status = stravaState.status;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_run_rounded, size: 16, color: NeverestPalette.orange),
                const SizedBox(width: 6),
                Text(
                  'VERIFICARE STRAVA',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: NeverestPalette.orange,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (status == null || !status.connected) ...[
              Text(
                'Conectează-ți contul Strava pentru a verifica automat dacă ai completat traseul.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ] else if (stravaState.isVerifying) ...[
              const Row(
                children: [
                  SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Se verifică activitățile Strava...'),
                ],
              ),
            ] else if (stravaState.verification != null) ...[
              _VerificationResult(
                verification: stravaState.verification!,
                isDark: isDark,
                onClear: () => context.read<StravaCubit>().clearVerification(),
                selectedActivityId: selectedActivityId,
                onActivitySelected: onActivitySelected,
              ),
            ] else ...[
              Text(
                'Strava conectat ca ${status.athleteName ?? "Atlet"}. Apasă pentru a verifica dacă ai completat traseul.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => context.read<StravaCubit>().verifyChallenge(challenge.id),
                  icon: const Icon(Icons.verified_rounded, size: 16),
                  label: const Text('Verifică cu Strava'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerificationResult extends StatelessWidget {
  const _VerificationResult({
    required this.verification,
    required this.isDark,
    required this.onClear,
    required this.selectedActivityId,
    required this.onActivitySelected,
  });

  final StravaChallengeVerification verification;
  final bool isDark;
  final VoidCallback onClear;
  final int? selectedActivityId;
  final ValueChanged<StravaActivity> onActivitySelected;

  @override
  Widget build(BuildContext context) {
    final color = verification.verified ? NeverestPalette.success : NeverestPalette.danger;
    final icon = verification.verified ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                verification.verificationMessage,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close_rounded, size: 16,
                  color: Theme.of(context).textTheme.bodySmall?.color),
            ),
          ],
        ),
        if (verification.matchingActivities.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Alege activitatea care confirmă provocarea:',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 6),
          ...verification.matchingActivities.take(3).map(
            (a) => _StravaActivityCard(
              activity: a,
              isDark: isDark,
              selected: selectedActivityId == a.stravaId,
              onTap: () => onActivitySelected(a),
            ),
          ),
        ],
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: const Text('Verifică din nou'),
          ),
        ),
      ],
    );
  }
}

class _StravaActivityCard extends StatelessWidget {
  const _StravaActivityCard({
    required this.activity,
    required this.isDark,
    this.selected = false,
    this.onTap,
  });
  final StravaActivity activity;
  final bool isDark;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected
            ? NeverestPalette.orange.withOpacity(isDark ? 0.16 : 0.10)
            : (isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? NeverestPalette.orange
              : (isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  activity.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NeverestPalette.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  activity.type,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: NeverestPalette.orange,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatChip(
                    label: 'KM', value: activity.distanceKm.toStringAsFixed(2)),
              ),
              Expanded(
                child: _StatChip(
                    label: 'DURATĂ', value: activity.formattedDuration),
              ),
              Expanded(
                child: _StatChip(label: 'RITM', value: activity.formattedPace),
              ),
              Expanded(
                child: _StatChip(
                    label: 'ELEVAȚIE',
                    value: '${activity.totalElevationGain.toStringAsFixed(0)}m'),
              ),
            ],
          ),
          if (activity.startLatLng != null || activity.endLatLng != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: NeverestPalette.orange),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _formatLatLng(activity.startLatLng, activity.endLatLng),
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (activity.startDateLocal.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _formatDate(activity.startDateLocal),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  String _formatLatLng(List<double>? start, List<double>? end) {
    final parts = <String>[];
    if (start != null) {
      parts.add('Start: ${start[0].toStringAsFixed(4)}, ${start[1].toStringAsFixed(4)}');
    }
    if (end != null) {
      parts.add('Final: ${end[0].toStringAsFixed(4)}, ${end[1].toStringAsFixed(4)}');
    }
    return parts.join(' → ');
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 0.8),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

