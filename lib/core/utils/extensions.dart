import 'dart:ui';

/// It is the non-detracted version of 'withOpacity()' native function
extension ColorOpacity on Color {
  Color withOpacityPercent(double opacity) => withAlpha((opacity * 255).round());
}