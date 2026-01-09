import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

class CompilerLogger {
  CompilerLogger._({
    required this.name,
  }) : _logger = Logger(name);

  final String name;
  late final Logger _logger;

  static CompilerLogger root = CompilerLogger._(name: 'root');

  void e(String message, [Object? err, StackTrace? stack]) =>
      _logger.severe(message);
  void w(String message) => _logger.warning(message);
  void i(String message) => _logger.info(message);
  void d(String message) => _logger.fine(message);
}

@internal
enum LogLevel {
  off,
  error,
  warn,
  info,
  debug,
  all,
}

typedef LogHandler = void Function(String message);

/// Manages log service for [DocxCompiler]
///
/// Set the log level and config the handler depending on your need.
class LoggerConfiguration {
  LoggerConfiguration._() {
    Logger.root.onRecord.listen((
      LogRecord record,
    ) {
      if (handler != null) {
        handler!(
          '[${record.level.toLogLevel().name}]'
          '[${record.loggerName}]: '
          '${record.time}: '
          '${record.message}',
        );
      }
    });
  }

  factory LoggerConfiguration() => instance;

  static final LoggerConfiguration instance = LoggerConfiguration._();

  LogHandler? handler;

  LogLevel _level = LogLevel.off;

  LogLevel get level => _level;

  void activeHandler({
    void Function(String)? printer,
  }) {
    handler = printer ?? print;
  }

  void deactivateHandler() {
    if (handler != null) handler = null;
  }

  void all() {
    _level = LogLevel.all;
    Logger.root.level = level.toLevel();
  }

  void debug() {
    _level = LogLevel.debug;
    Logger.root.level = level.toLevel();
  }

  void info() {
    _level = LogLevel.info;
    Logger.root.level = level.toLevel();
  }

  void warn() {
    _level = LogLevel.warn;
    Logger.root.level = level.toLevel();
  }

  void off() {
    _level = LogLevel.off;
    Logger.root.level = level.toLevel();
  }

  @internal
  set level(LogLevel level) {
    _level = level;
    Logger.root.level = level.toLevel();
  }
}

extension on LogLevel {
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

extension on Level {
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
