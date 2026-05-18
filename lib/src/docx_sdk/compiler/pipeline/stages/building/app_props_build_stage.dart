import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/docProps/xml_app_component.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage que construye docProps/app.xml.
///
/// Este archivo contiene información de la aplicación que creó
/// el documento, incluyendo el nombre, versión, y metadatos
/// específicos de la aplicación.
class AppPropsBuildStage extends PipelineStage {
  const AppPropsBuildStage();

  @override
  String get name => 'AppPropsBuild';

  @override
  int get order => 3;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Construye docProps/app.xml con información de la aplicación.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    final component = XmlAppComponent(
      metadata: context.options.editorSettings.metadata,
    );

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.appFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('AppProps built and added to archive.');
  }
}
