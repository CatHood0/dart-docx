import '../../../../../core/extensions/cast_ext.dart';
import '../../../../components/base/docx_node.dart';
import '../../../../components/root/root_body.dart';
import '../../../../exceptions/docx_compilation_exception.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

class TreeValidationStage extends PipelineStage {
  const TreeValidationStage();

  @override
  String get name => 'TreeValidations';

  @override
  int get order => 2;

  @override
  StageCategory get category => StageCategory.preCompile;

  @override
  String get description =>
      'Validates that document has correct tree structure to work with.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipTreeValidations;
  }

  @override
  void execute(PipelineContext context) {
    // NOTE: by now we just validates if the root exists
    final RootBody? root = context.tree
        .visitElement(
          (DocxNode<dynamic> e) => e is RootBody,
          visitChildrenIfNeeded: true,
        )
        ?.cast();

    if (root == null) {
      throw DocxCompilationException(
        message: 'Required RootBody was not found in the. '
            'Please, ensure that you\'re wrapping the relevant content of your document with RootBody',
        documentTitle: context.document.options.title,
        cause: 'Required RootBody not found'
      );
    }
  }
}
