import '../../../../components/layout/columns/page_column.dart';
import '../../../../components/blocks/paragraph.dart';
import '../../../../components/runs/run.dart';
import '../../../../components/base/run_base.dart';
import '../../../../sdk.dart';
import '../../../../events/docx_event.dart';
import '../../../../utils/logger/logger_configs.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage that discovers columns and processes column breaks.
///
/// Detects all [PageColumn] elements in the document and inserts
/// [Break.columnBreak] in the first paragraph of each column (except the first).
/// This ensures columns render correctly in Word.
class ColumnDiscoveryStage extends PipelineStage {
  const ColumnDiscoveryStage();

  @override
  String get name => 'ColumnDiscovery';

  @override
  int get order => 0;

  @override
  StageCategory get category => StageCategory.discovery;

  @override
  String get description => 'Detects PageColumn and inserts column breaks in paragraphs.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipColumnDiscovery;
  }

  @override
  void execute(PipelineContext context) {
    context.emit(DocxEvent.searching(subject: 'Detecting columns'));

    final columns = context.document.root
        .visitAllElement(
          visitChildrenIfNeeded: false,
          (DocxNode<dynamic> el) => el is PageColumn,
        )
        ?.cast<PageColumn>();

    if (columns == null || columns.isEmpty) {
      CompilerLogger.root.debug('No columns found in document.');
      context.metadata['columns'] = <PageColumn>[];
      return;
    }

    CompilerLogger.root.info('Found ${columns.length} columns. Processing breaks.');

    int index = 0;
    for (final PageColumn column in columns) {
      if (index > 0) {
        final DocxNode<dynamic>? paragraph = column.child.firstOrNull;
        if (paragraph == null || paragraph is! Paragraph) {
          CompilerLogger.root.info(
            'Inserting column break in element at $index '
            'by non-existent paragraph',
          );
          column.addFirst(
            Paragraph(
              children: <RunBase<dynamic>>[
                Run(component: Break.columnBreak()),
              ],
            ),
          );
          break;
        }
        CompilerLogger.root.info(
          'Inserting column break in first element of column at $index',
        );
        paragraph.addRunFirst(Run.columnBreak());
      }
      index++;
    }

    context.metadata['columns'] = columns;
    CompilerLogger.root.debug('Column discovery completed.');
  }
}
