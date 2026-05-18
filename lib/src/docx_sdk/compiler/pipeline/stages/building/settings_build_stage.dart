import 'dart:convert';
import 'package:archive/archive.dart';
import '../../../../sdk.dart';

class SettingsBuildStage extends PipelineStage {
  const SettingsBuildStage();

  @override
  String get name => 'SettingsBuild';

  @override
  int get order => 10;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build word/settings.xml.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    final component = XmlSettingsComponent(options: context.options.settings);

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.settingsXmlFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('Settings built and added to archive.');
  }
}
