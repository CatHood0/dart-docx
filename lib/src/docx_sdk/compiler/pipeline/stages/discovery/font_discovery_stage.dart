import '../../../../../../docx.dart';

/// Stage that discovers fonts used in the document.
///
/// If [ExecutionFlags.dynamicFontSearch] is true, scans the document
/// content (paragraphs, runs, styles) to find used fonts.
///
/// Also includes predefined fonts from [DocumentOptions.fonts].
///
/// Discovered fonts are used to build [fontTable.xml].
class FontDiscoveryStage extends PipelineStage {
  const FontDiscoveryStage();

  @override
  String get name => 'FontDiscovery';

  @override
  int get order => 4;

  @override
  StageCategory get category => StageCategory.discovery;

  @override
  String get description => 'Discovers fonts used in the document.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipFontDiscovery &&
        context.getStoreOfExactType<FontStore>() != null;
  }

  @override
  void execute(PipelineContext context) {
    context.emit(DocxEvent.searching(subject: 'Discovering fonts'));
    CompilerLogger.root.debug('Initiating font discovery.');

    context.getStoreOfExactType<FontStore>()!.discoverFonts(
          context.document,
          context.tree,
          dynamicSearchEnabled: context.flags.dynamicFontSearch,
        );

    CompilerLogger.root.debug(
      'Font discovery completed. '
      'Found ${context.getStoreOfExactType<FontStore>()!.hasFonts ? context.getStoreOfExactType<FontStore>()!.fonts.length : 0} fonts.',
    );
  }
}
