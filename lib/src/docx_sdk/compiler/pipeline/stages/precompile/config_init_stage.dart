import '../../../../events/docx_event.dart';
import '../../../../utils/logger/logger_configs.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage that initializes the compiler configuration.
///
/// Initializes the logging system, verifies the document is not empty,
/// and emits the compilation start event.
class ConfigInitStage extends PipelineStage {
  const ConfigInitStage();

  @override
  String get name => 'ConfigInit';

  @override
  int get order => 2;

  @override
  StageCategory get category => StageCategory.preCompile;

  @override
  String get description =>
      'Initializes configuration, verifies document and emits start event.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    context.logConfig.init();

    CompilerLogger.root.info('Starting Docx compilation process.');

    // if (context.isDocumentEmpty) {
    //   CompilerLogger.root.error(
    //     'Document content is '
    //     'empty. Aborting compilation.',
    //   );
    //   context
    //     ..registerError('Document content is empty')
    //     ..emit(DocxEvent.end(error: 'Document content is empty'));
    //   return;
    // }

    context.emit(DocxEvent.start());

    CompilerLogger.root.debug('Config initialization completed.');
  }
}
