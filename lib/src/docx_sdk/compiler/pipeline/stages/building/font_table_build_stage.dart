import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage que construye word/fontTable.xml.
///
/// Este archivo define las fuentes usadas en el documento.
/// Si [context.fontStore.hasFonts] es false, este stage no hace nada.
class FontTableBuildStage extends PipelineStage {
  const FontTableBuildStage();

  @override
  String get name => 'FontTableBuild';

  @override
  int get order => 8;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description =>
      'Construye word/fontTable.xml con las fuentes del documento.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipFontTable &&
        context.getStoreOfExactType<FontStore>() != null &&
        context.getStoreOfExactType<FontStore>()!.hasFonts;
  }

  @override
  void execute(PipelineContext context) {
    final component =
        context.getStoreOfExactType<FontStore>()!.buildFontTableXmlComponent(
              context.buildDocumentContext(),
            );

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.fontTableXmlFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('FontTable built and added to archive.');
  }
}
