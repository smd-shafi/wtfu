import 'package:flutter_test/flutter_test.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';
import 'package:wtfu/features/alarm/data/models/alarm_history_model.dart';

void main() {
  group('AlarmModel tests', () {
    final now = DateTime.now();
    final model = AlarmModel(
      id: 1234,
      title: 'Wake Up Test',
      hour: 7,
      minute: 30,
      repeatDays: const [1, 3, 5],
      ringtonePath: 'assets/sounds/alarm_beep.wav',
      vibrationEnabled: true,
      isEnabled: true,
      createdAt: now,
    );

    test('toJson returns accurate map representation', () {
      final json = model.toJson();
      
      expect(json['id'], equals(1234));
      expect(json['title'], equals('Wake Up Test'));
      expect(json['hour'], equals(7));
      expect(json['minute'], equals(30));
      expect(json['repeatDays'], equals([1, 3, 5]));
      expect(json['ringtonePath'], equals('assets/sounds/alarm_beep.wav'));
      expect(json['vibrationEnabled'], isTrue);
      expect(json['isEnabled'], isTrue);
      expect(json['createdAt'], equals(now.toIso8601String()));
      expect(json['lastTriggeredAt'], isNull);
    });

    test('fromJson returns accurate model instantiation', () {
      final json = {
        'id': 1234,
        'title': 'Wake Up Test',
        'hour': 7,
        'minute': 30,
        'repeatDays': [1, 3, 5],
        'ringtonePath': 'assets/sounds/alarm_beep.wav',
        'vibrationEnabled': true,
        'isEnabled': true,
        'createdAt': now.toIso8601String(),
        'lastTriggeredAt': null,
      };

      final parsed = AlarmModel.fromJson(json);
      
      expect(parsed.id, equals(1234));
      expect(parsed.title, equals('Wake Up Test'));
      expect(parsed.hour, equals(7));
      expect(parsed.minute, equals(30));
      expect(parsed.repeatDays, equals([1, 3, 5]));
      expect(parsed.ringtonePath, equals('assets/sounds/alarm_beep.wav'));
      expect(parsed.vibrationEnabled, isTrue);
      expect(parsed.isEnabled, isTrue);
      expect(parsed.createdAt.toIso8601String(), equals(now.toIso8601String()));
      expect(parsed.lastTriggeredAt, isNull);
    });

    test('copyWith updates fields successfully', () {
      final modified = model.copyWith(
        title: 'New Title',
        isEnabled: false,
        lastTriggeredAt: now,
      );
      
      expect(modified.id, equals(model.id)); // Unchanged
      expect(modified.title, equals('New Title'));
      expect(modified.isEnabled, isFalse);
      expect(modified.lastTriggeredAt, equals(now));
    });
  });

  group('AlarmHistoryModel tests', () {
    final now = DateTime.now();
    final history = AlarmHistoryModel(
      id: 'history_id',
      alarmId: 1234,
      alarmTitle: 'Gym Alarm',
      eventTime: now,
      eventType: 'triggered',
    );

    test('toJson and fromJson cycle works correctly', () {
      final json = history.toJson();
      final parsed = AlarmHistoryModel.fromJson(json);
      
      expect(parsed.id, equals('history_id'));
      expect(parsed.alarmId, equals(1234));
      expect(parsed.alarmTitle, equals('Gym Alarm'));
      expect(parsed.eventTime.toIso8601String(), equals(now.toIso8601String()));
      expect(parsed.eventType, equals('triggered'));
    });
  });
}
