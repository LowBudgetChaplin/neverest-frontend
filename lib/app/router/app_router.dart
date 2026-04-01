import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/launch_gate_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'shell',
        builder: (context, state) => const LaunchGateScreen(),
      ),
    ],
  );
}
