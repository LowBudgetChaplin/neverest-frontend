import 'package:flutter/material.dart';
import '../extensions/app_colors_ext.dart';
import '../extensions/app_shapes_ext.dart';
import '../extensions/app_spacing_ext.dart';
import '../styles_managers/dimens_manager.dart';


/// LightTheme aggregates ThemeExtensions for the light palette:
/// - `colorsLight`: all color tokens
/// - `shapesLight`: radius/elevation/geometry tokens
/// - `spacingLight`: paddings/margins/gaps
///
/// Plug these into `ThemeData.extensions` to make them available via
/// `Theme.of(context).extension<...>()`.
class LightTheme {
  static final colorsLight = AppColorsExt( //TODO: se the theme colors
    primary: HexColor.fromHex(""),
    secondary: HexColor.fromHex(""),
    bgPrimary: HexColor.fromHex(""),
    bgDefault: HexColor.fromHex(""),
    bgCardDark: HexColor.fromHex(""),
    bgCardDefault: HexColor.fromHex(""),
    borderCardDark: HexColor.fromHex(""),
    borderCardLight: HexColor.fromHex(""),
    txtDefault: HexColor.fromHex(""),
    txtBodyDark: HexColor.fromHex(""),
    txtBodyLight: HexColor.fromHex(""),
    txtBtnPrimary: HexColor.fromHex(""),
    txtBtnOutline: HexColor.fromHex(""),
    disabled: HexColor.fromHex(""),
    disabledLight: HexColor.fromHex("#0DA3A3A3"),
    error: HexColor.fromHex(""),
    errorLight: HexColor.fromHex(""),
    positive:  HexColor.fromHex(""),
    positiveLight: HexColor.fromHex(""),
    txtBtnSecondary: HexColor.fromHex(""),
    bgAppBar: Colors.white,
    bgDialog: Colors.white,
  );

  static const shapesLight = AppShapesExt(
      buttonRadius: AppRadius.buttonRadius,
      buttonSmallRadius: AppRadius.buttonSmallRadius,
      cardRadius: AppRadius.cardRadius,
      textFieldRadius: 12.0,
      elevation: AppSize.elevation,
      radiusDefault: 16.0,
      radiusSmall: 12.0,
      tileIcon: 74.0,
      sheetHandleHeight: 3.0,
      sheetHandleWidth: 39.0,
      sheetHandleRadius: 2.0,
      sheetTitleFontSize: 18.0,
  );

  static const spacingLight = AppSpacingExt(
      screenPadding: EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      cardPadding: EdgeInsets.all(16.0),
      itemListMediumMarginHorizontal: 12.0,
      itemListMediumMarginVertical: 12.0,
      itemDefaultMargin: 16.0,
      tabLabelPaddingVertical: 5.0,
      tabLabelPaddingHorizontal: 18.0,
      titleDescSpacingVertical: 8.0,
      smallMarginVertical: 7.0,
      leadIconMarginHorizontal: 8.0,
      textFieldPaddingVertical: 12.0,
      textFieldPaddingHorizontal: 16.0,
      labelSmallPaddingVertical: 4.0,
      labelSmallPaddingHorizontal: 12.0,
      itemLargeMarginVertical: 32.0,
  );
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll("#", '');
    if(hexColorString.length == 6) {
      hexColorString = "FF$hexColorString";
    }
    return Color(int.parse(hexColorString, radix: 16));
  }
}