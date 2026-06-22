import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neverest/resources/extensions/app_colors_ext.dart';
import 'package:neverest/resources/extensions/app_shapes_ext.dart';
import 'package:neverest/resources/extensions/app_spacing_ext.dart';
import 'package:neverest/resources/theme/app_themes/light_theme.dart';
import 'package:neverest/resources/theme/theme_data_factory.dart';

enum AppThemeKey {light, dark}

final themeKeyProvider = StateProvider<AppThemeKey>((_) => AppThemeKey.light);

final themeDataProvider = Provider<ThemeData>((ref) {
  final key = ref.watch(themeKeyProvider);
  late final AppColorsExt colorsExt;
  late final AppSpacingExt spacingExt;
  late final AppShapesExt shapesExt;

  switch (key){
    case AppThemeKey.light:
      colorsExt = LightTheme.colorsLight;
      spacingExt = LightTheme.spacingLight;
      shapesExt = LightTheme.shapesLight;
    case AppThemeKey.dark:
      // colorsExt = DarkTheme.colorsLight;
      // spacingExt = DarkTheme.spacingLight;
      // shapesExt = DarkTheme.shapesLight;
  }

  return makeTheme(
    colors: colorsExt,
    spacing: spacingExt,
    shapes: shapesExt,
  );
});