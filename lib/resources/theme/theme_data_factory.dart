import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../extensions/app_colors_ext.dart';
import '../extensions/app_shapes_ext.dart';
import '../extensions/app_spacing_ext.dart';

ThemeData makeTheme({
  required AppColorsExt colors,
  required AppSpacingExt spacing,
  required AppShapesExt shapes,
  Brightness brightness = Brightness.light,
}) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: colors.primary,
    onPrimary: Colors.white,
    secondary: colors.secondary,
    onSecondary: isDark ? colors.bgPrimary : colors.bgCardDark,
    error: colors.error,
    onError: Colors.white,
    surface: colors.bgDefault,
    onSurface: colors.txtDefault,
  );

  final baseTextTheme = ThemeData(
    brightness: brightness,
    fontFamily: 'PlusJakarta',
  ).textTheme;

  return ThemeData(
    useMaterial3: true,
    fontFamily: 'PlusJakarta',
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colors.bgDefault,
    primaryColor: colors.primary,
    dividerColor: isDark ? colors.borderCardDark : colors.borderCardLight,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colors.primary,
      selectionColor: colors.primary.withOpacity(0.22),
      selectionHandleColor: colors.primary,
    ),
    cupertinoOverrideTheme: CupertinoThemeData(primaryColor: colors.primary),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: colors.bgAppBar,
      foregroundColor: colors.txtDefault,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: baseTextTheme.titleMedium?.copyWith(
        color: colors.txtDefault,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: isDark ? colors.bgCardDefault : colors.bgCardDefault,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(shapes.cardRadius),
        side: BorderSide(
          color: isDark ? colors.borderCardDark : colors.borderCardLight,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? colors.bgCardDefault : colors.bgPrimary,
      contentPadding: EdgeInsets.symmetric(
        vertical: spacing.textFieldPaddingVertical,
        horizontal: spacing.textFieldPaddingHorizontal,
      ),
      hintStyle: baseTextTheme.bodyMedium?.copyWith(color: colors.txtBodyLight),
      labelStyle:
          baseTextTheme.bodyMedium?.copyWith(color: colors.txtBodyLight),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.textFieldRadius),
        borderSide: BorderSide(
          color: isDark ? colors.borderCardDark : colors.borderCardLight,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.textFieldRadius),
        borderSide: BorderSide(
          color: isDark ? colors.borderCardDark : colors.borderCardLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(shapes.textFieldRadius),
        borderSide: BorderSide(color: colors.primary),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? colors.bgCardDefault : colors.bgPrimary,
      selectedColor: colors.primary.withOpacity(0.14),
      labelStyle: baseTextTheme.labelSmall?.copyWith(
        color: colors.txtDefault,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: isDark ? colors.borderCardDark : colors.borderCardLight,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.bgDefault,
      indicatorColor: Colors.transparent,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return baseTextTheme.labelSmall?.copyWith(
          color: selected ? colors.primary : colors.txtBodyLight,
          fontWeight: FontWeight.w700,
        );
      }),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.txtBtnPrimary,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shapes.buttonRadius),
        ),
        textStyle: baseTextTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.txtDefault,
        minimumSize: const Size(0, 48),
        side: BorderSide(
          color: isDark ? colors.borderCardDark : colors.borderCardLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shapes.buttonRadius),
        ),
        textStyle: baseTextTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? colors.bgCardDefault : colors.bgCardDark,
      contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
        color: isDark ? Colors.white : Colors.white,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    textTheme: baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: 60,
        height: 0.95,
        color: colors.txtDefault,
        letterSpacing: 0.7,
        fontWeight: FontWeight.w800,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: 42,
        height: 0.96,
        color: colors.txtDefault,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w800,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: 30,
        height: 1,
        color: colors.txtDefault,
        letterSpacing: 0.4,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: 24,
        height: 1,
        color: colors.txtDefault,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: colors.txtDefault,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        color: colors.txtDefault,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        color: colors.txtDefault,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: colors.txtDefault,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        color: colors.txtBodyLight,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        color: colors.txtBodyLight,
        fontWeight: FontWeight.w700,
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[
      colors,
      shapes,
      spacing,
    ],
  );
}
