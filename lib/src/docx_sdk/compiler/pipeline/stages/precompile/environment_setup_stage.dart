import '../../../../../../docx.dart';

/// Stage that prepares the compilation environment.
///
/// Resets all stores and configures the cross-references
/// necessary for correct pipeline operation.
class EnvironmentSetupStage extends PipelineStage {
  const EnvironmentSetupStage();

  @override
  String get name => 'EnvironmentSetup';

  @override
  int get order => 0;

  @override
  StageCategory get category => StageCategory.preCompile;

  @override
  String get description =>
      'Prepares the compilation environment by resetting stores and '
      'configuring cross-references.';

  @override
  bool shouldExecute(PipelineContext context) => !context.flags.skipStoreReset;

  @override
  void execute(PipelineContext context) {
    NumberingList.clearReferences();

    context.getStores().forEach(
          (Store e) => e
            ..reset()
            ..initialize(context),
        );

    CompilerLogger.root.debug('Environment setup completed.');
  }
}
