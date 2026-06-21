import 'dart:developer' as developer;

class AppLogger {
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log('DEBUG: $message', error: error, stackTrace: stackTrace);
    print('DEBUG: $message');
  }

  static void info(String message) {
    developer.log('INFO: $message');
    print('INFO: $message');
  }

  static void warning(String message) {
    developer.log('WARNING: $message');
    print('WARNING: $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log('ERROR: $message', error: error, stackTrace: stackTrace, level: 1000);
    print('ERROR: $message - Error: $error');
  }
}
