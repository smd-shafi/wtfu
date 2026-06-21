import 'package:flutter_test/flutter_test.dart';
import 'package:wtfu/features/alarm/services/alarm_scheduler_service.dart';

void main() {
  late AlarmSchedulerService scheduler;

  setUp(() {
    scheduler = AlarmSchedulerService();
  });

  group('AlarmSchedulerService - calculateNextAlarmTime tests', () {
    test('One-time alarm in the future today should return today', () {
      final now = DateTime.now();
      // Schedule an alarm 1 hour in the future
      final targetTime = now.add(const Duration(hours: 1));
      
      final nextAlarm = scheduler.calculateNextAlarmTime(targetTime.hour, targetTime.minute, []);
      
      expect(nextAlarm.year, equals(now.year));
      expect(nextAlarm.month, equals(now.month));
      expect(nextAlarm.day, equals(now.day));
      expect(nextAlarm.hour, equals(targetTime.hour));
      expect(nextAlarm.minute, equals(targetTime.minute));
    });

    test('One-time alarm in the past today should return tomorrow', () {
      final now = DateTime.now();
      // Schedule an alarm 1 hour in the past
      final targetTime = now.subtract(const Duration(hours: 1));
      
      final nextAlarm = scheduler.calculateNextAlarmTime(targetTime.hour, targetTime.minute, []);
      
      final tomorrow = now.add(const Duration(days: 1));
      expect(nextAlarm.year, equals(tomorrow.year));
      expect(nextAlarm.month, equals(tomorrow.month));
      expect(nextAlarm.day, equals(tomorrow.day));
      expect(nextAlarm.hour, equals(targetTime.hour));
      expect(nextAlarm.minute, equals(targetTime.minute));
    });

    test('Recurring alarm scheduled for weekdays should find the correct candidate day', () {
      final now = DateTime.now();
      // Days: 1 (Mon) to 7 (Sun)
      // Suppose we only want weekdays: Monday through Friday
      final weekdays = [1, 2, 3, 4, 5];
      
      // Target time: 8 AM
      final nextAlarm = scheduler.calculateNextAlarmTime(8, 0, weekdays);
      
      // Verify that the computed date is indeed one of the weekdays
      expect(weekdays.contains(nextAlarm.weekday), isTrue);
      expect(nextAlarm.hour, equals(8));
      expect(nextAlarm.minute, equals(0));
      expect(nextAlarm.isAfter(now), isTrue);
    });

    test('Recurring alarm scheduled for weekends should find the correct candidate weekend day', () {
      final now = DateTime.now();
      final weekends = [6, 7]; // Saturday, Sunday
      
      final nextAlarm = scheduler.calculateNextAlarmTime(9, 30, weekends);
      
      expect(weekends.contains(nextAlarm.weekday), isTrue);
      expect(nextAlarm.hour, equals(9));
      expect(nextAlarm.minute, equals(30));
      expect(nextAlarm.isAfter(now), isTrue);
    });
  });
}
