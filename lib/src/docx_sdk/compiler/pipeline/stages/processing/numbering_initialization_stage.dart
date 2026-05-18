import '../../../../sdk.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage that initializes the [NumberingStore] with options and discovers instances.
///
/// This stage calls [NumberingStore.initialize] with the document's numbering
/// options, and then [NumberingStore.discoverAndRegister] to detect
/// and register all used numbering instances.
///
/// ## Behavior
/// - Only processes if [NumberingDiscoveryStage] detected numbering usage
/// - Checks `sharedData['hasNumberingUsage']` before processing
/// - Initializes the store only if there is numbering in the document
///
/// ## Dependencies
/// - Requires that [NumberingDiscoveryStage] has completed
class NumberingInitializationStage extends PipelineStage {
  const NumberingInitializationStage();

  @override
  String get name => 'NumberingInitialization';

  @override
  int get order => 0;

  @override
  StageCategory get category => StageCategory.processing;

  @override
  String get description =>
      'Initializes NumberingStore with options and discovers instances.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipNumberingProcessing;
  }

  @override
  void execute(PipelineContext context) {
    final hasNumberingUsage =
        context.metadata['hasNumberingUsage'] as bool? ?? false;
    if (!hasNumberingUsage) {
      CompilerLogger.root.debug(
        'No numbering usage detected, skipping initialization.',
      );
      return;
    }

    // Creates Cache
    context
        .getStoreOfExactType<NumberingStore>()!
        .discoverAndRegister(context.document);

    CompilerLogger.root.debug(
      'Numbering store initialized. '
      '${context.getStoreOfExactType<NumberingStore>()!.concreteInstances.length} '
      'concrete instances registered.',
    );
  }
}
