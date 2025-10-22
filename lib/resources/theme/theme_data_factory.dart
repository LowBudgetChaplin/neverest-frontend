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
}) {
  return ThemeData(
    scaffoldBackgroundColor: colors.bgDefault,
    primaryColor: colors.primary,
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primary.withOpacityPercent(0.3),
        selectionHandleColor: colors.primary
    ),

    // Cupertino theme alignment for IOS style
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: colors.primary,
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary
    ),

    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: colors.bgCardDefault,
      foregroundColor: colors.txtDefault,
      elevation: 0,
      shape: Border(
        bottom: BorderSide(color: colors.borderCardLight, width: 1),
      ),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.txtBodyLight,
      selectedLabelStyle: getBodySmallStyleBase(themeColors: colors),
      unselectedLabelStyle: getBodySmallStyleBase(themeColors: colors),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    cardTheme: CardThemeData(
      color: colors.bgCardDefault,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shapes.cardRadius),
        side: BorderSide(color: colors.borderCardLight, width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: false,
      contentPadding: EdgeInsets.symmetric(vertical: spacing.textFieldPaddingVertical, horizontal: spacing.textFieldPaddingHorizontal),
      hintStyle: getBodyMediumStyleBase(themeColors: colors, color: colors.disabled),
      labelStyle: getBodyMediumStyleBase(themeColors: colors, color: colors.txtBodyLight),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      floatingLabelAlignment: FloatingLabelAlignment.start,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.textFieldRadius),
        borderSide: BorderSide(color: colors.borderCardLight , width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.textFieldRadius),
        borderSide: BorderSide(color: colors.borderCardLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.textFieldRadius),
        borderSide: BorderSide(color: colors.primary, width: 1),
      ),
    ),

    // Global text styles settings and theme extensions
    textTheme: TextTheme(
        bodyMedium: getBodyMediumStyleBase(themeColors: colors, fontWeight: FontWeightManager.semibold)
    ),
    extensions: <ThemeExtension<dynamic>>[
      colors, shapes, spacing,
    ],
  );
}