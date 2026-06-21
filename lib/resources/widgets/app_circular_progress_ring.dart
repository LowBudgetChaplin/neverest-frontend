import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:neverest/core/utils/extensions.dart';

import '../../core/utils/number_formats.dart';
import '../styles_managers/font_manager.dart';
import '../styles_managers/styles_manager.dart';

/// Circular progress 'bar' (used in home screen)
class AppCircularStepRing extends StatefulWidget{
  final double progress;
  final Duration duration;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  final Widget? center;

  const AppCircularStepRing({
    super.key,
    required this.progress,
    this.duration = const Duration(milliseconds: 1200),
    this.size = 200,
    this.strokeWidth = 12,
    required this.color,
    required this.trackColor,
    this.center,
  });

  @override
  State<AppCircularStepRing> createState() => _AppCircularStepRingState();
}

class _AppCircularStepRingState extends State<AppCircularStepRing> with SingleTickerProviderStateMixin{
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    initControllers();
  }

  void initControllers(){
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward(from: 0);
  }

  @override
  void didUpdateWidget(AppCircularStepRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.progress != widget.progress || oldWidget.duration != widget.duration){
      _controller.duration = widget.duration;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
          animation: _animation,
          builder: (_, __) {
            final value = (_animation.value * widget.progress).clamp(0.0, 1.0);
            return Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.square(widget.size),
                  painter: AppRingPainter(
                    progress: value,
                    strokeWidth: widget.strokeWidth,
                    color: widget.color,
                    trackColor: widget.trackColor,
                  ),
                ),
                if(widget.center != null) widget.center!,
              ],
            );
          }
      )
    );
  }
}

class AppRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  
  AppRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor
});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor.withOpacityPercent(0.25);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    canvas.drawCircle(center, radius, track);
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    final rectArc = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rectArc, startAngle, sweepAngle, false, ring);
  }

  @override
  bool shouldRepaint(covariant AppRingPainter old) =>
    old.progress != progress ||
    old.strokeWidth != strokeWidth ||
    old.color != color ||
    old.trackColor != trackColor;
}

class AppRingCenter extends StatelessWidget {
  final int steps;
  final int goal;
  final int points;

  const AppRingCenter({
    super.key,
    required this.steps,
    required this.goal,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final stepsStyle = getTitleHeader2Style(
      context: context,
      fontWeight: FontWeightManager.bold,
    );

    final ofStyle = getBodyMediumStyle(
      context: context,
      color: c.txtDefault.withOpacityPercent(0.6),
    );

    final pointsStyle = getBodySmallStyle(
      context: context,
      fontWeight: FontWeightManager.semibold,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(manualFormatingWithSpace(steps), style: stepsStyle),
        const SizedBox(height: 4),
        Text('of ${manualFormatingWithSpace(goal)}', style: ofStyle),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: c.primary.withOpacityPercent(0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: c.primary.withOpacityPercent(0.40)),
          ),
          child: Text('+$points pts', style: pointsStyle),
        ),
      ],
    );
  }
}