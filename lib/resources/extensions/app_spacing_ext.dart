import 'dart:ui';
import 'package:flutter/material.dart';

/// Keeps spacing consistent and enables smooth theme transitions (copyWith/lerp)
@immutable
class AppSpacingExt extends ThemeExtension<AppSpacingExt> {
  final EdgeInsets screenPadding;
  final EdgeInsets cardPadding;
  final double itemListMediumMarginHorizontal;
  final double itemDefaultMargin;
  final double tabLabelPaddingVertical;
  final double tabLabelPaddingHorizontal;
  final double titleDescSpacingVertical;
  final double smallMarginVertical;
  final double leadIconMarginHorizontal;
  final double itemListMediumMarginVertical;
  final double textFieldPaddingVertical;
  final double textFieldPaddingHorizontal;
  final double labelSmallPaddingVertical;
  final double labelSmallPaddingHorizontal;
  final double itemLargeMarginVertical;

  const AppSpacingExt({
    required this.screenPadding,
    required this.cardPadding,
    required this.itemListMediumMarginHorizontal,
    required this.itemDefaultMargin,
    required this.tabLabelPaddingHorizontal,
    required this.tabLabelPaddingVertical,
    required this.titleDescSpacingVertical,
    required this.smallMarginVertical,
    required this.leadIconMarginHorizontal,
    required this.itemListMediumMarginVertical,
    required this.textFieldPaddingVertical,
    required this.textFieldPaddingHorizontal,
    required this.labelSmallPaddingVertical,
    required this.labelSmallPaddingHorizontal,
    required this.itemLargeMarginVertical,
  });

  @override
  AppSpacingExt copyWith({
    EdgeInsets? screenPadding,
    EdgeInsets? cardPadding,
    double? itemListMediumMarginHorizontal,
    double? itemDefaultMargin,
    double? tabLabelPaddingVertical,
    double? tabLabelPaddingHorizontal,
    double? titleDescSpacingVertical,
    double? smallMarginVertical,
    double? leadIconMarginHorizontal,
    double? itemListMediumMarginVertical,
    double? textFieldPaddingVertical,
    double? textFieldPaddingHorizontal,
    double? labelSmallPaddingVertical,
    double? labelSmallPaddingHorizontal,
    double? itemLargeMarginVertical
  }) {
    return AppSpacingExt(
      screenPadding: screenPadding ?? this.screenPadding,
      cardPadding: cardPadding ?? this.cardPadding,
      itemListMediumMarginHorizontal: itemListMediumMarginHorizontal ?? this.itemListMediumMarginHorizontal,
      itemDefaultMargin: itemDefaultMargin ?? this.itemDefaultMargin,
      tabLabelPaddingVertical: tabLabelPaddingVertical ?? this.tabLabelPaddingVertical,
      tabLabelPaddingHorizontal: tabLabelPaddingHorizontal ?? this.tabLabelPaddingHorizontal,
      titleDescSpacingVertical: titleDescSpacingVertical ?? this.titleDescSpacingVertical,
      smallMarginVertical: smallMarginVertical ?? this.smallMarginVertical,
      leadIconMarginHorizontal: leadIconMarginHorizontal ?? this.leadIconMarginHorizontal,
      itemListMediumMarginVertical: itemListMediumMarginVertical ?? this.itemListMediumMarginVertical,
      textFieldPaddingVertical: textFieldPaddingVertical ?? this.textFieldPaddingVertical,
      textFieldPaddingHorizontal: textFieldPaddingHorizontal ?? this.textFieldPaddingHorizontal,
      labelSmallPaddingVertical: labelSmallPaddingVertical ?? this.labelSmallPaddingVertical,
      labelSmallPaddingHorizontal: labelSmallPaddingHorizontal ?? this.labelSmallPaddingHorizontal,
      itemLargeMarginVertical: itemLargeMarginVertical ?? this.itemLargeMarginVertical,
    );
  }

  @override
  AppSpacingExt lerp(ThemeExtension<AppSpacingExt>? other, double t) {
    if (other is! AppSpacingExt) return this;
    return AppSpacingExt(
      screenPadding: EdgeInsets.lerp(screenPadding, other.screenPadding, t)!,
      cardPadding: EdgeInsets.lerp(cardPadding, other.cardPadding, t)!,
      itemListMediumMarginHorizontal: lerpDouble(itemListMediumMarginHorizontal, other.itemListMediumMarginHorizontal, t)!,
      itemDefaultMargin: lerpDouble(itemDefaultMargin, other.itemDefaultMargin, t)!,
      tabLabelPaddingVertical: lerpDouble(tabLabelPaddingVertical, other.tabLabelPaddingVertical, t)!,
      tabLabelPaddingHorizontal: lerpDouble(tabLabelPaddingHorizontal, other.tabLabelPaddingHorizontal, t)!,
      titleDescSpacingVertical: lerpDouble(titleDescSpacingVertical, other.titleDescSpacingVertical, t)!,
      smallMarginVertical: lerpDouble(smallMarginVertical, other.smallMarginVertical, t)!,
      leadIconMarginHorizontal: lerpDouble(leadIconMarginHorizontal, other.leadIconMarginHorizontal, t)!,
      itemListMediumMarginVertical: lerpDouble(itemListMediumMarginVertical, other.itemListMediumMarginVertical, t)!,
      textFieldPaddingVertical: lerpDouble(textFieldPaddingVertical, other.textFieldPaddingVertical, t)!,
      textFieldPaddingHorizontal: lerpDouble(textFieldPaddingHorizontal, other.textFieldPaddingHorizontal, t)!,
      labelSmallPaddingVertical: lerpDouble(labelSmallPaddingVertical, other.labelSmallPaddingVertical, t)!,
      labelSmallPaddingHorizontal: lerpDouble(labelSmallPaddingHorizontal, other.labelSmallPaddingHorizontal, t)!,
      itemLargeMarginVertical: lerpDouble(itemLargeMarginVertical, other.itemLargeMarginVertical, t)!,
    );
  }
}