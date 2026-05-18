import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/themes/xml_theme_component.dart';
class ThemeBuildStage extends PipelineStage {
  const ThemeBuildStage();

  @override
  String get name => 'ThemeBuild';

  @override
  int get order => 11;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build word/theme/theme1.xml.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipTheme && context.config.applyCustomTheme;
  }

  @override
  void execute(PipelineContext context) {
    final component = XmlThemeComponent(options: context.options.theme);

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.theme1XmlFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('Theme built and added to archive.');
  }
}
