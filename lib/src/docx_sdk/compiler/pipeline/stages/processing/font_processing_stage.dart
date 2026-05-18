import '../../../../events/docx_event.dart';
import '../../../../sdk.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage that processes fonts for embedding.
///
/// This stage is primarily for event emission and verification.
/// Actual font processing occurs in [FontDiscoveryStage] where fonts are
/// discovered and registered.
///
/// If there are fonts with [FontBinaryData], the necessary relationships
/// for embedding are generated.
class FontProcessingStage extends PipelineStage {
  const FontProcessingStage();

  @override
  String get name => 'FontProcessing';

  @override
  int get order => 4;

  @override
  StageCategory get category => StageCategory.processing;

  @override
  String get description => 'Processes fonts for embedding and generates relationships.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipFontProcessing && context.existStore<FontStore>();
  }

  @override
  void execute(PipelineContext context) {
    if (!context.getStoreOfExactType<FontStore>()!.hasFonts) {
      CompilerLogger.root.debug('No fonts to process.');
      return;
    }

    context.emit(DocxEvent.unknownProgress(subject: 'Processing fonts'));
    CompilerLogger.root.debug(
      'Processing ${context.getStoreOfExactType<FontStore>()!.fonts.length} fonts for embedding.',
    );

    // Actual font processing with binary data already occurs in FontStore.addFont()
    // Here we only verify and emit events

    if (context.getStoreOfExactType<FontStore>()!.fontRelations.isNotEmpty) {
      CompilerLogger.root.debug(
        '${context.getStoreOfExactType<FontStore>()!.fontRelations.length} font relations generated.',
      );
    }
  }
}
