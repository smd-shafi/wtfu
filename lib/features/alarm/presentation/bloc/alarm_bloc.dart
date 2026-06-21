import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wtfu/core/logger/app_logger.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';
import 'package:wtfu/features/alarm/data/models/alarm_history_model.dart';
import 'package:wtfu/features/alarm/domain/repos/alarm_repo.dart';
import 'package:wtfu/features/alarm/services/alarm_scheduler_service.dart';
import 'package:wtfu/features/alarm/services/full_screen_alarm_service.dart';
import 'package:wtfu/features/alarm/services/notification_service.dart';
import 'alarm_event.dart';
import 'alarm_state.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  final AlarmRepo repo;
  final AlarmSchedulerService scheduler;
  final FullScreenAlarmService fullScreenService;
  final NotificationService notificationService;
  
  StreamSubscription<AlarmSettings>? _ringSubscription;

  AlarmBloc({
    required this.repo,
    required this.scheduler,
    required this.fullScreenService,
    required this.notificationService,
  }) : super(const AlarmState()) {
    on<LoadAlarmsEvent>(_onLoadAlarms);
    on<AddAlarmEvent>(_onAddAlarm);
    on<UpdateAlarmEvent>(_onUpdateAlarm);
    on<DeleteAlarmEvent>(_onDeleteAlarm);
    on<ToggleAlarmEvent>(_onToggleAlarm);
    on<AlarmTriggeredEvent>(_onAlarmTriggered);
    on<StopAlarmEvent>(_onStopAlarm);
    on<ClearHistoryEvent>(_onClearHistory);
    on<UpdateSettingsEvent>(_onUpdateSettings);

    // Register alarm ringing stream subscription
    _ringSubscription = Alarm.ringStream.stream.listen((alarmSettings) {
      AppLogger.info('Alarm.ringStream emitted event for alarm ID: ${alarmSettings.id}');
      add(AlarmTriggeredEvent(alarmSettings.id));
    });
  }

  @override
  Future<void> close() {
    _ringSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadAlarms(LoadAlarmsEvent event, Emitter<AlarmState> emit) async {
    emit(state.copyWith(status: AlarmStatus.loading));
    try {
      final alarms = repo.getAlarms();
      final history = repo.getHistory();
      final darkMode = repo.isDarkMode();
      final use24Hour = repo.use24HourFormat();
      final defaultRingtone = repo.getDefaultRingtone();
      final defaultVibration = repo.getDefaultVibration();

      // Ensure active alarms are scheduled
      await scheduler.rescheduleAllActiveAlarms(alarms);

      emit(state.copyWith(
        status: AlarmStatus.success,
        alarms: alarms,
        history: history,
        darkMode: darkMode,
        use24HourFormat: use24Hour,
        defaultRingtone: defaultRingtone,
        defaultVibration: defaultVibration,
      ));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load alarms state in Bloc', e, stackTrace);
      emit(state.copyWith(status: AlarmStatus.failure, errorMessage: () => e.toString()));
    }
  }

  Future<void> _onAddAlarm(AddAlarmEvent event, Emitter<AlarmState> emit) async {
    try {
      // Check permissions first
      await notificationService.requestPermissions();
      
      final id = DateTime.now().millisecondsSinceEpoch % 100000;
      final alarm = AlarmModel(
        id: id,
        title: event.title,
        hour: event.hour,
        minute: event.minute,
        repeatDays: event.repeatDays,
        ringtonePath: event.ringtonePath,
        vibrationEnabled: event.vibrationEnabled,
        isEnabled: true,
        createdAt: DateTime.now(),
      );

      await repo.saveAlarm(alarm);
      add(LoadAlarmsEvent());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add alarm in Bloc', e, stackTrace);
      emit(state.copyWith(status: AlarmStatus.failure, errorMessage: () => e.toString()));
    }
  }

  Future<void> _onUpdateAlarm(UpdateAlarmEvent event, Emitter<AlarmState> emit) async {
    try {
      await repo.saveAlarm(event.alarm);
      add(LoadAlarmsEvent());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update alarm in Bloc', e, stackTrace);
      emit(state.copyWith(status: AlarmStatus.failure, errorMessage: () => e.toString()));
    }
  }

  Future<void> _onDeleteAlarm(DeleteAlarmEvent event, Emitter<AlarmState> emit) async {
    try {
      await repo.deleteAlarm(event.id);
      add(LoadAlarmsEvent());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete alarm in Bloc', e, stackTrace);
      emit(state.copyWith(status: AlarmStatus.failure, errorMessage: () => e.toString()));
    }
  }

  Future<void> _onToggleAlarm(ToggleAlarmEvent event, Emitter<AlarmState> emit) async {
    try {
      await repo.toggleAlarm(event.id, event.isEnabled);
      add(LoadAlarmsEvent());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle alarm in Bloc', e, stackTrace);
      emit(state.copyWith(status: AlarmStatus.failure, errorMessage: () => e.toString()));
    }
  }

  Future<void> _onAlarmTriggered(AlarmTriggeredEvent event, Emitter<AlarmState> emit) async {
    try {
      // Find the triggered alarm from local list or load from repo
      final alarms = repo.getAlarms();
      final alarmIndex = alarms.indexWhere((a) => a.id == event.id);
      if (alarmIndex < 0) {
        AppLogger.warning('Alarm triggered with ID ${event.id} but it was not found in database.');
        return;
      }
      final alarm = alarms[alarmIndex];
      
      // Save trigger event to history log
      final historyEntry = AlarmHistoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        alarmId: alarm.id,
        alarmTitle: alarm.title.isNotEmpty ? alarm.title : 'Alarm',
        eventTime: DateTime.now(),
        eventType: 'triggered',
      );
      await repo.addHistoryEntry(historyEntry);

      emit(state.copyWith(
        ringingAlarm: () => alarm,
      ));

      // Show overlay
      fullScreenService.show(alarm);
      
      // Reload history logs list
      final history = repo.getHistory();
      emit(state.copyWith(history: history));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to process triggered alarm in Bloc', e, stackTrace);
    }
  }

  Future<void> _onStopAlarm(StopAlarmEvent event, Emitter<AlarmState> emit) async {
    try {
      final alarms = repo.getAlarms();
      final alarmIndex = alarms.indexWhere((a) => a.id == event.id);
      if (alarmIndex < 0) {
        AppLogger.warning('Attempted to stop alarm ID ${event.id} which does not exist.');
        return;
      }
      final alarm = alarms[alarmIndex];

      // Stop the alarm service
      await repo.stopAlarm(event.id);

      // Save stop event to history log
      final historyEntry = AlarmHistoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        alarmId: alarm.id,
        alarmTitle: alarm.title.isNotEmpty ? alarm.title : 'Alarm',
        eventTime: DateTime.now(),
        eventType: 'stopped',
      );
      await repo.addHistoryEntry(historyEntry);

      // Dismiss overlay
      fullScreenService.dismiss();

      emit(state.copyWith(
        ringingAlarm: () => null,
      ));

      // Reload state to refresh next alarm scheduler calculations
      add(LoadAlarmsEvent());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to stop alarm in Bloc', e, stackTrace);
      emit(state.copyWith(status: AlarmStatus.failure, errorMessage: () => e.toString()));
    }
  }

  Future<void> _onClearHistory(ClearHistoryEvent event, Emitter<AlarmState> emit) async {
    try {
      await repo.clearHistory();
      emit(state.copyWith(history: const []));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear history in Bloc', e, stackTrace);
    }
  }

  Future<void> _onUpdateSettings(UpdateSettingsEvent event, Emitter<AlarmState> emit) async {
    try {
      await repo.saveThemeMode(event.darkMode);
      await repo.saveUse24HourFormat(event.use24HourFormat);
      await repo.saveDefaultRingtone(event.defaultRingtone);
      await repo.saveDefaultVibration(event.defaultVibration);

      emit(state.copyWith(
        darkMode: event.darkMode,
        use24HourFormat: event.use24HourFormat,
        defaultRingtone: event.defaultRingtone,
        defaultVibration: event.defaultVibration,
      ));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update settings in Bloc', e, stackTrace);
    }
  }
}
