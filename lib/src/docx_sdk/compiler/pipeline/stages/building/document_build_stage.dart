import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/document/xml_body_component.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage que construye word/document.xml.
///
/// Este es el archivo principal del documento, contiene todo el contenido
/// del documento (párrafos, tablas, etc.) envuelto en w:body.
///
/// El body se construye usando XmlBodyComponent que visita el DocxNode tree.
class DocumentBuildStage extends PipelineStage {
  const DocumentBuildStage();

  @override
  String get name => 'DocumentBuild';

  @override
  int get order => 5;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Construye word/document.xml con el contenido del documento.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    // Obtener theme ID resuelto en DocumentRelsBuildStage
    final themeId = context.metadata['themeId'] as String?;

    final bodyComponent = XmlBodyComponent(
      body: context.document.root,
      themeId: themeId,
    );

    final documentComponent = XmlDocumentComponent(body: bodyComponent);

    final document = documentComponent.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.documentFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('Document built and added to archive.');
  }
}
