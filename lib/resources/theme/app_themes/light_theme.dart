import 'package:flutter/material.dart';

import '../../extensions/app_colors_ext.dart';
import '../../extensions/app_shapes_ext.dart';
import '../../extensions/app_spacing_ext.dart';

class LightTheme {
  static const colorsLight = AppColorsExt(
    primary: Color(0xFFFF5A1F),
    secondary: Color(0xFF6E6E72),
    bgPrimary: Color(0xFFFAFAF7),
    bgDefault: Color(0xFFFAFAF7),
    bgCardDark: Color(0xFF161618),
    bgCardDefault: Color(0xFFFFFFFF),
    borderCardDark: Color(0xFF26262A),
    borderCardLight: Color(0xFFE8E6DF),
    txtDefault: Color(0xFF0A0A0B),
    txtBodyDark: Color(0xFF0A0A0B),
    txtBodyLight: Color(0xFF6E6E72),
    txtBtnPrimary: Color(0xFFFFFFFF),
    txtBtnOutline: Color(0xFF0A0A0B),
    disabled: Color(0xFF9B9BA1),
    disabledLight: Color(0x339B9BA1),
    error: Color(0xFFE5484D),
    errorLight: Color(0xFFFFD9D7),
    positive: Color(0xFF2EBD6B),
    positiveLight: Color(0xFFDCF6E8),
    txtBtnSecondary: Color(0xFF0A0A0B),
    bgAppBar: Color(0xFFFAFAF7),
    bgDialog: Color(0xFFFFFFFF),
  );

  static const shapesLight = AppShapesExt(
    buttonRadius: 24,
    buttonSmallRadius: 14,
    cardRadius: 18,
    textFieldRadius: 14,
    elevation: 0.0,
    radiusDefault: 18,
    radiusSmall: 12,
    tileIcon: 44,
    sheetHandleHeight: 4,
    sheetHandleWidth: 40,
    sheetHandleRadius: 99,
    sheetTitleFontSize: 18,
  );

  static const spacingLight = AppSpacingExt(
    screenPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    cardPadding: EdgeInsets.all(16),
    itemListMediumMarginHorizontal: 12,
    itemListMediumMarginVertical: 12,
    itemDefaultMargin: 16,
    tabLabelPaddingVertical: 5,
    tabLabelPaddingHorizontal: 18,
    titleDescSpacingVertical: 8,
    smallMarginVertical: 7,
    leadIconMarginHorizontal: 8,
    textFieldPaddingVertical: 12,
    textFieldPaddingHorizontal: 14,
    labelSmallPaddingVertical: 4,
    labelSmallPaddingHorizontal: 12,
    itemLargeMarginVertical: 32,
  );
}