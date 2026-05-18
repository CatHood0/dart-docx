import '../../../../events/docx_event.dart';
import '../../../../sdk.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage save embedded fonts to the related files.
///
/// If [FontStore.hasFonts] is provided and there is defined fonts with [FontBinaryData],
///
/// Add the embedded fonts in `word/fonts/` path.
///
/// This obfuscates the fonts following the ODT format
class EmbeddedFontsSaveStage extends PipelineStage {
  const EmbeddedFontsSaveStage();

  @override
  String get name => 'EmbeddedFontsSave';

  @override
  int get order => 1;

  @override
  StageCategory get category => StageCategory.postCompile;

  @override
  String get description => 'Save embedded fonts in the Archive output.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipFontEmbedding &&
        context.getStoreOfExactType<FontStore>() != null;
  }

  @override
  Future<void> execute(PipelineContext context) async {
    if (!context.getStoreOfExactType<FontStore>()!.hasFonts) {
      CompilerLogger.root.debug('No embedded fonts to save.');
      return;
    }

    context.emit(DocxEvent.unknownProgress(
      subject: 'Adding embedded font files',
    ));
    CompilerLogger.root.debug('Adding embedded font files to archive.');

    await for (void _ in context
        .getStoreOfExactType<FontStore>()!
        .addEmbeddedFontFilesToArchive(
          context.archive,
        )) {
    }

    CompilerLogger.root.debug('Embedded font files added.');
  }
}
