import 'package:meta/meta.dart';

import '../../utils/logger/logger_configs.dart';

class LoggablePhaseConfig {
  const LoggablePhaseConfig({
    this.loggablePhases = const <String>{},
    this.log,
    this.enabled = true,
    this.level,
  });

  final Set<String> loggablePhases;
  final void Function(String)? log;
  final bool enabled;
  final LogLevel? level;

  @internal
  void init() {
    if (enabled) {
      if (level != null) {
        LoggerConfiguration()
          ..level = level!
          ..activeHandler(printer: log);
        return;
      }
      LoggerConfiguration()
        ..all()
        ..activeHandler(printer: log);
    }
  }

  bool shouldLogPhase(String phaseName) {
    return loggablePhases.contains(phaseName);
  }
}
