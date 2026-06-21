import 'package:equatable/equatable.dart';

class AlarmEntity extends Equatable {
  final int id;
  final String title;
  final int hour;
  final int minute;
  final List<int> repeatDays; // 1 = Monday, 7 = Sunday, empty = one-time
  final String ringtonePath;
  final bool vibrationEnabled;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastTriggeredAt;

  const AlarmEntity({
    required this.id,
    required this.title,
    required this.hour,
    required this.minute,
    required this.repeatDays,
    required this.ringtonePath,
    required this.vibrationEnabled,
    required this.isEnabled,
    required this.createdAt,
    this.lastTriggeredAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        hour,
        minute,
        repeatDays,
        ringtonePath,
        vibrationEnabled,
        isEnabled,
        createdAt,
        lastTriggeredAt,
      ];
}
