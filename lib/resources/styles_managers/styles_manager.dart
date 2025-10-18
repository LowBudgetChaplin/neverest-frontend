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
      color: color, fontWeight:
  fontWeight);
}

extension AppThemeGetters on BuildContext {
  AppColorsExt get colors => Theme.of(this).extension<AppColorsExt>()!;
}

TextStyle getTitleHeader1Style(BuildContext context, { double fontSize = FontSize.header1, Color? color, fontWeight = FontWeightManager.bold}) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}

TextStyle getTitleHeader2Style(BuildContext context, { double fontSize = FontSize.header2, Color? color, fontWeight = FontWeightManager.bold}) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}

TextStyle getMainHeaderStyle(BuildContext context, { double fontSize = FontSize.header3, Color? color, fontWeight = FontWeightManager.bold }) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}

TextStyle getMainHeaderStyleBase(BuildContext context, { double fontSize = FontSize.header3, Color? color, fontWeight = FontWeightManager.bold }) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}

TextStyle getSecondaryHeaderStyle(BuildContext context, { double fontSize = FontSize.header4, Color? color, fontWeight = FontWeightManager.semibold }) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}

TextStyle getSecondaryHeaderStyleBase(BuildContext context, { double fontSize = FontSize.header4, Color? color, fontWeight = FontWeightManager.semibold }) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}

TextStyle getBodyLargeStyle(BuildContext context, { double fontSize = FontSize.body1, Color? color, fontWeight = FontWeightManager.semibold }) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}

TextStyle getBodyMediumStyle(BuildContext context, { double fontSize = FontSize.body2, Color? color, fontWeight = FontWeightManager.medium}) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}

TextStyle getBodyMediumStyleBase(BuildContext context, { double fontSize = FontSize.body2, Color? color, fontWeight = FontWeightManager.medium}) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}

TextStyle getBodySmallStyle(BuildContext context, { double fontSize = FontSize.body3, Color? color, fontWeight = FontWeightManager.medium }) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}

TextStyle getBodySmallStyleBase(BuildContext context, { double fontSize = FontSize.body3, Color? color, fontWeight = FontWeightManager.medium }) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}

TextStyle getBodyXSmallStyle(BuildContext context, { double fontSize = FontSize.body4, Color? color, fontWeight = FontWeightManager.regular }) {
  return _getTextStyle(fontSize, fontWeight, color ?? context.colors.txtDefault);
}