import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage que construye word/settings.xml.
///
/// Este archivo contiene configuración avanzada del documento,
/// incluyendo opciones de compatibilidad, protección, y otros
/// settings técnicos.
class SettingsBuildStage extends PipelineStage {
  const SettingsBuildStage();

  @override
  String get name => 'SettingsBuild';

  @override
  int get order => 10;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Construye word/settings.xml con configuración del documento.';

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
