import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../shell/presentation/design/neverest_design.dart';

/// A simple notifications inbox. Items are derived from the latest dashboard
/// data (new challenges, partner offers, upcoming events). The push toggle is
/// stored locally so the user controls whether push notifications are enabled.
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
    final data = context.watch<DashboardBloc>().state.data;
    final items = _buildItems(data);

    return Scaffold(
      appBar: AppBar(title: const Text('Notificări')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PushToggleCard(enabled: _pushEnabled, onChanged: _setPush),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Nicio notificare nouă.')),
            )
          else
            ...items.map((n) => _NotificationTile(item: n)),
        ],
      ),
    );
  }

  List<_NotifItem> _buildItems(DashboardData? data) {
    if (data == null) return const [];
    final items = <_NotifItem>[];

    for (final o in data.offers) {
      items.add(_NotifItem(
        icon: Icons.local_offer_rounded,
        color: NeverestPalette.orange,
        title: 'Ofertă nouă: ${o.brand}',
        subtitle: o.discountLabel != null && o.discountLabel!.isNotEmpty
            ? '${o.title} · ${o.discountLabel}'
            : o.title,
      ));
    }
    for (final c in data.challenges) {
      items.add(_NotifItem(
        icon: Icons.flag_rounded,
        color: neverestActivityColor(c.activityType),
        title: 'Provocare: ${c.title}',
        subtitle: '+${c.pointsReward} puncte',
      ));
    }
    for (final e in data.events) {
      items.add(_NotifItem(
        icon: Icons.event_rounded,
        color: neverestActivityColor(e.activityType),
        title: 'Eveniment: ${e.title}',
        subtitle: e.location,
      ));
    }
    return items;
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

  final _NotifItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
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
                Text(item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifItem {
  const _NotifItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}
