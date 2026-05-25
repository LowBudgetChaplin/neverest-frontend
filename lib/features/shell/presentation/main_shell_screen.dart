import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../access/presentation/cubit/access_cubit.dart';
import '../../admin/presentation/screens/admin_center_screen.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../shell/presentation/design/neverest_design.dart';
import '../../profile/presentation/bloc/profile_bloc.dart';
import '../../../l10n/app_localizations.dart';
import 'tabs/challenges_tab_screen.dart';
import 'tabs/events_tab_screen.dart';
import 'tabs/home_tab_screen.dart';
import 'tabs/leaderboard_tab_screen.dart';
import 'tabs/rewards_tab_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncShellDataForCurrentAuthState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<DashboardBloc, bool>(
      (bloc) => bloc.state.status == DashboardStatus.loading,
    );
    final canOpenAdminCenter = context.select<AccessCubit, bool>(
      (cubit) => cubit.state.canOpenAdminCenter,
    );
    final l10n = AppLocalizations.of(context)!;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => previous.status != current.status,
          listener: (context, authState) {
            if (authState.status == AuthStatus.authenticated) {
              context.read<ProfileBloc>().add(
                    ProfileLoadRequested(
                      suggestedDisplayName: _suggestDisplayName(authState),
                      preferMeEndpoints: true,
                    ),
                  );
              context.read<DashboardBloc>().add(const DashboardLoadRequested());
              context.read<AccessCubit>().refresh();
              return;
            }

            if (authState.status == AuthStatus.unauthenticated ||
                authState.status == AuthStatus.unavailable) {
              if (_selectedIndex != 0) {
                setState(() {
                  _selectedIndex = 0;
                });
              }
              context.read<ProfileBloc>().add(const ProfileClearedRequested());
              context
                  .read<DashboardBloc>()
                  .add(const DashboardClearedRequested());
              context.read<AccessCubit>().refresh();
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              previous.message != current.message &&
              current.message != null &&
              current.message!.trim().isNotEmpty,
          listener: (context, authState) {
            final messenger = ScaffoldMessenger.maybeOf(context);
            final message = authState.message;
            if (messenger == null ||
                message == null ||
                message.trim().isEmpty) {
              return;
            }
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(message)),
              );
          },
        ),
      ],
      child: Scaffold(
        floatingActionButton: isLoading
            ? FloatingActionButton.small(
                onPressed: null,
                backgroundColor: NeverestPalette.orange.withOpacity(0.4),
                child: const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              )
            : null,
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeTabScreen(
              onSelectTab: _selectTab,
              onOpenAdmin: canOpenAdminCenter ? _openAdminCenter : null,
            ),
            const EventsTabScreen(),
            const ChallengesTabScreen(),
            const LeaderboardTabScreen(),
            const RewardsTabScreen(),
          ],
        ),
        bottomNavigationBar: _NeverestBottomNav(
          selectedIndex: _selectedIndex,
          onSelected: _selectTab,
          items: [
            _NavItem(icon: Icons.home_rounded, label: l10n.navHome),
            _NavItem(icon: Icons.calendar_month_rounded, label: l10n.navEvents),
            _NavItem(
              icon: Icons.bolt_rounded,
              label: l10n.navChallenges,
              center: true,
            ),
            _NavItem(
              icon: Icons.emoji_events_rounded,
              label: l10n.navLeaderboard,
            ),
            _NavItem(icon: Icons.redeem_rounded, label: l10n.navRewards),
          ],
        ),
      ),
    );
  }

  void _selectTab(int value) {
    if (_selectedIndex == value) {
      return;
    }
    setState(() {
      _selectedIndex = value;
    });
  }

  void _openAdminCenter() {
    Navigator.of(context).push(
      AppPageRoute.fadeSlide(const AdminCenterScreen()),
    );
  }

  void _syncShellDataForCurrentAuthState() {
    final authState = context.read<AuthBloc>().state;
    if (authState.status != AuthStatus.authenticated) {
      context.read<AccessCubit>().refresh();
      return;
    }

    context.read<ProfileBloc>().add(
          ProfileLoadRequested(
            suggestedDisplayName: _suggestDisplayName(authState),
            preferMeEndpoints: true,
          ),
        );
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
    context.read<AccessCubit>().refresh();
  }

  String _suggestDisplayName(AuthState authState) {
    final session = authState.session;
    if (session == null) {
      return 'Neverest User';
    }
    if (session.displayName != null && session.displayName!.trim().isNotEmpty) {
      return session.displayName!.trim();
    }
    if (session.email != null && session.email!.trim().isNotEmpty) {
      final username = session.email!.trim().split('@').first;
      if (username.isNotEmpty) {
        return username;
      }
    }
    return 'Neverest User';
  }
}

class _NeverestBottomNav extends StatelessWidget {
  const _NeverestBottomNav({
    required this.selectedIndex,
    required this.onSelected,
    required this.items,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<_NavItem> items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 4, 8, bottomInset > 0 ? bottomInset : 10),
        child: SizedBox(
          height: 70,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final selected = index == selectedIndex;
              if (item.center) {
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => onSelected(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: NeverestPalette.orange,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    NeverestPalette.orange.withOpacity(0.45),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.bolt_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                letterSpacing: 0.9,
                                color: isDark
                                    ? NeverestPalette.inkMuted
                                    : NeverestPalette.paperMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final color = selected
                  ? NeverestPalette.orange
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onSelected(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: color, size: 23),
                      const SizedBox(height: 4),
                      Text(
                        item.label.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.9,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.label,
    this.center = false,
  });

  final IconData icon;
  final String label;
  final bool center;
}
