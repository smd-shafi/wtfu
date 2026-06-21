import 'package:wtfu/features/alarm/data/models/alarm_model.dart';
import 'package:wtfu/features/alarm/data/models/alarm_history_model.dart';
import 'package:wtfu/features/alarm/services/local_storage_service.dart';
import 'package:wtfu/features/alarm/services/alarm_scheduler_service.dart';

class AlarmDatasource {
  final LocalStorageService storage;
  final AlarmSchedulerService scheduler;

  AlarmDatasource(this.storage, this.scheduler);

  List<AlarmModel> getAlarms() => storage.getAlarms();

  Future<void> saveAlarm(AlarmModel alarm) async {
    await storage.saveAlarm(alarm);
    if (alarm.isEnabled) {
      await scheduler.scheduleAlarm(alarm);
    } else {
      await scheduler.cancelAlarm(alarm.id);
    }
  }

  Future<void> deleteAlarm(int id) async {
    await storage.deleteAlarm(id);
    await scheduler.cancelAlarm(id);
  }

  Future<void> toggleAlarm(int id, bool isEnabled) async {
    final alarms = storage.getAlarms();
    final index = alarms.indexWhere((a) => a.id == id);
    if (index >= 0) {
      final updated = alarms[index].copyWith(isEnabled: isEnabled);
      await storage.saveAlarm(updated);
      if (isEnabled) {
        await scheduler.scheduleAlarm(updated);
      } else {
        await scheduler.cancelAlarm(id);
      }
    }
  }

  Future<void> stopAlarm(int id) async {
    await scheduler.cancelAlarm(id);
    final alarms = storage.getAlarms();
    final index = alarms.indexWhere((a) => a.id == id);
    if (index >= 0) {
      final alarm = alarms[index];
      final now = DateTime.now();
      
      // Reschedule next repeating alarm, or disable one-time alarm
      if (alarm.repeatDays.isNotEmpty) {
        final updated = alarm.copyWith(
          lastTriggeredAt: now,
          isEnabled: true,
        );
        await storage.saveAlarm(updated);
        await scheduler.scheduleAlarm(updated);
      } else {
        final updated = alarm.copyWith(
          lastTriggeredAt: now,
          isEnabled: false,
        );
        await storage.saveAlarm(updated);
      }
    }
  }

  List<AlarmHistoryModel> getHistory() => storage.getHistory();
  Future<void> addHistoryEntry(AlarmHistoryModel entry) => storage.addHistoryEntry(entry);
  Future<void> clearHistory() => storage.clearHistory();

  // Settings
  bool isDarkMode() => storage.isDarkMode();
  Future<void> saveThemeMode(bool isDark) => storage.saveThemeMode(isDark);
  bool use24HourFormat() => storage.use24HourFormat();
  Future<void> saveUse24HourFormat(bool use24h) => storage.saveUse24HourFormat(use24h);
  String getDefaultRingtone() => storage.getDefaultRingtone();
  Future<void> saveDefaultRingtone(String path) => storage.saveDefaultRingtone(path);
  bool getDefaultVibration() => storage.getDefaultVibration();
  Future<void> saveDefaultVibration(bool enabled) => storage.saveDefaultVibration(enabled);
}
