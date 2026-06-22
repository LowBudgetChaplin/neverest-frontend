import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neverest/features/main/main_screen.dart';

class Routes {
  static const String getStartedRoute = "/getStartedRoute";
  static const String loginRoute = "/loginRoute";
  static const String mainRoute = "/mainRoute";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch(routeSettings.name) {

      case Routes.getStartedRoute:
        // return MaterialPageRoute(builder: (_) => const GetStartedScreen(), settings: routeSettings);
      case Routes.loginRoute:
        // return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: routeSettings);
      case Routes.mainRoute:
      return MaterialPageRoute(builder: (_) => const MainScreen(), settings: routeSettings);

      default:
        return undefinedRoute();
    }
  }

  /// If a [ProviderContainer] is passed in [RouteSettings.arguments],
  static Widget inheritIfProvided(RouteSettings s, Widget child) {
    final a = s.arguments;
    if (a is ProviderContainer) {
      return UncontrolledProviderScope(container: a, child: child);
    }
    return child;
  }

  static Route<dynamic> undefinedRoute() {
    return MaterialPageRoute(builder: (_) =>
        Scaffold(
          appBar: AppBar(title: const Text("")),
          body: const Center(child: Text(""),),
        )
    );
  }
}