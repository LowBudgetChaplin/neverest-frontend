import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neverest/resources/extensions/app_selectors.dart';
import 'package:neverest/resources/widgets/app_circular_progress_ring.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/dates.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _HomeContent();
  }
}

class _HomeContent extends ConsumerStatefulWidget {
  const _HomeContent();

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  var _stepsToday = 0;
  var _goal =
      10000;
  int?
      _baseLineAtMidnight;
  DateTime _day = DateTime.now();
  StreamSubscription<StepCount>? _subscription;

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  Future<void> _initPedometer() async {
    final status = await Permission.activityRecognition.request();
    if (!status.isGranted) {
      setState(() {
        _stepsToday = 2002;
        _goal = 10000;
      });
      return;
    }
    _subscription = Pedometer.stepCountStream
        .listen(_onStepEvent, onError: _onStepError, cancelOnError: false);
  }

  void _onStepEvent(StepCount event) {
    final now = DateTime.now();

    if (!isSameDay(now, _day)) {
      _day = DateTime(now.year, now.month, now.day);
      _baseLineAtMidnight = null;
      _stepsToday = 0;
    }

    final totalStepsSinceBoot = event.steps;
    _baseLineAtMidnight ??= totalStepsSinceBoot;

    final today = totalStepsSinceBoot - (_baseLineAtMidnight ?? 0);
    setState(() {
      _stepsToday = today
          .clamp(0, 1000000)
          .toInt();
    });
  }

  void _onStepError(Object error, [StackTrace? errorTrace]) {
    setState(() {
      _stepsToday =
          69669;
      _goal = 100001;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sp = context.spacing;
    final progress = (_stepsToday / _goal).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
          child: SingleChildScrollView(
        padding: EdgeInsets.only(top: sp.itemDefaultMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: sp.itemDefaultMargin),
              child: Center(
                child: AppCircularStepRing(
                  progress: progress,
                  color: c.primary,
                  trackColor: c.secondary,
                  center: AppRingCenter(
                    steps: _stepsToday,
                    goal: _goal,
                    points: (_stepsToday / 50)
                        .floor(),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
