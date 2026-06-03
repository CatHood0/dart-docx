import '../../../../sdk.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

class ArchiveFinalizationStage extends PipelineStage {
  const ArchiveFinalizationStage();

  @override
  String get name => 'ArchiveFinalization';

  @override
  int get order => 2;

  @override
  StageCategory get category => StageCategory.postCompile;

  @override
  String get description =>
      'Ends the Archive element and prepares for return it.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    context.metadata['_isArchiveFinalized'] = true;

    CompilerLogger.root.info(
      'Archive finalized. Total files: ${context.archive.files.length}',
    );
  }
}
