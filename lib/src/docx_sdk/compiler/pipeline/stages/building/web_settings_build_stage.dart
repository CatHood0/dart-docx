import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/web_settings/xml_web_settings_component.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage que construye word/webSettings.xml.
///
/// Este archivo contiene settings específicos para publicación web
/// y otros ajustes relacionados con la distribución del documento.
class WebSettingsBuildStage extends PipelineStage {
  const WebSettingsBuildStage();

  @override
  String get name => 'WebSettingsBuild';

  @override
  int get order => 12;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Construye word/webSettings.xml con settings web.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    final component = XmlWebSettingsComponent(
      options: context.options.webSettings,
    );

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.webSettingsXmlFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('WebSettings built and added to archive.');
  }
}
