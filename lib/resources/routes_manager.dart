import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized list of route names used by the app's navigator
class Routes {
  static const String getStartedRoute = "/getStartedRoute";
  static const String loginRoute = "/loginRoute";
}

/// Returns a [Route] for the given [routeSettings.name]
/// Falls back to [undefinedRoute] when the route is not recognized
class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch(routeSettings.name) {

      case Routes.getStartedRoute:
        // TODO Create get started screen
        // return MaterialPageRoute(builder: (_) => const GetStartedScreen(), settings: routeSettings);
      case Routes.loginRoute:
        // TODO Create login screen
        // return MaterialPageRoute(builder: (_) => const GetStartedScreen(), settings: routeSettings);

      default:
        return undefinedRoute();
    }
  }

  /// If a [ProviderContainer] is passed in [RouteSettings.arguments],
  /// wraps [child] with [UncontrolledProviderScope] so it inherits the same Riverpod container
  static Widget inheritIfProvided(RouteSettings s, Widget child) {
    final a = s.arguments;
    if (a is ProviderContainer) {
      return UncontrolledProviderScope(container: a, child: child);
    }
    return child;
  }

  // shows a fallback route with a minimal blank screen
  static Route<dynamic> undefinedRoute() {
    return MaterialPageRoute(builder: (_) =>
        Scaffold(
          appBar: AppBar(title: const Text("")),
          body: const Center(child: Text(""),),
        )
    );
  }
}