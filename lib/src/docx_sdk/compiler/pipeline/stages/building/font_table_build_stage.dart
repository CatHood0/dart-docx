import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';

class FontTableBuildStage extends PipelineStage {
  const FontTableBuildStage();

  @override
  String get name => 'FontTableBuild';

  @override
  int get order => 8;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build word/fontTable.xml.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipFontTable &&
        context.getStoreOfExactType<FontStore>() != null &&
        context.getStoreOfExactType<FontStore>()!.hasFonts;
  }

  @override
  void execute(PipelineContext context) {
    final component =
        context.getStoreOfExactType<FontStore>()!.buildFontTableXmlComponent();

    final document = component.buildDocument();
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.fontTableXmlFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('FontTable built and added to archive.');
  }
}
