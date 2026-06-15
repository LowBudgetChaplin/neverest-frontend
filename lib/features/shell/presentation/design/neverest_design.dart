import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class NeverestPalette {
  static const Color orange = Color(0xFFFF5A1F);
  static const Color orangeSoft = Color(0xFFFFE2D2);
  static const Color ink = Color(0xFF0A0A0B);
  static const Color inkRaised = Color(0xFF161618);
  static const Color inkLine = Color(0xFF26262A);
  static const Color inkMuted = Color(0xFF8B8B92);
  static const Color paper = Color(0xFFFAFAF7);
  static const Color paperRaised = Color(0xFFFFFFFF);
  static const Color paperLine = Color(0xFFE8E6DF);
  static const Color paperMuted = Color(0xFF6E6E72);
  static const Color success = Color(0xFF2EBD6B);
  static const Color danger = Color(0xFFE5484D);
  static const Color running = orange;
  static const Color padel = Color(0xFF7C5CFF);
  static const Color mountain = Color(0xFF2EBD6B);
}

Color neverestActivityColor(String activityType) {
  switch (activityType.toUpperCase()) {
    case 'PADEL':
      return NeverestPalette.padel;
    case 'MOUNTAIN':
      return NeverestPalette.mountain;
    case 'RUNNING':
    default:
      return NeverestPalette.running;
  }
}

class NeverestLogo extends StatelessWidget {
  const NeverestLogo({
    super.key,
    this.compact = false,
    this.foreground,
  });

  final bool compact;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final color = foreground ?? Theme.of(context).colorScheme.onSurface;
    final fontSize = compact ? 16.0 : 20.0;
    final markSize = compact ? 26.0 : 34.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/nvr_logo.png',
          width: markSize,
          height: markSize,
          // logo-ul e alb → pe temă deschisă îl colorăm în culoarea textului
          color: isDark ? null : color,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.terrain_rounded, color: color, size: compact ? 20 : 24),
        ),
        const SizedBox(width: 8),
        Text(
          'NEVEREST',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                color: color,
              ),
        ),
      ],
    );
  }
}

class NeverestGlassIconButton extends StatelessWidget {
  const NeverestGlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.background,
    this.foreground,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: background ??
          (isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.04)),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            size: 19,
            color: foreground ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class NeverestSectionHeader extends StatelessWidget {
  const NeverestSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class NeverestFilterChip extends StatelessWidget {
  const NeverestFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.icon,
    this.onTap,
  });

  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = selected
        ? Theme.of(context).colorScheme.onSurface
        : (isDark ? NeverestPalette.inkRaised : NeverestPalette.paperRaised);
    final fg = selected
        ? Theme.of(context).colorScheme.surface
        : Theme.of(context).colorScheme.onSurface;
    final border = selected
        ? Theme.of(context).colorScheme.onSurface
        : (isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine);

    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fg,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeverestProgressBar extends StatelessWidget {
  const NeverestProgressBar({
    super.key,
    required this.value,
    this.height = 6,
  });

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: isDark ? NeverestPalette.inkLine : NeverestPalette.paperLine,
            ),
            FractionallySizedBox(
              widthFactor: clamped,
              alignment: Alignment.centerLeft,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: NeverestPalette.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeverestAvatar extends StatelessWidget {
  const NeverestAvatar({
    super.key,
    required this.name,
    this.size = 34,
    this.imageB64,
  });

  final String name;
  final double size;
  /// Optional base64-encoded image (JPEG/PNG). When set, shown instead of initials.
  final String? imageB64;

  @override
  Widget build(BuildContext context) {
    // If we have a photo, show it
    if (imageB64 != null && imageB64!.isNotEmpty) {
      try {
        // Strip data URI prefix if present
        final raw = imageB64!.contains(',') ? imageB64!.split(',').last : imageB64!;
        final bytes = base64Decode(raw);
        return ClipOval(
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialsWidget(context),
          ),
        );
      } catch (_) {
        // Fall through to initials
      }
    }
    return _initialsWidget(context);
  }

  Widget _initialsWidget(BuildContext context) {
    final initials = _initials(name);
    final seed = name.runes.fold<int>(13, (value, rune) => value + rune);
    final hue = (seed % 360).toDouble();
    final background = HSLColor.fromAHSL(1, hue, 0.45, 0.55).toColor();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.32,
            ),
      ),
    );
  }

  String _initials(String text) {
    final parts = text
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

/// Imaginea unei recompense: foloseste poza base64 daca exista, altfel afiseaza
/// arta default (cercurile topografice) peste [fallbackColor].
class NeverestRewardImage extends StatelessWidget {
  const NeverestRewardImage({
    super.key,
    required this.imageB64,
    required this.fallbackColor,
    this.ringCount = 8,
  });

  final String? imageB64;
  final Color fallbackColor;
  final int ringCount;

  @override
  Widget build(BuildContext context) {
    if (imageB64 != null && imageB64!.isNotEmpty) {
      try {
        final raw =
            imageB64!.contains(',') ? imageB64!.split(',').last : imageB64!;
        final bytes = base64Decode(raw);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _fallback(),
        );
      } catch (_) {
        // Fall through to default art.
      }
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      color: fallbackColor,
      child: NeverestTopographicRings(color: Colors.white, count: ringCount),
    );
  }
}

