import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../shell/presentation/design/neverest_design.dart';
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
  Timer? _timer;
  int _seconds = 1333;
  int _meters = 3380;
  bool _paused = false;
  bool _adminView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSubmissions());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) {
        return;
      }
      setState(() {
        _seconds += 1;
        _meters += 2;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    final progress = (_meters / 7400).clamp(0.0, 1.0);
    final pace = ((_seconds / 60) / (_meters / 1000)).clamp(4.0, 9.0);
    final paceMin = pace.floor();
    final paceSec = ((pace - paceMin) * 60).round().toString().padLeft(2, '0');
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
              top: MediaQuery.paddingOf(context).top,
              bottom: 30,
            ),
            children: [
              SizedBox(
                height: 306,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NeverestMapMock(progress: progress, dark: dark),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Row(
                        children: [
                          NeverestGlassIconButton(
                            icon: Icons.close_rounded,
                            foreground: dark ? Colors.white : Colors.black,
                            background: dark
                                ? Colors.black.withOpacity(0.55)
                                : Colors.white.withOpacity(0.85),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: dark
                                  ? Colors.black.withOpacity(0.55)
                                  : Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: NeverestPalette.orange,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _paused
                                      ? l10n.challengePaused
                                      : l10n.challengeGpsLive,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: dark ? Colors.white : Colors.black,
                                        letterSpacing: 1.1,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 38),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: dark
                              ? Colors.black.withOpacity(0.62)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.challengeDestination,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    letterSpacing: 1.1,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.challengeDestinationValue,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Text(
                              l10n.challengeRemainingKm(
                                ((7400 - _meters) / 1000)
                                    .clamp(0, 20)
                                    .toStringAsFixed(2),
                              ),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: NeverestPalette.orange,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: dark
                              ? NeverestPalette.inkLine
                              : NeverestPalette.paperLine,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          l10n.challengeRouteHeadline,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: NeverestPalette.orange,
                                letterSpacing: 1.2,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.challengeOnFinishPoints(
                            widget.challenge.pointsReward,
                          ),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      (_meters / 1000).toStringAsFixed(2),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 76,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 6),
                      child: Text(
                        'KM',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NeverestProgressBar(value: progress),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: Row(
                  children: [
                    Text(
                      l10n.challengeProgressLine(
                        (progress * 100).round(),
                        (_meters / 1000).toStringAsFixed(2),
                        '7.4',
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Text(
                      l10n.challengeOnFinishPoints(widget.challenge.pointsReward),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: NeverestPalette.orange,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _SubStat(
                        label: l10n.challengeTime,
                        value: _formatTime(_seconds),
                      ),
                    ),
                    Expanded(
                      child: _SubStat(
                        label: l10n.challengePace,
                        value: '$paceMin:$paceSec',
                        unit: '/km',
                      ),
                    ),
                    Expanded(
                      child: _SubStat(
                        label: l10n.challengeSteps,
                        value: (_meters * 1.34).round().toString(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _paused = !_paused),
                        icon: Icon(
                          _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        ),
                        label:
                            Text(_paused ? l10n.challengeResume : l10n.challengePause),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: NeverestPalette.danger,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.stop_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
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

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours == 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
  });

  final bool isBusy;
  final bool isLoading;
  final TextEditingController proofController;
  final TextEditingController metricController;
  final VoidCallback onSubmit;
  final VoidCallback onRefresh;
  final bool showProgress;

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
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(labelText: l10n.challengeProofLabel),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: metricController,
            enabled: !isBusy,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.challengeMetricLabel),
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
              Expanded(
                child: Text(
                  l10n.challengeSubmissionId(submission.id),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
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

class _SubStat extends StatelessWidget {
  const _SubStat({
    required this.label,
    required this.value,
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.1,
              ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            text: value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 30),
            children: [
              if (unit != null)
                TextSpan(
                  text: unit,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
