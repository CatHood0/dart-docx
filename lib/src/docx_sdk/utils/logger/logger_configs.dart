import 'package:logging/logging.dart';
import './log_levels.dart';

class CompilerLogger {
  CompilerLogger._({
    required this.name,
  }) : _logger = Logger(name);

  final String name;
  late final Logger _logger;

  static CompilerLogger root = CompilerLogger._(name: 'root');

  void error(String message, [Object? err, StackTrace? stack]) =>
      _logger.severe(message);
  void warning(String message) => _logger.warning(message);
  void info(String message) => _logger.info(message);
  void debug(String message) => _logger.fine(message);
}

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
  factory LoggerConfiguration() => instance;
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

  set level(LogLevel level) {
    _level = level;
    Logger.root.level = level.toLevel();
  }
}
