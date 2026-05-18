import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/docProps/xml_core_component.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage que construye docProps/core.xml.
///
/// Este archivo contiene metadatos básicos del documento como
/// título, autor, fecha de creación, etc.
class CorePropsBuildStage extends PipelineStage {
  const CorePropsBuildStage();

  @override
  String get name => 'CorePropsBuild';

  @override
  int get order => 2;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Construye docProps/core.xml con metadatos del documento.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    final component = XmlCoreComponent(
      options: context.options,
    );

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.coreFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('CoreProps built and added to archive.');
  }
}
