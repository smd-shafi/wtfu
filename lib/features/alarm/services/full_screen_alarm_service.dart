import 'package:flutter/material.dart';
import 'package:wtfu/core/logger/app_logger.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';
import 'package:wtfu/features/alarm/presentation/screens/full_screen_alarm_screen.dart';

class FullScreenAlarmService {
  final GlobalKey<NavigatorState> navigatorKey;
  bool _isShowing = false;

  FullScreenAlarmService(this.navigatorKey);

  bool get isShowing => _isShowing;

  void show(AlarmModel alarm) {
    if (_isShowing) {
      AppLogger.info('FullScreenAlarmOverlay is already active. Skipping duplicate navigation.');
      return;
    }
    _isShowing = true;
    AppLogger.info('Pushing FullScreenAlarmOverlay for alarm ID: ${alarm.id}');

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => FullScreenAlarmScreen(alarm: alarm),
        settings: const RouteSettings(name: '/full_screen_alarm'),
      ),
    ).then((_) {
      _isShowing = false;
      AppLogger.info('FullScreenAlarmOverlay popped.');
    });
  }

  void dismiss() {
    if (_isShowing) {
      AppLogger.info('Dismissing FullScreenAlarmOverlay.');
      navigatorKey.currentState?.pop();
      _isShowing = false;
    } else {
      AppLogger.debug('Attempted to dismiss FullScreenAlarmOverlay, but it was not showing.');
    }
  }
}
