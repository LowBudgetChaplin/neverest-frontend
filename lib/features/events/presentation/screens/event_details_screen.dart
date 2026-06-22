import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../profile/domain/app_profile.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../shell/presentation/design/neverest_design.dart';
import '../../data/event_action_repository.dart';
import 'event_check_in_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  final EventSummary event;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _going = false;
  bool _busy = false;
  List<EventParticipant> _participants = const [];
  WebViewController? _mapController;

  String? get _routeUrl {
    final raw = widget.event.routeMapUrl?.trim();
    if (raw == null || raw.isEmpty) return null;
    final m = RegExp('src\\s*=\\s*"([^"]+)"').firstMatch(raw) ??
        RegExp("src\\s*=\\s*'([^']+)'").firstMatch(raw);
    if (m != null) return m.group(1);
    if (raw.startsWith('http')) return raw;
    return null;
  }

  String? get _openableMapUrl {
    final url = _routeUrl;
    if (url == null) return null;
    if (url.contains('/maps/embed')) {
      final lng = RegExp(r'!2d(-?\d+(?:\.\d+)?)').firstMatch(url)?.group(1);
      final lat = RegExp(r'!3d(-?\d+(?:\.\d+)?)').firstMatch(url)?.group(1);
      if (lat != null && lng != null) {
        return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      }
    }
    return url;
  }

  bool get _isEmbeddableMap {
    final url = _routeUrl ?? '';
    return url.contains('/maps/embed') || url.contains('output=embed');
  }

  @override
  void initState() {
    super.initState();
    final mapUrl = _routeUrl;
    if (mapUrl != null && mapUrl.isNotEmpty && _isEmbeddableMap) {
      _mapController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString(_buildMapHtml(mapUrl));
    }
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    try {
      final result = await context
          .read<EventActionRepository>()
          .getParticipants(widget.event.id);
      if (!mounted) return;
      setState(() {
        _going = result.going;
        _participants = result.participants;
      });
    } catch (_) {
      // Keep the screen usable even if participants fail to load.
    }
  }

  Future<void> _toggleGoing() async {
    if (_busy) return;
    setState(() => _busy = true);
    final repo = context.read<EventActionRepository>();
    try {
      final result = _going
          ? await repo.leaveEvent(widget.event.id)
          : await repo.joinEvent(widget.event.id);
      if (!mounted) return;
      setState(() {
        _going = result.going;
        _participants = result.participants;
        _busy = false;
      });
      // Reimprospatam dashboard-ul ca lista de evenimente (locuri ramase /
      // numar participanti) sa reflecte imediat join-ul/leave-ul.
      context.read<DashboardBloc>().add(const DashboardRefreshRequested());
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.commonError)),
      );
    }
  }

  String _buildMapHtml(String src) {
    final safe = src.replaceAll('"', '&quot;');
    return '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<style>
  html,body{margin:0;padding:0;height:100%;overflow:hidden;background:#161618}
  iframe{border:0;width:100%;height:100%}
</style>
</head>
<body>
<iframe src="$safe" allowfullscreen loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
</body>
</html>
''';
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canUseAdminFeatures = context.select<AccessCubit, bool>(
      (cubit) => cubit.state.canOpenAdminCenter,
    );
    final myProfile = context.select<ProfileBloc, AppProfile?>(
      (bloc) => bloc.state.profile,
    );
    final event = widget.event;
    final parsedDate = DateTime.tryParse(event.startsAt);
    final whenLabel = parsedDate == null
        ? event.startsAt
        : '${_weekday(parsedDate)} ${parsedDate.day} ${_month(parsedDate.month)} · ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    final activityColor = neverestActivityColor(event.activityType);
    final routeUrl = _routeUrl;
    final hasRoute = routeUrl != null && routeUrl.isNotEmpty;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  height: 250,
                  color: NeverestPalette.ink,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NeverestTopographicLines(
                        color: activityColor,
                        density: 14,
                        opacity: 0.72,
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  NeverestGlassIconButton(
                                    icon: Icons.arrow_back_rounded,
                                    foreground: Colors.white,
                                    background:
                                        Colors.white.withOpacity(0.14),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                              const Spacer(),
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
                                  const SizedBox(width: 6),
                                  Text(
                                    event.activityType.toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          letterSpacing: 1.3,
                                        ),
                                  ),
                                  if (event.recurrence != null &&
                                      event.recurrence!.isNotEmpty &&
                                      event.recurrence != 'NONE') ...[
                                    Text(
                                      '  ·  ${event.recurrence}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: Colors.white
                                                .withOpacity(0.65),
                                            letterSpacing: 1.1,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                event.title.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 36,
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
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 86,
                    ),
                    children: [
                      _MetaTile(
                        icon: Icons.calendar_month_rounded,
                        label: l10n.eventWhen,
                        value: whenLabel,
                      ),
                      _MetaTile(
                        icon: Icons.location_on_outlined,
                        label: l10n.eventWhere,
                        value: event.location,
                      ),
                      _MetaTile(
                        icon: Icons.bolt_rounded,
                        label: l10n.eventReward,
                        value: '+${event.pointsReward} pts',
                        accent: true,
                      ),
                      _MetaTile(
                        icon: Icons.repeat_rounded,
                        label: l10n.eventRecurrence,
                        value: _recurrenceLabel(event.recurrence),
                      ),
                    ],
                  ),
                ),

                if (hasRoute)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: _mapController != null
                        ? Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SizedBox(
                                  height: 200,
                                  child: WebViewWidget(
                                      controller: _mapController!),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _OpenMapButton(
                                onTap: () => _openUrl(_openableMapUrl),
                              ),
                            ],
                          )
                        : _RouteMapCard(
                            location: event.location,
                            activityColor: activityColor,
                            onTap: () => _openUrl(_openableMapUrl),
                          ),
                  ),

                if (event.description != null &&
                    event.description!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Text(
                      l10n.eventAbout.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(
                      event.description!,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.45),
                    ),
                  ),
                ],

                if (_participants.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Text(
                      '${l10n.eventParticipants.toUpperCase()} · ${_participants.length}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                    ),
                  ),
                  for (final participant in _participants)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Row(
                        children: [
                          NeverestAvatar(
                            name: participant.name,
                            size: 34,
                            imageB64: participant.avatarB64,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              participant.userId == (myProfile?.id ?? '')
                                  ? '${participant.name} (${l10n.eventYouGoing})'
                                  : participant.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (participant.userId == (myProfile?.id ?? '')) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.check_circle_rounded,
                                size: 16, color: NeverestPalette.success),
                          ],
                        ],
                      ),
                    ),
                ],

                if (event.stravaClubUrl != null &&
                    event.stravaClubUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _SocialBar(
                      icon: Icons.directions_run_rounded,
                      color: const Color(0xFFFC4C02),
                      label: l10n.eventStravaClub,
                      onTap: () => _openUrl(event.stravaClubUrl!),
                    ),
                  ),

                if (event.whatsappGroupUrl != null &&
                    event.whatsappGroupUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _SocialBar(
                      icon: Icons.chat_bubble_outline_rounded,
                      color: NeverestPalette.success,
                      label: l10n.eventWhatsappGroup,
                      onTap: () => _openUrl(event.whatsappGroupUrl!),
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),

          Container(
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
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.paddingOf(context).bottom > 0
                  ? MediaQuery.paddingOf(context).bottom + 8
                  : 18,
            ),
            child: FilledButton.icon(
              onPressed: _busy
                  ? null
                  : () {
                      if (canUseAdminFeatures) {
                        Navigator.of(context).push(
                          AppPageRoute.fadeSlide(
                            EventCheckInScreen(event: event),
                          ),
                        );
                      } else {
                        _toggleGoing();
                      }
                    },
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(_going ? Icons.check_rounded : Icons.add_rounded),
              label: Text(
                canUseAdminFeatures
                    ? l10n.eventAdminCheckIn
                    : (_going ? l10n.eventGoing : l10n.eventImGoing),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekday(DateTime date) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];

  String _month(int month) => [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][month - 1];

  String _recurrenceLabel(String? recurrence) => switch (
        recurrence?.toUpperCase()) {
    'WEEKLY' => 'Weekly',
    'BIWEEKLY' => 'Every 2 weeks',
    'MONTHLY' => 'Monthly',
    'QUARTERLY' => 'Every 3 months',
    'YEARLY' => 'Yearly',
    _ => 'One-time',
  };
}

class _SocialBar extends StatelessWidget {
  const _SocialBar({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? NeverestPalette.inkRaised
              : NeverestPalette.paperRaised,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
                child:
                    Text(label, style: Theme.of(context).textTheme.bodySmall)),
            Icon(Icons.open_in_new_rounded,
                size: 16,
                color: isDark
                    ? NeverestPalette.inkMuted
                    : NeverestPalette.paperMuted),
          ],
        ),
      ),
    );
  }
}

class _RouteMapCard extends StatelessWidget {
  const _RouteMapCard({
    required this.location,
    required this.activityColor,
    required this.onTap,
  });

  final String location;
  final Color activityColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        height: 140,
        decoration: BoxDecoration(
          color: NeverestPalette.ink,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: NeverestTopographicLines(
                color: activityColor,
                density: 12,
                opacity: 0.7,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.map_outlined,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: NeverestPalette.orange,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              l10n.eventOpenRoute,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                            ),
                          ],
                        ),
                      ),
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

class _OpenMapButton extends StatelessWidget {
  const _OpenMapButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.directions_rounded, size: 18),
        label: Text(l10n.eventOpenRoute),
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: accent
            ? NeverestPalette.orange
            : (isDark
                ? NeverestPalette.inkRaised
                : NeverestPalette.paperRaised),
        borderRadius: BorderRadius.circular(14),
        border: accent
            ? null
            : Border.all(
                color: isDark
                    ? NeverestPalette.inkLine
                    : NeverestPalette.paperLine,
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: accent
                    ? Colors.white.withOpacity(0.9)
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: accent
                            ? Colors.white.withOpacity(0.82)
                            : Theme.of(context).textTheme.bodySmall?.color,
                        letterSpacing: 1.2,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: accent ? Colors.white : null,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
