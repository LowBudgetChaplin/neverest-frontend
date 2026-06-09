import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../resources/widgets/app_illustrated_state.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_models.dart';
import '../bloc/admin_panel_cubit.dart';

class AdminCenterScreen extends StatelessWidget {
  const AdminCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canOpenAdminCenter = context.select<AccessCubit, bool>(
      (cubit) => cubit.state.canOpenAdminCenter,
    );
    if (!canOpenAdminCenter) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin center')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: AppIllustratedState(
              icon: Icons.lock_outline,
              title: 'Admin access required',
              subtitle:
                  'Your account does not have organizer permissions for this section.',
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => AdminPanelCubit(
        repository: context.read<AdminRepository>(),
      )..loadInitial(),
      child: const _AdminCenterView(),
    );
  }
}

class _AdminCenterView extends StatefulWidget {
  const _AdminCenterView();

  @override
  State<_AdminCenterView> createState() => _AdminCenterViewState();
}

class _AdminCenterViewState extends State<_AdminCenterView> {
  final _eventTitleController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventLocationController = TextEditingController();
  final _eventPointsController = TextEditingController();
  final _eventCapacityController = TextEditingController();
  final _eventRouteMapUrlController = TextEditingController();
  final _eventStravaClubUrlController = TextEditingController();
  final _eventWhatsappGroupUrlController = TextEditingController();
  final _eventRetryIdController = TextEditingController();

  final _challengeTitleController = TextEditingController();
  final _challengeDescriptionController = TextEditingController();
  final _challengePointsController = TextEditingController(text: '120');
  final _challengeTargetValueController = TextEditingController();
  final _challengeTargetUnitController = TextEditingController();

  final _rewardTitleController = TextEditingController();
  final _rewardPartnerController = TextEditingController();
  final _rewardDescriptionController = TextEditingController();
  final _rewardPointsController = TextEditingController(text: '150');
  final _rewardStockController = TextEditingController();

  final _userDisplayNameController = TextEditingController();
  final _auditActionController = TextEditingController();
  final _auditActorController = TextEditingController();

  String _eventActivity = 'RUNNING';
  String _eventRecurrence = 'NONE';
  DateTime _eventStartsAt = DateTime.now().add(const Duration(days: 1));

  static const _eventRecurrences = [
    'NONE',
    'WEEKLY',
    'BIWEEKLY',
    'MONTHLY',
    'QUARTERLY',
    'YEARLY',
  ];

  String _challengeActivity = 'RUNNING';
  String _challengeMode = 'ONLINE';
  String _challengeFrequency = 'WEEKLY';
  DateTime _challengeStartsAt = DateTime.now().add(const Duration(days: 1));
  DateTime _challengeEndsAt = DateTime.now().add(const Duration(days: 8));

  bool? _auditSuccess;

  static const _activityTypes = ['PADEL', 'MOUNTAIN', 'RUNNING'];
  static const _challengeModes = ['ONLINE', 'OFFLINE'];
  static const _challengeFrequencies = ['WEEKLY', 'MONTHLY'];