class NeverestTopographicLines extends StatelessWidget {
  const NeverestTopographicLines({
    super.key,
    required this.color,
    this.density = 12,
    this.opacity = 0.55,
    this.withPeak = true,
  });

  final Color color;
  final int density;
  final double opacity;
  final bool withPeak;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TopographicLinesPainter(
        color: color,
        density: density,
        opacity: opacity,
        withPeak: withPeak,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _TopographicLinesPainter extends CustomPainter {
  _TopographicLinesPainter({
    required this.color,
    required this.density,
    required this.opacity,
    required this.withPeak,
  });

  final Color color;
  final int density;
  final double opacity;
  final bool withPeak;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final steps = 24;

    for (var i = 0; i < density; i++) {
      final path = Path();
      final t = density <= 1 ? 0.0 : i / (density - 1);
      final yShift = -i * (size.height / 26);
      final amp = 18 + i * 6;
      final peakHeight = withPeak ? 26 + i * 4 : 0;
      path.moveTo(0, size.height * 0.7 + yShift);
      for (var step = 1; step <= steps; step++) {
        final x = size.width * (step / steps);
        final center = x - size.width / 2;
        final gaussian = math.exp(-math.pow(center / (size.width * 0.12), 2));
        final peakBoost = peakHeight * gaussian;
        final wave =
            math.sin((step / steps) * math.pi * 3 + i * 0.4) * (amp / 8);
        final y = size.height * 0.7 + yShift - peakBoost + wave;
        path.lineTo(x, y);
      }
      paint.color = color.withOpacity(opacity * (1 - t * 0.5));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TopographicLinesPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.density != density ||
        oldDelegate.opacity != opacity ||
        oldDelegate.withPeak != withPeak;
  }
}

class NeverestTopographicRings extends StatelessWidget {
  const NeverestTopographicRings({
    super.key,
    required this.color,
    this.count = 8,
    this.opacity = 0.65,
  });

  final Color color;
  final int count;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TopographicRingsPainter(
        color: color,
        count: count,
        opacity: opacity,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _TopographicRingsPainter extends CustomPainter {
  _TopographicRingsPainter({
    required this.color,
    required this.count,
    required this.opacity,
  });

  final Color color;
  final int count;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.45;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (var i = 0; i < count; i++) {
      final t = i / count;
      final radius = maxRadius * (0.2 + t);
      paint.color = color.withOpacity(opacity * (1 - t * 0.8));
      final rect = Rect.fromCenter(
        center: center,
        width: radius * 2,
        height: radius * 1.45,
      );
      canvas.drawOval(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TopographicRingsPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.count != count ||
        oldDelegate.opacity != opacity;
  }
}

class NeverestMapMock extends StatelessWidget {
  const NeverestMapMock({
    super.key,
    required this.progress,
    required this.dark,
  });

  final double progress;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NeverestMapPainter(
        progress: progress.clamp(0.0, 1.0),
        dark: dark,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _NeverestMapPainter extends CustomPainter {
  _NeverestMapPainter({
    required this.progress,
    required this.dark,
  });

  final double progress;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..style = PaintingStyle.fill
      ..color = dark ? const Color(0xFF0D1117) : const Color(0xFFE8E4D8);
    canvas.drawRect(Offset.zero & size, bg);

    final roadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = dark ? const Color(0xFF353B46) : const Color(0xFFC8C1AE)
      ..strokeWidth = 4;
    final minorRoadPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = dark ? const Color(0xFF252B35) : const Color(0xFFD8D1C1)
      ..strokeWidth = 2;

    void road(List<Offset> points, Paint paint) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }

    road([
      Offset(0, size.height * 0.32),
      Offset(size.width, size.height * 0.28),
    ], roadPaint);
    road([
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.54, size.height),
    ], roadPaint);
    road([
      Offset(0, size.height * 0.15),
      Offset(size.width, size.height * 0.13),
    ], minorRoadPaint);
    road([
      Offset(0, size.height * 0.74),
      Offset(size.width, size.height * 0.7),
    ], minorRoadPaint);
    road([
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.25, size.height),
    ], minorRoadPaint);
    road([
      Offset(size.width * 0.8, 0),
      Offset(size.width * 0.84, size.height),
    ], minorRoadPaint);

    final route = Path()
      ..moveTo(size.width * 0.18, size.height * 0.84)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.72,
        size.width * 0.38,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.46,
        size.height * 0.48,
        size.width * 0.58,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.3,
        size.width * 0.82,
        size.height * 0.2,
      );
    final routeMetrics = route.computeMetrics().toList();
    final routeLength = routeMetrics.fold<double>(
      0,
      (total, metric) => total + metric.length,
    );
    final completed = routeLength * (0.25 + progress * 0.45);
    final donePath = Path();
    var consumed = 0.0;
    for (final metric in routeMetrics) {
      final remaining = completed - consumed;
      if (remaining <= 0) {
        break;
      }
      final segment = metric.extractPath(0, math.min(metric.length, remaining));
      donePath.addPath(segment, Offset.zero);
      consumed += metric.length;
    }

    canvas.drawPath(
      route,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..color = NeverestPalette.orange.withOpacity(0.45),
    );
    canvas.drawPath(
      donePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..color = NeverestPalette.orange,
    );

    final start = Offset(size.width * 0.18, size.height * 0.84);
    final end = Offset(size.width * 0.82, size.height * 0.2);
    final live = Offset(
      start.dx + (end.dx - start.dx) * (0.25 + progress * 0.45),
      start.dy + (end.dy - start.dy) * (0.25 + progress * 0.45),
    );

    canvas.drawCircle(
      start,
      7,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      start,
      4,
      Paint()..color = NeverestPalette.ink,
    );
    canvas.drawCircle(
      end,
      9,
      Paint()..color = NeverestPalette.orange,
    );
    canvas.drawCircle(
      end,
      3.5,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      live,
      13,
      Paint()..color = NeverestPalette.orange.withOpacity(0.25),
    );
    canvas.drawCircle(
      live,
      6.5,
      Paint()..color = NeverestPalette.orange,
    );
    canvas.drawCircle(
      live,
      3.2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _NeverestMapPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.dark != dark;
  }
}

String neverestCompactNumber(num value) {
  if (value.abs() < 1000) {
    return value.toStringAsFixed(value is int ? 0 : 1);
  }
  if (value.abs() < 1000000) {
    return '${(value / 1000).toStringAsFixed(1)}k';
  }
  return '${(value / 1000000).toStringAsFixed(1)}m';
}
