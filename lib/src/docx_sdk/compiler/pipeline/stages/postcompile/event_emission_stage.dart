import '../../../../sdk.dart';
import '../../../../events/docx_event.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

class EventEmissionStage extends PipelineStage {
  const EventEmissionStage();

  @override
  String get name => 'EventEmission';

  @override
  int get order => 3;

  @override
  StageCategory get category => StageCategory.postCompile;

  @override
  String get description => 'Emit end event and release the resources.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    if (context.lastError != null) {
      CompilerLogger.root.error(
        'Docx compilation failed: ${context.lastError}',
        context.lastError,
      );
      context.emit(DocxEvent.end(error: context.lastError));
    } else {
      CompilerLogger.root.info('Docx compilation completed successfully.');
      context.emit(DocxEvent.end(result: context.archive));
    }

    context.resetEventController();

    CompilerLogger.root.debug('Event emission stage completed.');
  }
}
