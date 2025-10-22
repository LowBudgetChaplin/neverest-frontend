import 'dart:ui';

extension ColorOpacity on Color {
  Color withOpacityPercent(double opacity) => withAlpha((opacity * 255).round());
}