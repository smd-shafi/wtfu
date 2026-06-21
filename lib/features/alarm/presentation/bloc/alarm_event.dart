import 'package:equatable/equatable.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';

abstract class AlarmEvent extends Equatable {
  const AlarmEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlarmsEvent extends AlarmEvent {}

class AddAlarmEvent extends AlarmEvent {
  final String title;
  final int hour;
  final int minute;
  final List<int> repeatDays;
  final String ringtonePath;
  final bool vibrationEnabled;

  const AddAlarmEvent({
    required this.title,
    required this.hour,
    required this.minute,
    required this.repeatDays,
    required this.ringtonePath,
    required this.vibrationEnabled,
  });

  @override
  List<Object?> get props => [title, hour, minute, repeatDays, ringtonePath, vibrationEnabled];
}

class UpdateAlarmEvent extends AlarmEvent {
  final AlarmModel alarm;

  const UpdateAlarmEvent(this.alarm);

  @override
  List<Object?> get props => [alarm];
}

class DeleteAlarmEvent extends AlarmEvent {
  final int id;

  const DeleteAlarmEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleAlarmEvent extends AlarmEvent {
  final int id;
  final bool isEnabled;

  const ToggleAlarmEvent(this.id, this.isEnabled);

  @override
  List<Object?> get props => [id, isEnabled];
}

class StopAlarmEvent extends AlarmEvent {
  final int id;

  const StopAlarmEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class AlarmTriggeredEvent extends AlarmEvent {
  final int id;

  const AlarmTriggeredEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearHistoryEvent extends AlarmEvent {}

class UpdateSettingsEvent extends AlarmEvent {
  final bool darkMode;
  final bool use24HourFormat;
  final String defaultRingtone;
  final bool defaultVibration;

  const UpdateSettingsEvent({
    required this.darkMode,
    required this.use24HourFormat,
    required this.defaultRingtone,
    required this.defaultVibration,
  });

  @override
  List<Object?> get props => [darkMode, use24HourFormat, defaultRingtone, defaultVibration];
}
