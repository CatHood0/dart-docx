import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/web_settings/xml_web_settings_component.dart';

class WebSettingsBuildStage extends PipelineStage {
  const WebSettingsBuildStage();

  @override
  String get name => 'WebSettingsBuild';

  @override
  int get order => 12;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build word/webSettings.xml.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    final component = XmlWebSettingsComponent(
      options: context.options.webSettings,
    );

    final document = component.buildDocument();
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.webSettingsXmlFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('WebSettings built and added to archive.');
  }
}
