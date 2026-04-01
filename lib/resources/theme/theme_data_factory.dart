import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:neverest/core/utils/extensions.dart';
import 'package:neverest/resources/extensions/app_colors_ext.dart';
import 'package:neverest/resources/extensions/app_shapes_ext.dart';
import 'package:neverest/resources/extensions/app_spacing_ext.dart';

import '../styles_managers/font_manager.dart';
import '../styles_managers/styles_manager.dart';

/// App theme changer for text, tabs, appBar, bottomNavgBar etc. depending on the app theme case from theme_controller
ThemeData makeTheme({
  required AppColorsExt colors,
  required AppSpacingExt spacing,
  required AppShapesExt shapes,
  Brightness brightness = Brightness.light,
}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: colors.primary,
    brightness: brightness,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakarta',
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    primaryColor: colorScheme.primary,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colorScheme.primary,
      selectionColor: colorScheme.primary.withOpacityPercent(0.25),
      selectionHandleColor: colorScheme.primary,
    ),

    // Cupertino theme alignment for IOS style
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: colorScheme.primary,
    ),

    progressIndicatorTheme:
        ProgressIndicatorThemeData(color: colorScheme.primary),

    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      shape: Border(
        bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.secondaryContainer,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return getBodySmallStyleBase(
          themeColors: colors,
          color:
              selected ? colorScheme.onSecondaryContainer : colors.txtBodyLight,
        );
      }),
    ),

    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      elevation: 0.2,
      shadowColor: Colors.black12,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shapes.cardRadius + 2),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      isDense: false,
      contentPadding: EdgeInsets.symmetric(
        vertical: spacing.textFieldPaddingVertical,
        horizontal: spacing.textFieldPaddingHorizontal,
      ),
      hintStyle:
          getBodyMediumStyleBase(themeColors: colors, color: colors.disabled),
      labelStyle: getBodyMediumStyleBase(
        themeColors: colors,
        color: colors.txtBodyLight,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      floatingLabelAlignment: FloatingLabelAlignment.start,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.textFieldRadius),
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.textFieldRadius),
        borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.textFieldRadius),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.secondaryContainer,
      selectedColor: colorScheme.primaryContainer,
      labelStyle: getBodySmallStyleBase(
        themeColors: colors,
        color: colorScheme.onSecondaryContainer,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Global text styles settings and theme extensions
    textTheme: TextTheme(
      bodyMedium: getBodyMediumStyleBase(
        themeColors: colors,
        fontWeight: FontWeightManager.semibold,
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[
      colors,
      shapes,
      spacing,
    ],
  );
}
