import 'package:alarm/alarm.dart';
import 'package:wtfu/core/logger/app_logger.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';

class AlarmSchedulerService {
  Future<void> scheduleAlarm(AlarmModel alarm) async {
    try {
      final nextTime = calculateNextAlarmTime(alarm.hour, alarm.minute, alarm.repeatDays);
      
      final alarmSettings = AlarmSettings(
        id: alarm.id,
        dateTime: nextTime,
        assetAudioPath: alarm.ringtonePath,
        loopAudio: true,
        vibrate: alarm.vibrationEnabled,
        volumeSettings: VolumeSettings.fixed(),
        androidFullScreenIntent: true,
        notificationSettings: NotificationSettings(
          title: alarm.title.isNotEmpty ? alarm.title : 'Alarm',
          body: 'It is ${_formatTime(alarm.hour, alarm.minute)}. Time to wake up!',
          stopButton: 'Stop Alarm',
        ),
      );

      await Alarm.set(alarmSettings: alarmSettings);
      AppLogger.info('Successfully scheduled alarm ${alarm.id} for $nextTime (Title: ${alarm.title})');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to schedule alarm ${alarm.id}', e, stackTrace);
      rethrow;
    }
  }

  Future<void> cancelAlarm(int id) async {
    try {
      await Alarm.stop(id);
      AppLogger.info('Successfully cancelled alarm scheduling for ID $id');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cancel alarm $id', e, stackTrace);
      rethrow;
    }
  }

  Future<void> rescheduleAllActiveAlarms(List<AlarmModel> alarms) async {
    try {
      // Clear all scheduled ones first to prevent overlap/zombies
      for (final alarm in alarms) {
        await Alarm.stop(alarm.id);
      }
      
      // Schedule only the enabled ones
      for (final alarm in alarms) {
        if (alarm.isEnabled) {
          await scheduleAlarm(alarm);
        }
      }
      AppLogger.info('Rescheduled all active alarms (${alarms.where((a) => a.isEnabled).length} alarms)');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to reschedule active alarms', e, stackTrace);
    }
  }

  /// Calculates the next occurrence of an alarm.
  /// [repeatDays] contains integers from 1 (Monday) to 7 (Sunday).
  /// If [repeatDays] is empty, it calculates for the next occurrence today or tomorrow.
  DateTime calculateNextAlarmTime(int hour, int minute, List<int> repeatDays) {
    final now = DateTime.now();
    
    if (repeatDays.isEmpty) {
      // One-time alarm: target today or tomorrow
      final candidate = DateTime(now.year, now.month, now.day, hour, minute);
      if (candidate.isAfter(now)) {
        return candidate;
      } else {
        return candidate.add(const Duration(days: 1));
      }
    } else {
      // Recurring alarm: find nearest candidate day including today
      DateTime? closestDateTime;
      
      for (int i = 0; i < 7; i++) {
        final candidateDate = now.add(Duration(days: i));
        final weekday = candidateDate.weekday; // Monday = 1, Sunday = 7
        
        if (repeatDays.contains(weekday)) {
          final candidateTime = DateTime(
            candidateDate.year,
            candidateDate.month,
            candidateDate.day,
            hour,
            minute,
          );
          
          if (candidateTime.isAfter(now)) {
            closestDateTime = candidateTime;
            break;
          }
        }
      }
      
      // Fallback (e.g. if time has passed today and next scheduled day is today next week)
      if (closestDateTime == null) {
        // Find next day in the list starting next week
        for (int i = 7; i < 14; i++) {
          final candidateDate = now.add(Duration(days: i));
          final weekday = candidateDate.weekday;
          
          if (repeatDays.contains(weekday)) {
            closestDateTime = DateTime(
              candidateDate.year,
              candidateDate.month,
              candidateDate.day,
              hour,
              minute,
            );
            break;
          }
        }
      }
      
      return closestDateTime ?? DateTime(now.year, now.month, now.day, hour, minute).add(const Duration(days: 1));
    }
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}
