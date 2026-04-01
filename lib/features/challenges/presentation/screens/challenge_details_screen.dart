import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../resources/widgets/app_illustrated_state.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSubmissions());
  }

  @override
  void dispose() {
    _proofController.dispose();
    _metricController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canUseAdminFeatures = context.select<AccessCubit, bool>(
      (cubit) => cubit.state.canOpenAdminCenter,
    );
    final effectiveAdminView = _adminView && canUseAdminFeatures;

    return Scaffold(
      appBar: AppBar(title: const Text('Challenge details')),
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
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.challenge.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(widget.challenge.activityType)),
                        Chip(label: Text(widget.challenge.frequency)),
                        Chip(label: Text(widget.challenge.mode)),
                        Chip(label: Text('+${widget.challenge.pointsReward}p')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Submit progress',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _proofController,
                        enabled: !isBusy,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Proof text',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _metricController,
                        enabled: !isBusy,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Metric value (optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilledButton(
                            onPressed: isBusy ? null : _submitChallenge,
                            child: const Text('Submit challenge'),
                          ),
                          OutlinedButton(
                            onPressed:
                                state.isLoading ? null : _loadSubmissions,
                            child: const Text('Refresh submissions'),
                          ),
                        ],
                      ),
                      if (state.isSubmitting) ...[
                        const SizedBox(height: 10),
                        const LinearProgressIndicator(minHeight: 2),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (canUseAdminFeatures)
                SwitchListTile(
                  value: _adminView,
                  onChanged: state.isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _adminView = value;
                          });
                          _loadSubmissions();
                        },
                  title: const Text('Admin review mode'),
                  subtitle:
                      const Text('Enable to list all submissions and review.'),
                )
              else
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.lock_outline),
                    title: Text('Admin review locked'),
                    subtitle: Text(
                      'Submission review is available only for organizer accounts.',
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              if (state.isLoading && state.submissions.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (state.submissions.isEmpty)
                AppIllustratedState(
                  icon: Icons.inbox_outlined,
                  title: effectiveAdminView
                      ? 'No submissions yet'
                      : 'No personal submissions',
                  subtitle: effectiveAdminView
                      ? 'Users have not submitted this challenge yet.'
                      : 'Submit your first challenge progress.',
                )
              else
                ...state.submissions.map(
                  (submission) => _SubmissionCard(
                    submission: submission,
                    adminView: effectiveAdminView,
                    isReviewing: state.isReviewing,
                    onApprove: () =>
                        _reviewSubmission(submission, approved: true),
                    onReject: () =>
                        _reviewSubmission(submission, approved: false),
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
    final proof = _proofController.text.trim();
    if (proof.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proof text is required.')),
      );
      return;
    }

    final metricRaw = _metricController.text.trim().replaceAll(',', '.');
    final metricValue = metricRaw.isEmpty ? null : double.tryParse(metricRaw);
    if (metricRaw.isNotEmpty && metricValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metric value must be numeric.')),
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
    if (!_isAdminModeEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin role is required for submission review.'),
        ),
      );
      return;
    }

    final noteController = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(approved ? 'Approve submission' : 'Reject submission'),
          content: TextField(
            controller: noteController,
            minLines: 2,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reviewer note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(noteController.text),
              child: const Text('Confirm'),
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
    final isPending = submission.status.toUpperCase() == 'PENDING';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Submission ${submission.id}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Chip(label: Text(submission.status)),
              ],
            ),
            const SizedBox(height: 6),
            Text('Proof: ${submission.proofText}'),
            if (submission.metricValue != null)
              Text('Metric value: ${submission.metricValue}'),
            Text('Awarded points: ${submission.awardedPoints}'),
            if (submission.reviewerNote != null &&
                submission.reviewerNote!.isNotEmpty)
              Text('Reviewer note: ${submission.reviewerNote}'),
            if (adminView && isPending) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: isReviewing ? null : onApprove,
                    child: const Text('Approve'),
                  ),
                  OutlinedButton(
                    onPressed: isReviewing ? null : onReject,
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
