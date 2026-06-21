import 'package:equatable/equatable.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';
import 'package:wtfu/features/alarm/data/models/alarm_history_model.dart';

enum AlarmStatus { initial, loading, success, failure }

class AlarmState extends Equatable {
  final AlarmStatus status;
  final List<AlarmModel> alarms;
  final List<AlarmHistoryModel> history;
  final AlarmModel? ringingAlarm;
  final bool darkMode;
  final bool use24HourFormat;
  final String defaultRingtone;
  final bool defaultVibration;
  final String? errorMessage;

  const AlarmState({
    this.status = AlarmStatus.initial,
    this.alarms = const [],
    this.history = const [],
    this.ringingAlarm,
    this.darkMode = true,
    this.use24HourFormat = false,
    this.defaultRingtone = 'assets/sounds/alarm_beep.wav',
    this.defaultVibration = true,
    this.errorMessage,
  });

  AlarmState copyWith({
    AlarmStatus? status,
    List<AlarmModel>? alarms,
    List<AlarmHistoryModel>? history,
    AlarmModel? Function()? ringingAlarm,
    bool? darkMode,
    bool? use24HourFormat,
    String? defaultRingtone,
    bool? defaultVibration,
    String? Function()? errorMessage,
  }) {
    return AlarmState(
      status: status ?? this.status,
      alarms: alarms ?? this.alarms,
      history: history ?? this.history,
      ringingAlarm: ringingAlarm != null ? ringingAlarm() : this.ringingAlarm,
      darkMode: darkMode ?? this.darkMode,
      use24HourFormat: use24HourFormat ?? this.use24HourFormat,
      defaultRingtone: defaultRingtone ?? this.defaultRingtone,
      defaultVibration: defaultVibration ?? this.defaultVibration,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        alarms,
        history,
        ringingAlarm,
        darkMode,
        use24HourFormat,
        defaultRingtone,
        defaultVibration,
        errorMessage,
      ];
}
