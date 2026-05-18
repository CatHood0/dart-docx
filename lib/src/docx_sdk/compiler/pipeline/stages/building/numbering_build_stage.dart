import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
class NumberingBuildStage extends PipelineStage {
  const NumberingBuildStage();

  @override
  String get name => 'NumberingBuild';

  @override
  int get order => 6;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description =>
      'Build word/numbering.xml.';

  @override
  bool shouldExecute(PipelineContext context) {
    if (context.flags.skipNumberingBuild) {
      return false;
    }
    return context.metadata['hasNumberingUsage'] as bool? ??
        context.hasNumberingUsage;
  }

  @override
  void execute(PipelineContext context) {
    if (context.getStoreOfExactType<NumberingStore>() == null) {
      throw Exception(
        'Expected NumberingStore '
        'during $name (${category.name}) '
        'execution but was not found',
      );
    }
    final component = context
        .getStoreOfExactType<NumberingStore>()!
        .buildNumberingXmlComponent();

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.numberingXmlFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('Numbering built and added to archive.');
  }
}
