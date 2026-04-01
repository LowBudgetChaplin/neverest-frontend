import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../access/presentation/cubit/access_cubit.dart';
import '../../admin/presentation/screens/admin_center_screen.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../profile/presentation/bloc/profile_bloc.dart';
import '../../theme/presentation/theme_mode_cubit.dart';
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

  static const _titles = [
    'Neverest',
    'Events',
    'Challenges',
    'Rewards',
    'Leaderboard',
  ];

  static const _tabs = [
    HomeTabScreen(),
    EventsTabScreen(),
    ChallengesTabScreen(),
    RewardsTabScreen(),
    LeaderboardTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<DashboardBloc, bool>(
      (bloc) => bloc.state.status == DashboardStatus.loading,
    );
    final canOpenAdminCenter = context.select<AccessCubit, bool>(
      (cubit) => cubit.state.canOpenAdminCenter,
    );
    final isDarkMode = context.select<ThemeModeCubit, bool>(
      (cubit) => cubit.state == ThemeMode.dark,
    );

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
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_titles[_selectedIndex]),
              Text(
                'Neverest Club',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          actions: [
            if (canOpenAdminCenter)
              IconButton(
                tooltip: 'Admin center',
                onPressed: () {
                  Navigator.of(context).push(
                    AppPageRoute.fadeSlide(const AdminCenterScreen()),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings_outlined),
              ),
            IconButton(
              tooltip:
                  isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
              onPressed: () => context.read<ThemeModeCubit>().toggle(),
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            ),
            IconButton(
              tooltip: 'Refresh from backend',
              onPressed: isLoading
                  ? null
                  : () {
                      context
                          .read<DashboardBloc>()
                          .add(const DashboardRefreshRequested());
                    },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: _tabs,
        ),
        bottomNavigationBar: NavigationBar(
          height: 74,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (value) {
            setState(() {
              _selectedIndex = value;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag),
              label: 'Challenges',
            ),
            NavigationDestination(
              icon: Icon(Icons.card_giftcard_outlined),
              selectedIcon: Icon(Icons.card_giftcard),
              label: 'Rewards',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events),
              label: 'Leaderboard',
            ),
          ],
        ),
      ),
    );
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
