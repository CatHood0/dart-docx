import '../../../../../../docx.dart';

/// Stage that detects numbering usage in the document.
///
/// Looks for paragraphs with [Paragraph.numbering] not null and [NumberingList] components.
/// Stores the result in [sharedData['hasNumberingUsage']] for later use
/// in [NumberingBuildStage].
class NumberingDiscoveryStage extends PipelineStage {
  const NumberingDiscoveryStage();

  @override
  String get name => 'NumberingDiscovery';

  @override
  int get order => 1;

  @override
  StageCategory get category => StageCategory.discovery;

  @override
  String get description => 'Detects numbering usage in paragraphs and NumberingLists.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipNumberingDiscovery;
  }

  @override
  void execute(PipelineContext context) {
    context.emit(DocxEvent.searching(subject: 'Detecting numbering usage'));

    final bool hasNumberingUsage = context.document.root.visitElement(
          visitChildrenIfNeeded: true,
          (DocxNode<dynamic> el) {
            return el is Paragraph && el.numbering != null || el is NumberingList;
          },
        ) !=
        null;

    context.metadata['hasNumberingUsage'] = hasNumberingUsage;

    CompilerLogger.root.debug(
      'Numbering discovery completed. Has numbering: $hasNumberingUsage',
    );
  }
}
