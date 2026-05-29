import '../../../../events/docx_event.dart';
import '../../../../stores/hyperlink_store.dart';
import '../../../../utils/logger/logger_configs.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage that discovers all hyperlinks in the document.
///
/// Iterates over direct children of DocumentRoot and looks for
/// [HyperlinkRun] components. Discovered hyperlinks are used to build
/// relationships in [HyperlinkRegistrationStage].
class HyperlinkDiscoveryStage extends PipelineStage {
  const HyperlinkDiscoveryStage();

  @override
  String get name => 'HyperlinkDiscovery';

  @override
  int get order => 3;

  @override
  StageCategory get category => StageCategory.discovery;

  @override
  String get description => 'Discovers all hyperlinks in the document.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipHyperlinkDiscovery;
  }

  @override
  void execute(PipelineContext context) {
    context.emit(DocxEvent.searching(subject: 'Searching hyperlinks'));

    if (context.getStoreOfExactType<HyperlinkStore>() == null) {
      throw Exception(
        'HyperlinkStore expected '
        'during $name (${category.name}) '
        'execution but was not found',
      );
    }

    CompilerLogger.root.debug('Initiating hyperlink search.');

    context
        .getStoreOfExactType<HyperlinkStore>()!
        .discoverHyperlinks(context.tree);

    CompilerLogger.root.debug(
      'Hyperlink search completed. '
      'Found ${context.getStoreOfExactType<HyperlinkStore>()!.hyperlinks.length} hyperlinks.',
    );
  }
}
