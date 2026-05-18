import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/themes/xml_theme_component.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage que construye word/theme/theme1.xml.
///
/// Este archivo contiene el tema visual del documento (colores,
/// fuentes de tema, efectos). Solo se construye si
/// [PipelineConfig.applyCustomTheme] es true.
class ThemeBuildStage extends PipelineStage {
  const ThemeBuildStage();

  @override
  String get name => 'ThemeBuild';

  @override
  int get order => 11;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Construye word/theme/theme1.xml con el tema visual.';

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
