import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/docProps/xml_app_component.dart';
class AppPropsBuildStage extends PipelineStage {
  const AppPropsBuildStage();

  @override
  String get name => 'AppPropsBuild';

  @override
  int get order => 3;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build docProps/app.xml.';

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
