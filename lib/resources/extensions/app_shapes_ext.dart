import 'dart:ui';
import 'package:flutter/material.dart';

/// Theme extension that centralizes shape-related tokens:
/// radius, elevation, sizes etc.
/// Enables consistent UI geometry and smooth transitions (copyWith/lerp)
@immutable
class AppShapesExt extends ThemeExtension<AppShapesExt> {
  final double buttonRadius;
  final double buttonSmallRadius;
  final double cardRadius;
  final double elevation;
  final double radiusDefault;
  final double textFieldRadius;
  final double radiusSmall;
  final double tileIcon;
  final double sheetHandleHeight;
  final double sheetHandleWidth;
  final double sheetHandleRadius;
  final double sheetTitleFontSize;

  const AppShapesExt({
    required this.buttonRadius,
    required this.buttonSmallRadius,
    required this.cardRadius,
    required this.elevation,
    required this.radiusDefault,
    required this.textFieldRadius,
    required this.radiusSmall,
    required this.tileIcon,
    required this.sheetHandleHeight,
    required this.sheetHandleWidth,
    required this.sheetHandleRadius,
    required this.sheetTitleFontSize,
  });

  @override
  AppShapesExt copyWith({
    double? buttonRadius,
    double? buttonSmallRadius,
    double? cardRadius,
    double? elevation,
    double? radiusDefault,
    double? textFieldRadius,
    double? radiusSmall,
    double? tileIcon,
    double? sheetHandleHeight,
    double? sheetHandleWidth,
    double? sheetHandleRadius,
    double? sheetTitleFontSize,
  }) => AppShapesExt(
    buttonRadius: buttonRadius ?? this.buttonRadius,
    buttonSmallRadius: buttonSmallRadius ?? this.buttonSmallRadius,
    cardRadius: cardRadius ?? this.cardRadius,
    elevation: elevation ?? this.elevation,
    radiusDefault: radiusDefault ?? this.radiusDefault,
    textFieldRadius: textFieldRadius ?? this.textFieldRadius,
    radiusSmall: radiusSmall ?? this.radiusSmall,
    tileIcon: tileIcon ?? this.tileIcon,
    sheetHandleHeight: sheetHandleHeight ?? this.sheetHandleHeight,
    sheetHandleWidth:  sheetHandleWidth  ?? this.sheetHandleWidth,
    sheetHandleRadius: sheetHandleRadius ?? this.sheetHandleRadius,
    sheetTitleFontSize: sheetTitleFontSize ?? this.sheetTitleFontSize,
  );

  @override
  AppShapesExt lerp(ThemeExtension<AppShapesExt>? other, double t) {
    if (other is! AppShapesExt) return this;
    double l(double a, double b) => lerpDouble(a, b, t)!;
    return AppShapesExt(
      buttonRadius: l(buttonRadius, other.buttonRadius),
      buttonSmallRadius: l(buttonSmallRadius, other.buttonSmallRadius),
      cardRadius: l(cardRadius, other.cardRadius),
      elevation: l(elevation, other.elevation),
      radiusDefault: l(radiusDefault, other.radiusDefault),
      textFieldRadius: l(textFieldRadius, other.textFieldRadius),
      radiusSmall: l(radiusSmall, other.radiusSmall),
      tileIcon: l(tileIcon, other.tileIcon),
      sheetHandleHeight: l(sheetHandleHeight, other.sheetHandleHeight),
      sheetHandleWidth:  l(sheetHandleWidth,  other.sheetHandleWidth),
      sheetHandleRadius: l(sheetHandleRadius, other.sheetHandleRadius),
      sheetTitleFontSize: l(sheetTitleFontSize, other.sheetTitleFontSize),
    );
  }
}
