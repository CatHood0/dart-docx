import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage que construye word/_rels/fontTable.xml.rels.
///
/// Este archivo contiene las relaciones para fuentes embebidas.
/// Solo se construye si hay fuentes embebidas y [dynamicFontSearch] está habilitado.
class FontRelsBuildStage extends PipelineStage {
  const FontRelsBuildStage();

  @override
  String get name => 'FontRelsBuild';

  @override
  int get order => 9;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description =>
      'Construye word/_rels/fontTable.xml.rels para fuentes embebidas.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipFontRels &&
        context.flags.dynamicFontSearch &&
        context.getStoreOfExactType<FontStore>() != null &&
        context.getStoreOfExactType<FontStore>()!.fontRelations.isNotEmpty;
  }

  @override
  void execute(PipelineContext context) {
    final component = context.getStoreOfExactType<FontStore>()!.buildFontTableRelsXmlDocument(
      context.buildDocumentContext(),
    );

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.fontTableXmlRelsFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('FontRels built and added to archive.');
  }
}
