import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';

class ContentTypeBuildStage extends PipelineStage {
  const ContentTypeBuildStage();

  @override
  String get name => 'ContentTypeBuild';

  @override
  int get order => 0;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build [Content_Types].xml.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    final component = XmlContentTypeComponent(
      applyCustomTheme: context.config.applyCustomTheme,
      overrides: context.getStoreOfExactType<MediaStore>()!.overrides,
      extensions: <String>[
        ...context.getStoreOfExactType<MediaStore>()!.extensions,
        ...context.getStoreOfExactType<FontStore>()!.extensions,
      ],
    );

    final document = component.buildDocument();
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.contentTypesPath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('ContentType built and added to archive.');
  }
}
