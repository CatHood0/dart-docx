import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage que construye [Content_Types].xml.
///
/// Este archivo es requerido por el formato OPC y define los content types
/// de todas las partes del documento. Incluye overrides para las partes
/// específicas del DOCX y defaults para extensiones comunes.
class ContentTypeBuildStage extends PipelineStage {
  const ContentTypeBuildStage();

  @override
  String get name => 'ContentTypeBuild';

  @override
  int get order => 0;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Construye [Content_Types].xml con todos los content types.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    final component = XmlContentTypeComponent(
      applyCustomTheme: context.config.applyCustomTheme,
      overrides: context.getStoreOfExactType<MediaStore>()!.overrides,
      extensions: <String>[
        ...context.getStoreOfExactType<MediaStore>()!.extensions,
        ...context.getStoreOfExactType<FontStore>()!.extensions,
      ],
    );

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.contentTypesPath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('ContentType built and added to archive.');
  }
}
