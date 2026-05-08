import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_page_route.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../access/presentation/cubit/access_cubit.dart';
import '../../../dashboard/domain/dashboard_data.dart';
import '../../../profile/presentation/screens/my_qr_screen.dart';
import '../../../shell/presentation/design/neverest_design.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canUseAdminFeatures = context.select<AccessCubit, bool>(
      (cubit) => cubit.state.canOpenAdminCenter,
    );
    final event = widget.event;
    final parsedDate = DateTime.tryParse(event.startsAt);
    final whenLabel = parsedDate == null
        ? event.startsAt
        : '${_weekday(parsedDate)} ${parsedDate.day} ${_month(parsedDate.month)} · ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    final activityColor = neverestActivityColor(event.activityType);
    final aboutText = l10n.eventAboutSample;

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
                                    background: Colors.white.withOpacity(0.14),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  const Spacer(),
                                  NeverestGlassIconButton(
                                    icon: Icons.share_outlined,
                                    foreground: Colors.white,
                                    background: Colors.white.withOpacity(0.14),
                                    onPressed: () {},
                                  ),
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
                                    _tagFor(event).toUpperCase(),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.white,
                                          letterSpacing: 1.3,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                event.title.toUpperCase(),
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        icon: Icons.person_outline_rounded,
                        label: l10n.eventHost,
                        value: 'Cristina M.',
                      ),
                      _MetaTile(
                        icon: Icons.bolt_rounded,
                        label: l10n.eventReward,
                        value: '+${event.pointsReward} pts',
                        accent: true,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
                    aboutText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    children: [
                      Text(
                        l10n.eventAttendeesCount(28),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.eventSpotsLeft(12),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _participants
                        .map(
                          (name) => Container(
                            padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? NeverestPalette.inkRaised
                                  : NeverestPalette.paperRaised,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness == Brightness.dark
                                        ? NeverestPalette.inkLine
                                        : NeverestPalette.paperLine,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                NeverestAvatar(name: name, size: 20),
                                const SizedBox(width: 6),
                                Text(name, style: Theme.of(context).textTheme.labelSmall),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: NeverestPalette.success,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.eventWhatsappSync,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const Icon(
                          Icons.check_circle_rounded,
                          color: NeverestPalette.success,
                          size: 18,
                        ),
                      ],
                    ),
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
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        AppPageRoute.fadeSlide(const MyQrScreen()),
                      );
                    },
                    icon: const Icon(Icons.route_rounded),
                    label: Text(l10n.eventRoute),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (canUseAdminFeatures) {
                        Navigator.of(context).push(
                          AppPageRoute.fadeSlide(
                            EventCheckInScreen(event: event),
                          ),
                        );
                      } else {
                        setState(() => _going = !_going);
                      }
                    },
                    icon: Icon(_going ? Icons.check_rounded : Icons.add_rounded),
                    label: Text(
                      canUseAdminFeatures
                          ? l10n.eventAdminCheckIn
                          : (_going ? l10n.eventGoing : l10n.eventImGoing),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _weekday(DateTime date) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
  }

  String _month(int month) {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][month - 1];
  }

  String _tagFor(EventSummary event) {
    final type = event.activityType.toUpperCase();
    if (type == 'PADEL') {
      return 'Mixed levels · Round-robin';
    }
    if (type == 'MOUNTAIN') {
      return '14 km · 900m gain';
    }
    return 'Group run · 8 km';
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
            : (isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised),
        borderRadius: BorderRadius.circular(14),
        border: accent
            ? null
            : Border.all(
                color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
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

const _participants = [
  'Maria',
  'Tudor',
  'Sara',
  'Bogdan',
  'Ioana',
  'Vlad',
  'Ana',
  'Diana',
];
