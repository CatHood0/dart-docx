import '../../../../../core/namespaces.dart' as ns;
import '../../../../events/docx_event.dart';
import '../../../../sdk.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage that registers discovered hyperlinks.
///
/// For each [HyperlinkRun] in [HyperlinkStore], assigns a unique rId
/// and creates a [RelationShip] with the hyperlink target.
///
/// Generated relationships are stored in [context.hyperlinkRelationships]
/// for use in [DocumentRelsBuildStage].
class HyperlinkRegistrationStage extends PipelineStage {
  const HyperlinkRegistrationStage();

  @override
  String get name => 'HyperlinkRegistration';

  @override
  int get order => 3;

  @override
  StageCategory get category => StageCategory.processing;

  @override
  String get description => 'Registers hyperlinks and builds relationships.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipHyperlinkRegistration;
  }

  @override
  void execute(PipelineContext context) {
    if (context.getStoreOfExactType<HyperlinkStore>()!.hyperlinks.isEmpty) {
      CompilerLogger.root.debug('No hyperlinks to register.');
      context.hyperlinkRelationships = [];
      return;
    }

    context.emit(DocxEvent.unknownProgress(subject: 'Registering links'));
    CompilerLogger.root
        .debug('Registering hyperlinks and building relationships.');

    context.hyperlinkRelationships = context
        .getStoreOfExactType<HyperlinkStore>()!
        .buildHyperlinkRelationships(
          ns.namespaces['hyperlink']!,
        );

    CompilerLogger.root.debug(
      'Hyperlink relationships built. Count: ${context.hyperlinkRelationships.length}.',
    );
  }
}
