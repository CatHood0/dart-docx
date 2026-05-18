import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
class RelsBuildStage extends PipelineStage {
  const RelsBuildStage();

  @override
  String get name => 'RelsBuild';

  @override
  int get order => 1;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build _rels/.rels.';

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
