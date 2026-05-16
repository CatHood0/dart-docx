import 'package:logging/logging.dart';
import '../../../../docx.dart';

extension LogToLevel on LogLevel {
  Level toLevel() {
    switch (this) {
      case LogLevel.off:
        return Level.OFF;
      case LogLevel.error:
        return Level.SEVERE;
      case LogLevel.warn:
        return Level.WARNING;
      case LogLevel.info:
        return Level.INFO;
      case LogLevel.debug:
        return Level.FINE;
      case LogLevel.all:
        return Level.ALL;
    }
  }

  String get name {
    switch (this) {
      case LogLevel.off:
        return 'OFF';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.all:
        return 'ALL';
    }
  }
}

extension LevelToLog on Level {
  LogLevel toLogLevel() {
    if (this == Level.SEVERE) {
      return LogLevel.error;
    } else if (this == Level.WARNING) {
      return LogLevel.warn;
    } else if (this == Level.INFO) {
      return LogLevel.info;
    } else if (this == Level.FINE) {
      return LogLevel.debug;
    }
    return LogLevel.off;
  }
}
