import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Routes {
  static const String getStartedRoute = "/getStartedRoute";
  static const String loginRoute = "/loginRoute";
}

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