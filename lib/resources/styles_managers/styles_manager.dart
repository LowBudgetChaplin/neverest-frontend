import 'package:flutter/material.dart';
import '../extensions/app_colors_ext.dart';
import 'font_manager.dart';

/// Centralizes the app’s text styles that are aware of the current theme
TextStyle _getTextStyle(
    double fontSize,
    FontWeight fontWeight,
    Color color) {

  return TextStyle(
      fontSize: fontSize,
      fontFamily: 'PlusJakarta', //TODO: to see if we keep this font
      fontFamilyFallback: const ['Roboto', 'sans-serif'],
      color: color, fontWeight:
  fontWeight);
}

extension AppThemeGetters on BuildContext {
  AppColorsExt get colors => Theme.of(this).extension<AppColorsExt>()!;
}

/// Helper for choosing the color depending on the context on themeColors
Color _resolveColor({
  BuildContext? context,
  AppColorsExt? themeColors,
  Color? explicitColor,
}) {
  if (explicitColor != null) return explicitColor;
  if (context != null) return context.colors.txtDefault;
  assert(themeColors != null, 'context is null, provide themeColors');
  return themeColors!.txtDefault;
}

/// TITLES / HEADERS

TextStyle getTitleHeader1Style({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.header1,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.bold;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}

TextStyle getTitleHeader2Style({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.header2,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.bold;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}

TextStyle getMainHeaderStyle({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.header3,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.bold;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}

TextStyle getMainHeaderStyleBase({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.header3,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.bold;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}

TextStyle getSecondaryHeaderStyle({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.header4,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.semibold;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}

TextStyle getSecondaryHeaderStyleBase({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.header4,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.semibold;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}

/// BODY

TextStyle getBodyLargeStyle({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.body1,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.semibold;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}

TextStyle getBodyMediumStyle({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.body2,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.medium;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}

TextStyle getBodyMediumStyleBase({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.body2,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.medium;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}

TextStyle getBodySmallStyle({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.body3,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.medium;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}

TextStyle getBodySmallStyleBase({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.body3,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.medium;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}

TextStyle getBodyXSmallStyle({
  BuildContext? context,
  AppColorsExt? themeColors,
  double fontSize = FontSize.body4,
  Color? color,
  FontWeight? fontWeight,
}) {
  final fw = fontWeight ?? FontWeightManager.regular;
  final baseColor = _resolveColor(context: context, themeColors: themeColors, explicitColor: color);
  return _getTextStyle(fontSize, fw, baseColor);
}