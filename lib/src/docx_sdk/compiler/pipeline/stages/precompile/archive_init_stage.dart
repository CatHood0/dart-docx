import 'package:archive/archive.dart';

import '../../../../utils/logger/logger_configs.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage that initializes the compilation archive.
///
/// Creates a new empty [Archive] and assigns it to the context.
/// If an archive already exists (e.g., from template extraction),
/// clears it before using.
class ArchiveInitStage extends PipelineStage {
  const ArchiveInitStage();

  @override
  String get name => 'ArchiveInit';

  @override
  int get order => 3;

  @override
  StageCategory get category => StageCategory.preCompile;

  @override
  String get description => 'Initializes the empty archive for compilation.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  Future<void> execute(PipelineContext context) async {
    context.archive = Archive();

    if (_archiveHasContent(context.archive)) {
      await context.archive.clear();
      CompilerLogger.root.debug('Existing archive cleared.');
    }

    CompilerLogger.root.debug('Archive initialization completed.');
  }

  bool _archiveHasContent(Archive archive) {
    return archive.files.isNotEmpty;
  }
}
