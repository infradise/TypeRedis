/*
 * Copyright 2025-2026 Infradise Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// ignore_for_file: constant_identifier_names

/// Defines logging severity levels.
///
/// Follows the levels from `package:logging`.
class TRLogLevel {
  final String name;
  final int value;

  const TRLogLevel(this.name, this.value);

  /// Fine-grained tracing
  static const TRLogLevel fine = TRLogLevel('FINE', 500);

  /// Informational messages
  static const TRLogLevel info = TRLogLevel('INFO', 700);

  /// Potential problems
  static const TRLogLevel warning = TRLogLevel('WARNING', 800);

  /// Serious failures
  static const TRLogLevel severe = TRLogLevel('SEVERE', 1000);

  /// Error messages
  static const TRLogLevel error = TRLogLevel('ERROR', 1400);

  /// Disables logging.
  static const TRLogLevel off = TRLogLevel('OFF', 2000);

  /// Enables logging.
  static const EnableTRLog = false;

  bool operator <(TRLogLevel other) => value < other.value;
  bool operator <=(TRLogLevel other) => value <= other.value;

  // Legacy identifiers kept for backward compatibility (deprecated)
  @Deprecated('Since 1.1.0: Use "severe" instead')
  static const TRLogLevel SEVERE = severe;

  @Deprecated('Since 1.1.0: Use "warning" instead')
  static const TRLogLevel WARNING = warning;

  @Deprecated('Since 1.1.0: Use "info" instead')
  static const TRLogLevel INFO = info;

  @Deprecated('Since 1.1.0: Use "fine" instead')
  static const TRLogLevel FINE = fine;

  @Deprecated('Since 1.1.0: Use "off" instead')
  static const TRLogLevel OFF = off;
}

/// A simple internal logger for the valkey_client.
///
/// This avoids adding an external dependency on `package:logging`.
class TRLogger {
  final String name;
  static TRLogLevel level = TRLogLevel.off; // Logging is off by default
  bool _enableTRLog = TRLogLevel.EnableTRLog;
  void setEnableTRLog(bool status) => _enableTRLog = status;

  TRLogger(this.name);

  void setLogLevelFine() {
    level = TRLogLevel.fine;
  }

  void setLogLevelInfo() {
    level = TRLogLevel.info;
  }

  void setLogLevelWarning() {
    level = TRLogLevel.warning;
  }

  void setLogLevelSevere() {
    level = TRLogLevel.severe;
  }

  void setLogLevelError() {
    level = TRLogLevel.error;
  }

  void setLogLevelOff() {
    level = TRLogLevel.off;
  }

  /// Logs a message if [messageLevel] is at or above the current [level].
  void _log(TRLogLevel messageLevel, String message,
      [Object? error, StackTrace? stackTrace]) {
    if (!_enableTRLog) {
      if (messageLevel.value < TRLogger.level.value) {
        return; // Log level is too low, ignore.
      }
    }

    // Simple print-based logging. Users can configure this later.
    print('[${DateTime.now().toIso8601String()}] $name - '
        '${messageLevel.name}: $message');
    if (error != null) {
      print('  Error: $error');
    }
    if (stackTrace != null) {
      print('  Stacktrace:\n$stackTrace');
    }
  }

  void fine(String message) {
    _log(TRLogLevel.fine, message);
  }

  void info(String message) {
    _log(TRLogLevel.info, message);
  }

  void warning(String message, [Object? error]) {
    _log(TRLogLevel.warning, message, error);
  }

  void severe(String message, [Object? error, StackTrace? stackTrace]) {
    _log(TRLogLevel.severe, message, error, stackTrace);
  }

  void error(String message) {
    _log(TRLogLevel.error, message);
  }
}
