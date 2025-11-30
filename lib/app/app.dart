import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neverest/resources/routes_manager.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../resources/theme/theme_controller.dart';

/// Root widget of the app
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

/// State for the root widget
class _MainAppState extends State<MainApp> {

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      // Watches the current locale; UI rebuilds when locale changes
      final locale = ref.watch(localeProvider);
      final theme = ref.watch(themeDataProvider);

      return MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RouteGenerator.getRoute,
        initialRoute: Routes.mainRoute, //TODO: change it for now to see your preferred screen to work on until we connect the flux
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: theme, //TODO: replace with the actual theme
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales
      );
    });
  }
}