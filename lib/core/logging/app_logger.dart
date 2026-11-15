import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// App logging with one rule: no customer or financial data in logs
/// (PRD 10.3, architecture 12).
///
/// Messages are fixed developer-written text plus codes. Never interpolate
/// names, phone numbers, amounts, balances or descriptions into a message.
/// Error objects are printed in full only in debug builds, because a
/// database exception's text can include statement parameters.
class AppLogger {
  const AppLogger({this.sink});

  /// Receives every record that passes the level filter. Tests use it to
  /// assert on what would be logged.
  final void Function(LogRecord record)? sink;

  void debug(String message) => _log(LogLevel.debug, message);

  void info(String message) => _log(LogLevel.info, message);

  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Release builds keep warnings and errors only.
    if (!kDebugMode && level.index < LogLevel.warning.index) return;

    final record = LogRecord(
      level: level,
      message: message,
      errorDescription: describeError(error, verbose: kDebugMode),
      stackTrace: stackTrace,
    );
    sink?.call(record);
    developer.log(
      record.errorDescription == null
          ? record.message
          : '${record.message} [${record.errorDescription}]',
      name: 'smart_khata',
      level: level.developerLevel,
      stackTrace: stackTrace,
    );
  }

  /// What may be written about [error]. Outside [verbose] mode only the
  /// error's type is kept.
  @visibleForTesting
  static String? describeError(Object? error, {required bool verbose}) {
    if (error == null) return null;
    return verbose ? error.toString() : error.runtimeType.toString();
  }
}

enum LogLevel {
  debug(500),
  info(800),
  warning(900),
  error(1000);

  const LogLevel(this.developerLevel);

  final int developerLevel;
}

@immutable
class LogRecord {
  const LogRecord({
    required this.level,
    required this.message,
    this.errorDescription,
    this.stackTrace,
  });

  final LogLevel level;
  final String message;
  final String? errorDescription;
  final StackTrace? stackTrace;
}
