import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neverest/core/utils/extensions.dart';
import 'package:neverest/resources/extensions/app_selectors.dart';
import 'package:neverest/resources/widgets/app_circular_progress_ring.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/dates.dart';

/// This is the screen where the user has access after login
/// It contains the user's progress, stats, active challenges, nearby rewards & friends activity
class HomeScreen extends ConsumerWidget{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _HomeContent();
  }
}

class _HomeContent extends ConsumerStatefulWidget{
  const _HomeContent();

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

//TODO: it should read a state render or smth after the fetch and continuously updating the stats
//TODO: discuss the proper business logic before starting integrating the backend/WS but until then lets pretend its working so small beak and play of ankles
class _HomeContentState extends ConsumerState<_HomeContent>{
  var _stepsToday = 0; // today's number of steps
  var _goal = 10000; // today's actual step goal //TODO: only for mock. fetch the goal from API
  int? _baseLineAtMidnight; // the cumulative no. of steps at first data reading of the day
  DateTime _day = DateTime.now(); // current date for midnight reset
  StreamSubscription<StepCount>? _subscription; // steps counter listener


  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  // initializing the step counter listener which will determine the actual no. of steps
  Future<void> _initPedometer() async {
    final status = await Permission.activityRecognition.request();
    if(!status.isGranted){
      setState(() {
        _stepsToday = 2002; // TODO: only for mock
        _goal = 10000;
      });
      return;
    }
    _subscription = Pedometer.stepCountStream.listen(_onStepEvent, onError: _onStepError, cancelOnError: false);
  }

  // event listener for step counter and steps reset
  void _onStepEvent(StepCount event){
    final now = DateTime.now();

    if(!isSameDay(now, _day)){
      _day = DateTime(now.year, now.month, now.day);
      _baseLineAtMidnight = null;
      _stepsToday = 0;
    }

    final totalStepsSinceBoot = event.steps;
    _baseLineAtMidnight ??= totalStepsSinceBoot;

    final today = totalStepsSinceBoot - (_baseLineAtMidnight ?? 0);
    setState(() {
      _stepsToday = today.clamp(0, 1000000).toInt(); // arbitrary range. maybe we change it in the future
    });
  }

  // fallback when the sensor is not available
  void _onStepError(Object error, [StackTrace? errorTrace]){
    setState(() {
      _stepsToday = 69669; //TODO: only for mock. probably the fallback will be 0 and 0 in to the future
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
    final progress = (_stepsToday/_goal).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(), //TODO: change it after merge
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
                        points: (_stepsToday/50).floor(), //TODO: for mock only 1pct per 50 steps
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }


}