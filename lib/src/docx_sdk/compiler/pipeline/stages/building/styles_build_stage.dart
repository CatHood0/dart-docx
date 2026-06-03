import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/styles/xml_styles_component.dart';

class StylesBuildStage extends PipelineStage {
  const StylesBuildStage();

  @override
  String get name => 'StylesBuild';

  @override
  int get order => 7;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build word/styles.xml.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    final component = XmlStylesComponent(docStyles: context.options.docStyles);

    final document = component.buildDocument();
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.stylesXmlFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('Styles built and added to archive.');
  }
}
