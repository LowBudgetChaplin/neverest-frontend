import 'package:flutter/material.dart';

import '../../extensions/app_colors_ext.dart';
import '../../extensions/app_shapes_ext.dart';
import '../../extensions/app_spacing_ext.dart';
import 'light_theme.dart';

class DarkTheme {
  static const colorsDark = AppColorsExt(
    primary: Color(0xFFFF5A1F),
    secondary: Color(0xFF8B8B92),
    bgPrimary: Color(0xFF0A0A0B),
    bgDefault: Color(0xFF0A0A0B),
    bgCardDark: Color(0xFF161618),
    bgCardDefault: Color(0xFF161618),
    borderCardDark: Color(0xFF26262A),
    borderCardLight: Color(0xFF26262A),
    txtDefault: Color(0xFFFAFAF7),
    txtBodyDark: Color(0xFFFAFAF7),
    txtBodyLight: Color(0xFF8B8B92),
    txtBtnPrimary: Color(0xFFFFFFFF),
    txtBtnOutline: Color(0xFFFAFAF7),
    disabled: Color(0xFF8B8B92),
    disabledLight: Color(0x338B8B92),
    error: Color(0xFFE5484D),
    errorLight: Color(0xFFFFD9D7),
    positive: Color(0xFF2EBD6B),
    positiveLight: Color(0xFFDCF6E8),
    txtBtnSecondary: Color(0xFFFAFAF7),
    bgAppBar: Color(0xFF0A0A0B),
    bgDialog: Color(0xFF161618),
  );

  static const AppShapesExt shapesDark = LightTheme.shapesLight;
  static const AppSpacingExt spacingDark = LightTheme.spacingLight;
}
