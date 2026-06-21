import 'package:wtfu/features/alarm/data/datasources/alarm_datasource.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';
import 'package:wtfu/features/alarm/data/models/alarm_history_model.dart';
import 'package:wtfu/features/alarm/domain/repos/alarm_repo.dart';

class AlarmRepoImpl implements AlarmRepo {
  final AlarmDatasource datasource;

  AlarmRepoImpl(this.datasource);

  @override
  List<AlarmModel> getAlarms() => datasource.getAlarms();

  @override
  Future<void> saveAlarm(AlarmModel alarm) => datasource.saveAlarm(alarm);

  @override
  Future<void> deleteAlarm(int id) => datasource.deleteAlarm(id);

  @override
  Future<void> toggleAlarm(int id, bool isEnabled) => datasource.toggleAlarm(id, isEnabled);

  @override
  Future<void> stopAlarm(int id) => datasource.stopAlarm(id);

  @override
  List<AlarmHistoryModel> getHistory() => datasource.getHistory();

  @override
  Future<void> addHistoryEntry(AlarmHistoryModel entry) => datasource.addHistoryEntry(entry);

  @override
  Future<void> clearHistory() => datasource.clearHistory();

  // Settings
  @override
  bool isDarkMode() => datasource.isDarkMode();

  @override
  Future<void> saveThemeMode(bool isDark) => datasource.saveThemeMode(isDark);

  @override
  bool use24HourFormat() => datasource.use24HourFormat();

  @override
  Future<void> saveUse24HourFormat(bool use24h) => datasource.saveUse24HourFormat(use24h);

  @override
  String getDefaultRingtone() => datasource.getDefaultRingtone();

  @override
  Future<void> saveDefaultRingtone(String path) => datasource.saveDefaultRingtone(path);

  @override
  bool getDefaultVibration() => datasource.getDefaultVibration();

  @override
  Future<void> saveDefaultVibration(bool enabled) => datasource.saveDefaultVibration(enabled);
}
