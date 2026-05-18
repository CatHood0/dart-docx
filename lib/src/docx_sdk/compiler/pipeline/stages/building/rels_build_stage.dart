import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../pipeline_context.dart';
import '../../pipeline_stage.dart';

/// Stage que construye _rels/.rels.
///
/// Este archivo define las relaciones de nivel superior del paquete.
/// Solo incluye una relación hacia word/_rels/document.xml.rels.
class RelsBuildStage extends PipelineStage {
  const RelsBuildStage();

  @override
  String get name => 'RelsBuild';

  @override
  int get order => 1;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Construye _rels/.rels con relaciones de nivel superior.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    final component = XmlRelsComponent();

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.relsFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('Rels built and added to archive.');
  }
}
