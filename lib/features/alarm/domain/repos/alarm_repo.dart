import 'package:wtfu/features/alarm/data/models/alarm_model.dart';
import 'package:wtfu/features/alarm/data/models/alarm_history_model.dart';

abstract class AlarmRepo {
  List<AlarmModel> getAlarms();
  Future<void> saveAlarm(AlarmModel alarm);
  Future<void> deleteAlarm(int id);
  Future<void> toggleAlarm(int id, bool isEnabled);
  Future<void> stopAlarm(int id);
  List<AlarmHistoryModel> getHistory();
  Future<void> addHistoryEntry(AlarmHistoryModel entry);
  Future<void> clearHistory();
  
  // Settings
  bool isDarkMode();
  Future<void> saveThemeMode(bool isDark);
  bool use24HourFormat();
  Future<void> saveUse24HourFormat(bool use24h);
  String getDefaultRingtone();
  Future<void> saveDefaultRingtone(String path);
  bool getDefaultVibration();
  Future<void> saveDefaultVibration(bool enabled);
}
