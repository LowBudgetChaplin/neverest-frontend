import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shell/presentation/design/neverest_design.dart';
import '../../domain/notification_models.dart';
import '../cubit/notification_cubit.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _prefsKey = 'neverest_push_enabled';
  bool _pushEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPref();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final cubit = context.read<NotificationCubit>();
      await cubit.loadAll();
      await cubit.markAllRead();
    });
  }

  Future<void> _loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _pushEnabled = prefs.getBool(_prefsKey) ?? true);
  }

  Future<void> _setPush(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
    if (!mounted) return;
    setState(() => _pushEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotificationCubit>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Notificări')),
      body: RefreshIndicator(
        onRefresh: () => context.read<NotificationCubit>().loadAll(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PushToggleCard(enabled: _pushEnabled, onChanged: _setPush),
            const SizedBox(height: 16),
            if (state.isLoading && state.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Nicio notificare nouă.')),
              )
            else
              ...state.items.map((n) => _NotificationTile(item: n)),
          ],
        ),
      ),
    );
  }
}

class _PushToggleCard extends StatelessWidget {
  const _PushToggleCard({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notificări push',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text('Primește alerte pentru provocări și oferte noi.',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final AppNotification item;

  ({IconData icon, Color color}) _visualFor(String type) {
    switch (type) {
      case 'SUBMISSION_APPROVED':
        return (icon: Icons.check_circle_rounded, color: NeverestPalette.success);
      case 'SUBMISSION_REJECTED':
        return (icon: Icons.cancel_rounded, color: NeverestPalette.danger);
      case 'SUBMISSION_PENDING':
        return (icon: Icons.hourglass_top_rounded, color: NeverestPalette.orange);
      default:
        return (icon: Icons.notifications_rounded, color: NeverestPalette.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visual = _visualFor(item.type);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.read
              ? (isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine)
              : NeverestPalette.orange.withOpacity(0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: visual.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(visual.icon, color: visual.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(item.body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (!item.read) ...[
            const SizedBox(width: 8),
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: NeverestPalette.orange,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
