import 'package:flutter/material.dart';
import '../../extensions/app_colors_ext.dart';
import '../../extensions/app_shapes_ext.dart';
import '../../extensions/app_spacing_ext.dart';
import '../../styles_managers/dimens_manager.dart';


/// LightTheme aggregates ThemeExtensions for the light palette:
/// - `colorsLight`: all color tokens
/// - `shapesLight`: radius/elevation/geometry tokens
/// - `spacingLight`: paddings/margins/gaps
///
/// Plug these into `ThemeData.extensions` to make them available via
/// `Theme.of(context).extension<...>()`.
class LightTheme {
  static final colorsLight = AppColorsExt( //TODO: set the  proper figma theme colors
    primary: HexColor.fromHex("#6750A4"),
    secondary: HexColor.fromHex("#625B71"),
    bgPrimary: HexColor.fromHex("#FFFFFF"),
    bgDefault: HexColor.fromHex("#F6F6F6"),
    bgCardDark: HexColor.fromHex("#1E1E1E"),
    bgCardDefault: HexColor.fromHex("#FFFFFF"),
    borderCardDark: HexColor.fromHex("#2C2C2C"),
    borderCardLight: HexColor.fromHex("#E5E5E5"),
    txtDefault: HexColor.fromHex("#111111"),
    txtBodyDark: HexColor.fromHex("#2B2B2B"),
    txtBodyLight: HexColor.fromHex("#757575"),
    txtBtnPrimary: HexColor.fromHex("#FFFFFF"),
    txtBtnOutline: HexColor.fromHex("#6750A4"),
    disabled: HexColor.fromHex("#9E9E9E"),
    disabledLight: HexColor.fromHex("#0DA3A3A3"),
    error: HexColor.fromHex("#B3261E"),
    errorLight: HexColor.fromHex("#F2B8B5"),
    positive: HexColor.fromHex("#2E7D32"),
    positiveLight: HexColor.fromHex("#A5D6A7"),
    txtBtnSecondary: HexColor.fromHex("#FFFFFF"),
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