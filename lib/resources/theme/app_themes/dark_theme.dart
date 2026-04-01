import 'package:flutter/material.dart';

import '../../extensions/app_colors_ext.dart';
import '../../extensions/app_shapes_ext.dart';
import '../../extensions/app_spacing_ext.dart';
import 'light_theme.dart';

class DarkTheme {
  static const colorsDark = AppColorsExt(
    primary: Color(0xFFFF8A4B),
    secondary: Color(0xFFB0A7D1),
    bgPrimary: Color(0xFF0F1115),
    bgDefault: Color(0xFF0F1115),
    bgCardDark: Color(0xFF171A21),
    bgCardDefault: Color(0xFF171A21),
    borderCardDark: Color(0xFF2B3240),
    borderCardLight: Color(0xFF2B3240),
    txtDefault: Color(0xFFF3F4F8),
    txtBodyDark: Color(0xFFE5E7EC),
    txtBodyLight: Color(0xFFA1A7B3),
    txtBtnPrimary: Color(0xFF111318),
    txtBtnOutline: Color(0xFFF3F4F8),
    disabled: Color(0xFF6E7380),
    disabledLight: Color(0x4D6E7380),
    error: Color(0xFFFFB4AB),
    errorLight: Color(0xFF8C1D18),
    positive: Color(0xFF81C784),
    positiveLight: Color(0xFF1C4F2B),
    txtBtnSecondary: Color(0xFFF3F4F8),
    bgAppBar: Color(0xFF0F1115),
    bgDialog: Color(0xFF171A21),
  );

  static const AppShapesExt shapesDark = LightTheme.shapesLight;
  static const AppSpacingExt spacingDark = LightTheme.spacingLight;
}
