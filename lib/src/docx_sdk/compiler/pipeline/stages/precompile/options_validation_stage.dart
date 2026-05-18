import '../../../../utils/logger/logger_configs.dart';
import '../../execution_flags.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage that validates document options.
///
/// Verifies that required styles exist in the DocumentStylesSheet.
/// Only executes if [ExecutionFlags.forceNormalStyle] is true.
class OptionsValidationStage extends PipelineStage {
  const OptionsValidationStage();

  @override
  String get name => 'OptionsValidation';

  @override
  int get order => 1;

  @override
  StageCategory get category => StageCategory.preCompile;

  @override
  String get description => 'Validates document options and verifies required styles.';

  @override
  bool shouldExecute(PipelineContext context) {
    return context.flags.forceNormalStyle;
  }

  @override
  void execute(PipelineContext context) {
    final options = context.options;
    final defaultNormalStyle = context.config.defaultNormalStyle;

    final normalStyle = options.docStyles.getStyleById(defaultNormalStyle.styleId);
    if (normalStyle == null) {
      final message = 'Style "${defaultNormalStyle.styleId}" does not exist in '
          'DocumentStylesSheet. Make sure the Normal style is defined '
          'or disable applyNormalStyleIfNeeded.';

      CompilerLogger.root.error(message);
      context.registerError(message);
      throw Exception(message);
    }

    CompilerLogger.root.debug('Options validation passed. '
        'Normal style "${defaultNormalStyle.styleId}" verified.');
  }
}
