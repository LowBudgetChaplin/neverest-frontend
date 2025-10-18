import 'package:flutter/material.dart';

/// Theme extension for the application's custom palette.
/// Allows defining/animating (copyWith/lerp) brand colors, background, text etc.
@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  final Color primary;
  final Color secondary;
  final Color bgPrimary;
  final Color bgDefault;
  final Color bgCardDark;
  final Color bgCardDefault;
  final Color borderCardDark;
  final Color borderCardLight;
  final Color txtDefault;
  final Color txtBodyDark;
  final Color txtBodyLight;
  final Color txtBtnPrimary;
  final Color txtBtnOutline;
  final Color disabled;
  final Color disabledLight;
  final Color error;
  final Color errorLight;
  final Color positive;
  final Color positiveLight;
  final Color txtBtnSecondary;
  final Color bgAppBar;
  final Color bgDialog;

  const AppColorsExt({
    required this.primary,
    required this.secondary,
    required this.bgPrimary,
    required this.bgDefault,
    required this.bgCardDark,
    required this.bgCardDefault,
    required this.borderCardDark,
    required this.borderCardLight,
    required this.txtDefault,
    required this.txtBodyDark,
    required this.txtBodyLight,
    required this.txtBtnPrimary,
    required this.txtBtnOutline,
    required this.disabled,
    required this.disabledLight,
    required this.error,
    required this.errorLight,
    required this.positive,
    required this.positiveLight,
    required this.txtBtnSecondary,
    required this.bgAppBar,
    required this.bgDialog
  }); @override AppColorsExt copyWith({
    Color? primary,
    Color? secondary,
    Color? bgPrimary,
    Color? bgDefault,
    Color? bgCardDark,
    Color? bgCardDefault,
    Color? borderCardDark,
    Color? borderCardLight,
    Color? txtDefault,
    Color? txtBodyDark,
    Color? txtBodyLight,
    Color? txtBtnPrimary,
    Color? txtBtnOutline,
    Color? disabled,
    Color? disabledLight,
    Color? error,
    Color? errorLight,
    Color? positive,
    Color? positiveLight,
    Color? txtBtnSecondary,
    Color? bgAppBar,
    Color? bgDialog
  }) => AppColorsExt(
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    bgPrimary: bgPrimary ?? this.bgPrimary,
    bgDefault: bgDefault ?? this.bgDefault,
    bgCardDark: bgCardDark ?? this.bgCardDark,
    bgCardDefault: bgCardDefault ?? this.bgCardDefault,
    borderCardDark: borderCardDark ?? this.borderCardDark,
    borderCardLight: borderCardLight ?? this.borderCardLight,
    txtDefault: txtDefault ?? this.txtDefault,
    txtBodyDark: txtBodyDark ?? this.txtBodyDark,
    txtBodyLight: txtBodyLight ?? this.txtBodyLight,
    txtBtnPrimary: txtBtnPrimary ?? this.txtBtnPrimary,
    txtBtnOutline: txtBtnOutline ?? this.txtBtnOutline,
    disabled: disabled ?? this.disabled,
    disabledLight: disabledLight ?? this.disabledLight,
    error: error ?? this.error,
    errorLight: errorLight ?? this.errorLight,
    positive: positive ?? this.positive,
    positiveLight: positiveLight ?? this.positiveLight,
    txtBtnSecondary: txtBtnSecondary ?? this.txtBtnSecondary,
    bgAppBar: bgAppBar ?? this.bgAppBar,
    bgDialog: bgDialog ?? this.bgDialog
  ); @override AppColorsExt lerp(ThemeExtension<AppColorsExt>? other, double t) {
    if (other is! AppColorsExt) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;

    return AppColorsExt(
        primary: l(primary, other.primary),
        secondary: l(secondary, other.secondary),
        bgPrimary: l(bgPrimary, other.bgPrimary),
        bgDefault: l(bgDefault, other.bgDefault),
        bgCardDark: l(bgCardDark, other.bgCardDark),
        bgCardDefault: l(bgCardDefault, other.bgCardDefault),
        borderCardDark: l(borderCardDark, other.borderCardDark),
        borderCardLight: l(borderCardLight, other.borderCardLight),
        txtDefault: l(txtDefault, other.txtDefault),
        txtBodyDark: l(txtBodyDark, other.txtBodyDark),
        txtBodyLight: l(txtBodyLight, other.txtBodyLight),
        txtBtnPrimary: l(txtBtnPrimary, other.txtBtnPrimary),
        txtBtnOutline: l(txtBtnOutline, other.txtBtnOutline),
        disabled: l(disabled, other.disabled),
        error: l(error, other.error),
        errorLight: l(errorLight, other.errorLight),
        positive: l(positive, other.positive),
        positiveLight: l(positiveLight, other.positiveLight),
        txtBtnSecondary: l(txtBtnSecondary, other.txtBtnSecondary),
        disabledLight: l(disabledLight, other.disabledLight),
        bgAppBar: l(bgAppBar, other.bgAppBar),
        bgDialog: l(bgDialog, other.bgDialog)
    );
  }
}