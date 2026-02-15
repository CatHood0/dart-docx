import 'package:meta/meta.dart';

import '../../utils/logger/logger_configs.dart';

class LoggablePhaseConfig {
  const LoggablePhaseConfig({
    this.loggablePhases = const <String>{},
    this.log,
    this.enabled = true,
  });

  final Set<String> loggablePhases;
  final void Function(String)? log;
  final bool enabled;

  @internal
  void init() {
    if (enabled) {
      LoggerConfiguration()
        ..all()
        ..activeHandler(printer: log);
    }
  }

  bool shouldLogPhase(String phaseName) {
    return loggablePhases.contains(phaseName);
  }
}
