import 'package:flutter/material.dart';

import 'app_colors_ext.dart';
import 'app_shapes_ext.dart';
import 'app_spacing_ext.dart';

/// Adds convenient getters on `BuildContext` to access your ThemeExtensions without boilerplate
/// Ex:
///   Instead of: Theme.of(context).extension<AppColorsExt>()!;
///   Write: context.colors.
///
/// Provided selectors
/// - context.colors  → AppColorsExt   (brand, backgrounds, text, states)
/// - context.shapes  → AppShapesExt   (radius, elevation, sheet geometry)
/// - context.spacing → AppSpacingExt  (paddings, margins, gaps)
extension AppSelectors on BuildContext {
  AppColorsExt get colors => Theme.of(this).extension<AppColorsExt>()!;
  AppShapesExt get shapes => Theme.of(this).extension<AppShapesExt>()!;
  AppSpacingExt get spacing => Theme.of(this).extension<AppSpacingExt>()!;
}