import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtfu/core/logger/app_logger.dart';
import 'package:wtfu/features/alarm/data/models/alarm_model.dart';
import 'package:wtfu/features/alarm/data/models/alarm_history_model.dart';

class LocalStorageService {
  final SharedPreferences prefs;

  static const String _alarmsKey = 'wtfu_alarms';
  static const String _historyKey = 'wtfu_history';
  static const String _themeKey = 'wtfu_theme_mode';
  static const String _timeFormatKey = 'wtfu_time_format_24h';
  static const String _defaultRingtoneKey = 'wtfu_default_ringtone';
  static const String _defaultVibrationKey = 'wtfu_default_vibration';

  LocalStorageService(this.prefs);

  // --- Alarms Storage ---

  List<AlarmModel> getAlarms() {
    try {
      final jsonString = prefs.getString(_alarmsKey);
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString) as List;
      return jsonList.map((item) => AlarmModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load alarms from storage', e, stackTrace);
      return [];
    }
  }

  Future<void> saveAlarms(List<AlarmModel> alarms) async {
    try {
      final jsonList = alarms.map((alarm) => alarm.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_alarmsKey, jsonString);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save alarms to storage', e, stackTrace);
    }
  }

  Future<void> saveAlarm(AlarmModel alarm) async {
    final alarms = getAlarms();
    final index = alarms.indexWhere((item) => item.id == alarm.id);
    if (index >= 0) {
      alarms[index] = alarm;
    } else {
      alarms.add(alarm);
    }
    await saveAlarms(alarms);
  }

  Future<void> deleteAlarm(int id) async {
    final alarms = getAlarms();
    alarms.removeWhere((item) => item.id == id);
    await saveAlarms(alarms);
  }

  // --- History Storage ---

  List<AlarmHistoryModel> getHistory() {
    try {
      final jsonString = prefs.getString(_historyKey);
      if (jsonString == null) return [];
      
      final List<dynamic> jsonList = json.decode(jsonString) as List;
      return jsonList.map((item) => AlarmHistoryModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load history from storage', e, stackTrace);
      return [];
    }
  }

  Future<void> saveHistory(List<AlarmHistoryModel> history) async {
    try {
      final jsonList = history.map((entry) => entry.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_historyKey, jsonString);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save history to storage', e, stackTrace);
    }
  }

  Future<void> addHistoryEntry(AlarmHistoryModel entry) async {
    final history = getHistory();
    // Prepend to show latest logs first, capped at 100 entries
    history.insert(0, entry);
    if (history.length > 100) {
      history.removeLast();
    }
    await saveHistory(history);
  }

  Future<void> clearHistory() async {
    await prefs.remove(_historyKey);
  }

  // --- Settings Storage ---

  bool isDarkMode() {
    return prefs.getBool(_themeKey) ?? true; // Default to Dark mode
  }

  Future<void> saveThemeMode(bool isDark) async {
    await prefs.setBool(_themeKey, isDark);
  }

  bool use24HourFormat() {
    return prefs.getBool(_timeFormatKey) ?? false; // Default to 12h format
  }

  Future<void> saveUse24HourFormat(bool use24h) async {
    await prefs.setBool(_timeFormatKey, use24h);
  }

  String getDefaultRingtone() {
    return prefs.getString(_defaultRingtoneKey) ?? 'assets/sounds/alarm_beep.wav';
  }

  Future<void> saveDefaultRingtone(String path) async {
    await prefs.setString(_defaultRingtoneKey, path);
  }

  bool getDefaultVibration() {
    return prefs.getBool(_defaultVibrationKey) ?? true;
  }

  Future<void> saveDefaultVibration(bool enabled) async {
    await prefs.setBool(_defaultVibrationKey, enabled);
  }
}
