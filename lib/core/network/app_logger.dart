import 'package:flutter/foundation.dart';

class AppLogger {
  /// Registra un mensaje informativo solo en modo depuración (debug mode).
  static void info(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }

  /// Registra una advertencia solo en modo depuración (debug mode).
  static void warn(String message) {
    if (kDebugMode) {
      print('[WARNING] $message');
    }
  }

  /// Registra un error solo en modo depuración (debug mode).
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[ERROR] $message');
      if (error != null) {
        print('Details: $error');
      }
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
  }
}
