import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/access/data/access_repository.dart';
import '../features/access/presentation/cubit/access_cubit.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/admin/data/admin_repository.dart';
import '../features/challenges/data/challenge_action_repository.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import '../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../features/events/data/event_action_repository.dart';
import '../features/leaderboard/data/leaderboard_repository.dart';
import '../features/leaderboard/presentation/cubit/activity_leaderboard_cubit.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/rewards/data/reward_action_repository.dart';
import '../features/strava/data/strava_repository.dart';
import '../features/strava/presentation/cubit/strava_cubit.dart';
import '../features/theme/presentation/app_locale_cubit.dart';
import '../features/theme/presentation/theme_mode_cubit.dart';
import '../l10n/app_localizations.dart';
import '../resources/theme/app_themes/dark_theme.dart';
import '../resources/theme/app_themes/light_theme.dart';
import '../resources/theme/theme_data_factory.dart';
import 'router/app_router.dart';
import 'services/api_client.dart';
import 'services/auth_token_storage.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AuthTokenStorage _authTokenStorage;
  late final ApiClient _apiClient;
  late final DashboardRepository _dashboardRepository;
  late final EventActionRepository _eventActionRepository;
  late final ChallengeActionRepository _challengeActionRepository;
  late final RewardActionRepository _rewardActionRepository;
  late final AdminRepository _adminRepository;
  late final LeaderboardRepository _leaderboardRepository;
  late final AccessRepository _accessRepository;
  late final AuthRepository _authRepository;
  late final ProfileRepository _profileRepository;
  late final StravaRepository _stravaRepository;

  @override
  void initState() {
    super.initState();
    _authTokenStorage = AuthTokenStorage();
    _apiClient = ApiClient(_authTokenStorage);
    _dashboardRepository = DashboardRepository(_apiClient);
    _eventActionRepository = EventActionRepository(_apiClient);
    _challengeActionRepository = ChallengeActionRepository(_apiClient);
    _rewardActionRepository = RewardActionRepository(_apiClient);
    _adminRepository = AdminRepository(_apiClient);
    _leaderboardRepository = LeaderboardRepository(_apiClient);
    _accessRepository = AccessRepository(_apiClient);
    _authRepository = AuthRepository(
      tokenStorage: _authTokenStorage,
      apiClient: _apiClient,
    );
    _profileRepository = ProfileRepository(_apiClient);
    _stravaRepository = StravaRepository(_apiClient);
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lightTheme = makeTheme(
      colors: LightTheme.colorsLight,
      spacing: LightTheme.spacingLight,
      shapes: LightTheme.shapesLight,
      brightness: Brightness.light,
    );
    final darkTheme = makeTheme(
      colors: DarkTheme.colorsDark,
      spacing: DarkTheme.spacingDark,
      shapes: DarkTheme.shapesDark,
      brightness: Brightness.dark,
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _authTokenStorage),
        RepositoryProvider.value(value: _apiClient),
        RepositoryProvider.value(value: _dashboardRepository),
        RepositoryProvider.value(value: _eventActionRepository),
        RepositoryProvider.value(value: _challengeActionRepository),
        RepositoryProvider.value(value: _rewardActionRepository),
        RepositoryProvider.value(value: _adminRepository),
        RepositoryProvider.value(value: _leaderboardRepository),
        RepositoryProvider.value(value: _accessRepository),
        RepositoryProvider.value(value: _authRepository),
        RepositoryProvider.value(value: _profileRepository),
        RepositoryProvider.value(value: _stravaRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DashboardBloc(
              repository: _dashboardRepository,
            ),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              repository: _authRepository,
              apiClient: _apiClient,
            )..add(const AuthRestoreRequested()),
          ),
          BlocProvider(
            create: (context) => ProfileBloc(
              repository: _profileRepository,
            ),
          ),
          BlocProvider(
            create: (context) => AccessCubit(
              repository: _accessRepository,
            )..refresh(),
          ),
          BlocProvider(
            create: (context) => StravaCubit(_stravaRepository),
          ),
          BlocProvider(
            create: (context) => ActivityLeaderboardCubit(
              repository: _leaderboardRepository,
            ),
          ),
          BlocProvider(create: (_) => ThemeModeCubit()),
          BlocProvider(create: (_) => AppLocaleCubit()),
        ],
        child: BlocBuilder<ThemeModeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final locale = context.watch<AppLocaleCubit>().state;
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: AppRouter.router,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeMode,
              locale: locale,
              themeAnimationDuration: const Duration(milliseconds: 220),
              themeAnimationCurve: Curves.easeInOutCubic,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );
  }
}
