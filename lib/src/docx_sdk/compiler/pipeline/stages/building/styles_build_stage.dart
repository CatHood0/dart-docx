import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/styles/xml_styles_component.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage que construye word/styles.xml.
///
/// Este archivo contiene todas las definiciones de estilos usadas
/// en el documento, incluyendo el estilo Normal y estilos latent.
class StylesBuildStage extends PipelineStage {
  const StylesBuildStage();

  @override
  String get name => 'StylesBuild';

  @override
  int get order => 7;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Construye word/styles.xml con todas las definiciones de estilos.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    final component = XmlStylesComponent();

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.stylesXmlFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('Styles built and added to archive.');
  }
}
