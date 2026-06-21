import 'package:permission_handler/permission_handler.dart';
import 'package:wtfu/core/logger/app_logger.dart';

class NotificationService {
  Future<bool> requestPermissions() async {
    try {
      // 1. Request Notification Permission
      final notificationStatus = await Permission.notification.status;
      if (notificationStatus.isDenied) {
        AppLogger.info('Requesting notification permission...');
        await Permission.notification.request();
      }

      // 2. Request Exact Alarm Permission (Android 12+)
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (exactAlarmStatus.isDenied) {
        AppLogger.info('Requesting exact alarm permission...');
        await Permission.scheduleExactAlarm.request();
      }

      final updatedNotification = await Permission.notification.isGranted;
      final updatedExactAlarm = await Permission.scheduleExactAlarm.isGranted;

      AppLogger.info('Permissions status - Notification: $updatedNotification, ExactAlarm: $updatedExactAlarm');
      
      return updatedNotification && updatedExactAlarm;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to request permissions', e, stackTrace);
      return false;
    }
  }

  Future<bool> checkPermissionStatus() async {
    final notificationGranted = await Permission.notification.isGranted;
    final exactAlarmGranted = await Permission.scheduleExactAlarm.isGranted;
    return notificationGranted && exactAlarmGranted;
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (status.isDenied) {
        AppLogger.info('Requesting ignore battery optimizations...');
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to request ignore battery optimizations', e, stackTrace);
    }
  }
}