  @override
  void dispose() {
    _eventTitleController.dispose();
    _eventDescriptionController.dispose();
    _eventLocationController.dispose();
    _eventPointsController.dispose();
    _eventCapacityController.dispose();
    _eventRouteMapUrlController.dispose();
    _eventStravaClubUrlController.dispose();
    _eventWhatsappGroupUrlController.dispose();
    _eventRetryIdController.dispose();
    _challengeTitleController.dispose();
    _challengeDescriptionController.dispose();
    _challengePointsController.dispose();
    _challengeTargetValueController.dispose();
    _challengeTargetUnitController.dispose();
    _rewardTitleController.dispose();
    _rewardPartnerController.dispose();
    _rewardDescriptionController.dispose();
    _rewardPointsController.dispose();
    _rewardStockController.dispose();
    _userDisplayNameController.dispose();
    _auditActionController.dispose();
    _auditActorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin center')),
      body: BlocConsumer<AdminPanelCubit, AdminPanelState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.successMessage != current.successMessage,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            context.read<AdminPanelCubit>().clearMessages();
            return;
          }

          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            context
                .read<DashboardBloc>()
                .add(const DashboardRefreshRequested());
            context.read<AdminPanelCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          final isBusy = state.isBusy;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (isBusy) const LinearProgressIndicator(minHeight: 2),
              if (isBusy) const SizedBox(height: 10),
              _AuthMeCard(authMe: state.authMe),
              const SizedBox(height: 12),
              _buildEventSection(context, state, isBusy),
              const SizedBox(height: 12),
              _buildChallengeSection(context, isBusy),
              const SizedBox(height: 12),
              _buildRewardSection(context, isBusy),
              const SizedBox(height: 12),
              _buildUsersSection(context, state, isBusy),
              const SizedBox(height: 12),
              _buildAuditSection(context, state, isBusy),
              const SizedBox(height: 12),
              _buildActivityLeaderboardSection(context, state, isBusy),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventSection(
    BuildContext context,
    AdminPanelState state,
    bool isBusy,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create event',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _eventTitleController,
              enabled: !isBusy,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _eventDescriptionController,
              enabled: !isBusy,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _eventActivity,
                    items: _activityTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: isBusy
                        ? null
                        : (value) => setState(
                              () => _eventActivity = value ?? _eventActivity,
                            ),
                    decoration:
                        const InputDecoration(labelText: 'Activity type'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _eventRecurrence,
                    items: _eventRecurrences
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r),
                            ))
                        .toList(),
                    onChanged: isBusy
                        ? null
                        : (value) => setState(
                              () => _eventRecurrence = value ?? _eventRecurrence,
                            ),
                    decoration: const InputDecoration(labelText: 'Recurrence'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _eventLocationController,
                    enabled: !isBusy,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _eventPointsController,
                    enabled: !isBusy,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Points reward',
                      hintText: 'ex: 100',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _eventCapacityController,
              enabled: !isBusy,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Max participants (optional)',
                hintText: 'leave empty for unlimited',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _eventRouteMapUrlController,
              enabled: !isBusy,
              decoration: const InputDecoration(
                labelText: 'Google Maps',
                hintText: '<iframe src="...">',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _eventStravaClubUrlController,
              enabled: !isBusy,
              decoration: const InputDecoration(
                labelText: 'Strava Club URL (optional)',
                hintText: 'https://www.strava.com/...',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _eventWhatsappGroupUrlController,
              enabled: !isBusy,
              decoration: const InputDecoration(
                labelText: 'WhatsApp Group URL (optional)',
                hintText: 'https://chat.whatsapp.com/...',
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: isBusy
                  ? null
                  : () async {
                      final picked =
                          await _pickDateTime(context, _eventStartsAt);
                      if (picked != null) {
                        setState(() => _eventStartsAt = picked);
                      }
                    },
              icon: const Icon(Icons.schedule_outlined),
              label: Text(
                'Starts at: ${_displayDate(_eventStartsAt)}',
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: isBusy ? null : _createEvent,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create event'),
            ),
            if (state.lastCreatedEvent != null) ...[
              const SizedBox(height: 10),
              Text(
                'Last event: ${state.lastCreatedEvent!.event.title}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              ...state.lastCreatedEvent!.announcements.map(
                (dispatch) => Text(
                  '- ${dispatch.channel}: ${dispatch.success ? "OK" : "FAILED"}'
                  '${dispatch.statusCode == null ? "" : " (${dispatch.statusCode})"}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            const Divider(height: 28),
            Text('Retry announcements',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _eventRetryIdController,
              enabled: !isBusy,
              decoration: const InputDecoration(labelText: 'Event ID'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: isBusy ? null : _retryAnnouncements,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry announcements'),
            ),
            if (state.lastAnnouncementRetry.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...state.lastAnnouncementRetry.map(
                (dispatch) => Text(
                  '- ${dispatch.channel}: ${dispatch.success ? "OK" : "FAILED"} '
                  '${dispatch.detail}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeSection(BuildContext context, bool isBusy) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create challenge',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _challengeTitleController,
              enabled: !isBusy,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _challengeDescriptionController,
              enabled: !isBusy,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _challengeActivity,
                    items: _activityTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: isBusy
                        ? null
                        : (value) => setState(
                              () => _challengeActivity =
                                  value ?? _challengeActivity,
                            ),
                    decoration: const InputDecoration(labelText: 'Activity'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _challengeMode,
                    items: _challengeModes
                        .map((mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(mode),
                            ))
                        .toList(),
                    onChanged: isBusy
                        ? null
                        : (value) => setState(
                            () => _challengeMode = value ?? _challengeMode),
                    decoration: const InputDecoration(labelText: 'Mode'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _challengeFrequency,
                    items: _challengeFrequencies
                        .map((frequency) => DropdownMenuItem(
                              value: frequency,
                              child: Text(frequency),
                            ))
                        .toList(),
                    onChanged: isBusy
                        ? null
                        : (value) => setState(
                              () => _challengeFrequency =
                                  value ?? _challengeFrequency,
                            ),
                    decoration: const InputDecoration(labelText: 'Frequency'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _challengePointsController,
                    enabled: !isBusy,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Points reward'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isBusy
                        ? null
                        : () async {
                            final picked = await _pickDateTime(
                                context, _challengeStartsAt);
                            if (picked != null) {
                              setState(() => _challengeStartsAt = picked);
                            }
                          },
                    child: Text('Start: ${_displayDate(_challengeStartsAt)}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isBusy
                        ? null
                        : () async {
                            final picked =
                                await _pickDateTime(context, _challengeEndsAt);
                            if (picked != null) {
                              setState(() => _challengeEndsAt = picked);
                            }
                          },
                    child: Text('End: ${_displayDate(_challengeEndsAt)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _challengeTargetValueController,
                    enabled: !isBusy,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                        labelText: 'Target value (optional)'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _challengeTargetUnitController,
                    enabled: !isBusy,
                    decoration: const InputDecoration(
                      labelText: 'Target unit (optional)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: isBusy ? null : _createChallenge,
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Create challenge'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardSection(BuildContext context, bool isBusy) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create reward',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _rewardTitleController,
              enabled: !isBusy,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _rewardPartnerController,
              enabled: !isBusy,
              decoration: const InputDecoration(labelText: 'Partner name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _rewardDescriptionController,
              enabled: !isBusy,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rewardPointsController,
                    enabled: !isBusy,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Points cost'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _rewardStockController,
                    enabled: !isBusy,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock (optional)',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: isBusy ? null : _createReward,
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Create reward'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersSection(
    BuildContext context,
    AdminPanelState state,
    bool isBusy,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Users',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh users',
                  onPressed: isBusy
                      ? null
                      : () => context.read<AdminPanelCubit>().refreshUsers(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userDisplayNameController,
                    enabled: !isBusy,
                    decoration: const InputDecoration(
                      labelText: 'Create user display name',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: isBusy ? null : _createUser,
                  child: const Text('Create'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (state.users.isEmpty)
              const AppIllustratedState(
                icon: Icons.group_outlined,
                title: 'No users found',
                subtitle: 'Create a user or refresh from backend.',
              )
            else
              ...state.users.take(8).map(
                    (user) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(user.displayName),
                      subtitle: Text('Available: ${user.availablePoints}p'),
                      trailing: Text(user.id.substring(0, 6)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditSection(
    BuildContext context,
    AdminPanelState state,
    bool isBusy,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Audit logs', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _auditActionController,
                    enabled: !isBusy,
                    decoration:
                        const InputDecoration(labelText: 'Action filter'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _auditActorController,
                    enabled: !isBusy,
                    decoration:
                        const InputDecoration(labelText: 'Actor filter'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<bool?>(
              value: _auditSuccess,
              decoration: const InputDecoration(labelText: 'Success filter'),
              items: const [
                DropdownMenuItem<bool?>(
                  value: null,
                  child: Text('All'),
                ),
                DropdownMenuItem<bool?>(
                  value: true,
                  child: Text('Success only'),
                ),
                DropdownMenuItem<bool?>(
                  value: false,
                  child: Text('Failed only'),
                ),
              ],
              onChanged: isBusy
                  ? null
                  : (value) => setState(() => _auditSuccess = value),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : _refreshAuditLogs,
                    icon: const Icon(Icons.search),
                    label: const Text('Search logs'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isBusy ? null : _exportAuditLogs,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Export logs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.auditLogs.isEmpty)
              const AppIllustratedState(
                icon: Icons.history_toggle_off,
                title: 'No audit logs',
                subtitle: 'No entries match current filters.',
              )
            else
              ...state.auditLogs.take(12).map(
                    (log) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        log.success
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color: log.success
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                      title: Text(log.action),
                      subtitle: Text('${log.actor} • ${log.message}'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLeaderboardSection(
    BuildContext context,
    AdminPanelState state,
    bool isBusy,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity leaderboard',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: state.selectedActivityType,
                    items: _activityTypes
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: isBusy
                        ? null
                        : (value) {
                            if (value != null) {
                              context
                                  .read<AdminPanelCubit>()
                                  .refreshActivityLeaderboard(value);
                            }
                          },
                    decoration: const InputDecoration(labelText: 'Activity'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: isBusy
                      ? null
                      : () => context
                          .read<AdminPanelCubit>()
                          .refreshActivityLeaderboard(
                              state.selectedActivityType),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (state.activityLeaderboard.isEmpty)
              const AppIllustratedState(
                icon: Icons.emoji_events_outlined,
                title: 'No leaderboard entries',
                subtitle: 'No points recorded for this activity yet.',
              )
            else
              ...state.activityLeaderboard.asMap().entries.map(
                    (entry) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        child: Text('${entry.key + 1}'),
                      ),
                      title: Text(entry.value.displayName),
                      trailing: Text('${entry.value.points}p'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _createEvent() async {
    final title = _eventTitleController.text.trim();
    final location = _eventLocationController.text.trim();
    final points = int.tryParse(_eventPointsController.text.trim());
    if (title.isEmpty || location.isEmpty || points == null) {
      _showValidation('Event title, location and points are required.');
      return;
    }

    final capacityText = _eventCapacityController.text.trim();
    final capacity = capacityText.isEmpty ? null : int.tryParse(capacityText);
    if (capacityText.isNotEmpty && (capacity == null || capacity <= 0)) {
      _showValidation('Max participants must be a positive number.');
      return;
    }

    await context.read<AdminPanelCubit>().createEvent(
          title: title,
          activityType: _eventActivity,
          location: location,
          startsAtIso: _toLocalDateTimeIso(_eventStartsAt),
          pointsReward: points,
          capacity: capacity,
          description: _eventDescriptionController.text.trim().isEmpty
              ? null
              : _eventDescriptionController.text.trim(),
          recurrence: _eventRecurrence,
          routeMapUrl: _eventRouteMapUrlController.text.trim().isEmpty
              ? null
              : _eventRouteMapUrlController.text.trim(),
          stravaClubUrl: _eventStravaClubUrlController.text.trim().isEmpty
              ? null
              : _eventStravaClubUrlController.text.trim(),
          whatsappGroupUrl: _eventWhatsappGroupUrlController.text.trim().isEmpty
              ? null
              : _eventWhatsappGroupUrlController.text.trim(),
        );
  }

  Future<void> _retryAnnouncements() async {
    final eventId = _eventRetryIdController.text.trim();
    if (eventId.isEmpty) {
      _showValidation('Event ID is required for retry.');
      return;
    }

    await context.read<AdminPanelCubit>().retryAnnouncements(eventId);
  }

  Future<void> _createChallenge() async {
    final title = _challengeTitleController.text.trim();
    final description = _challengeDescriptionController.text.trim();
    final points = int.tryParse(_challengePointsController.text.trim());
    final targetValueRaw =
        _challengeTargetValueController.text.trim().replaceAll(',', '.');
    final targetValue =
        targetValueRaw.isEmpty ? null : double.tryParse(targetValueRaw);

    if (title.isEmpty || description.isEmpty || points == null) {
      _showValidation('Challenge title, description and points are required.');
      return;
    }

    if (targetValueRaw.isNotEmpty && targetValue == null) {
      _showValidation('Target value must be numeric.');
      return;
    }

    await context.read<AdminPanelCubit>().createChallenge(
          title: title,
          description: description,
          activityType: _challengeActivity,
          mode: _challengeMode,
          frequency: _challengeFrequency,
          startsAtIso: _toLocalDateTimeIso(_challengeStartsAt),
          endsAtIso: _toLocalDateTimeIso(_challengeEndsAt),
          pointsReward: points,
          targetValue: targetValue,
          targetUnit: _challengeTargetUnitController.text,
        );
  }

  Future<void> _createReward() async {
    final title = _rewardTitleController.text.trim();
    final partner = _rewardPartnerController.text.trim();
    final description = _rewardDescriptionController.text.trim();
    final points = int.tryParse(_rewardPointsController.text.trim());
    final stockText = _rewardStockController.text.trim();
    final stock = stockText.isEmpty ? null : int.tryParse(stockText);

    if (title.isEmpty ||
        partner.isEmpty ||
        description.isEmpty ||
        points == null) {
      _showValidation(
          'Reward title, partner, description and points are required.');
      return;
    }
    if (stockText.isNotEmpty && stock == null) {
      _showValidation('Stock must be numeric.');
      return;
    }

    await context.read<AdminPanelCubit>().createReward(
          title: title,
          partnerName: partner,
          description: description,
          pointsCost: points,
          stock: stock,
        );
  }

  Future<void> _createUser() async {
    final displayName = _userDisplayNameController.text.trim();
    if (displayName.isEmpty) {
      _showValidation('Display name is required.');
      return;
    }
    await context.read<AdminPanelCubit>().createUser(displayName);
  }

  Future<void> _refreshAuditLogs() async {
    await context.read<AdminPanelCubit>().refreshAuditLogs(
          limit: 50,
          action: _auditActionController.text,
          actor: _auditActorController.text,
          success: _auditSuccess,
        );
  }

  Future<void> _exportAuditLogs() async {
    await context.read<AdminPanelCubit>().exportAuditLogs(
          action: _auditActionController.text,
          actor: _auditActorController.text,
          success: _auditSuccess,
        );
  }

  Future<DateTime?> _pickDateTime(
      BuildContext context, DateTime initial) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (pickedDate == null || !context.mounted) {
      return null;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (pickedTime == null) {
      return null;
    }

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  String _displayDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy HH:mm').format(dateTime);
  }

  String _toLocalDateTimeIso(DateTime dateTime) {
    return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(dateTime);
  }

  void _showValidation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _AuthMeCard extends StatelessWidget {
  const _AuthMeCard({required this.authMe});

  final AuthMeInfo? authMe;

  @override
  Widget build(BuildContext context) {
    if (authMe == null) {
      return const AppIllustratedState(
        icon: Icons.verified_user_outlined,
        title: 'Auth profile unavailable',
        subtitle: 'Could not load /api/v1/auth/me yet.',
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Auth /me', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Subject: ${authMe!.subject}'),
            // Text('Authenticated: ${authMe!.authenticated}'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: authMe!.authorities
                  .map(
                    (authority) => Chip(label: Text(authority)),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
