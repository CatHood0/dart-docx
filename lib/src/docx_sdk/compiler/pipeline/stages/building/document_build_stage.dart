import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/document/xml_body_component.dart';

class DocumentBuildStage extends PipelineStage {
  const DocumentBuildStage();

  @override
  String get name => 'DocumentBuild';

  @override
  int get order => 5;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build word/document.xml.';

  @override
  bool shouldExecute(PipelineContext context) => !context.flags.skipDocumentBuild;

  @override
  void execute(PipelineContext context) {
    CompilerLogger.root.debug('Starting $description');
    final String? themeId = context.metadata['themeId'] as String?;

    final XmlBodyComponent bodyComponent = XmlBodyComponent(
      options: context.options,
      // Should we wrap in a ThemeData?
      body: context.tree,
      themeId: themeId,
    );

    final documentComponent = XmlDocumentComponent(body: bodyComponent);

    final document = documentComponent.buildDocument();
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.documentFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('Document built and added to archive.');
  }
}
