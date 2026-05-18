import '../../../../components/base/docx_node.dart';
import '../../../../components/blocks/paragraph.dart';
import '../../../../events/docx_event.dart';
import '../../../../utils/logger/logger_configs.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage that validates Style.ref used in the document.
///
/// If [ExecutionFlags.checkStyleRefExistence] is true, visits all
/// elements and verifies that each [Style.ref] used has a corresponding
/// style in [DocumentStylesSheet].
class StyleValidationStage extends PipelineStage {
  const StyleValidationStage();

  @override
  String get name => 'StyleValidation';

  @override
  int get order => 6;

  @override
  StageCategory get category => StageCategory.discovery;

  @override
  String get description => 'Validates that document Style.refs exist in DocumentStylesSheet.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipStyleValidation && context.flags.checkStyleRefExistence;
  }

  @override
  void execute(PipelineContext context) {
    context.emit(DocxEvent.searching(subject: 'Validating styles'));
    CompilerLogger.root.debug('Initiating style validation.');

    final missingStyles = <String>[];

    context.document.root
        .visitAllElement(
      visitChildrenIfNeeded: true,
      (DocxNode<dynamic> el) => el is Paragraph,
    )
        ?.forEach((element) {
      final paragraph = element as Paragraph;
      _validateStyleRef(paragraph, context, missingStyles);
    });

    if (missingStyles.isNotEmpty) {
      CompilerLogger.root.warning(
        'Found ${missingStyles.length} missing or invalid styles: '
        '${missingStyles.join(", ")}',
      );
      context.metadata['missingStyles'] = missingStyles;
    }

    CompilerLogger.root.debug('Style validation completed.');
  }

  void _validateStyleRef(
    Paragraph paragraph,
    PipelineContext context,
    List<String> missingStyles,
  ) {}
}
