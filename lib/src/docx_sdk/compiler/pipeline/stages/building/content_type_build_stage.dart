import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../../../docx.dart';
import '../../../../stores/glossary_store.dart';

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
    final MediaStore mediaStore = context.getStoreOfExactType<MediaStore>()!;
    final GlossaryStore glossaryStore = context.getStoreOfExactType<GlossaryStore>()!;

    // Build overrides list with glossary override if needed
    final List<XmlOverrideElementTypeComponent> allOverrides = <XmlOverrideElementTypeComponent>[
      ...mediaStore.overrides,
      if (glossaryStore.hasEntries)
        XmlOverrideElementTypeComponent(
          part: '/${DocxPaths.glossaryFilePath}',
          contentType: namespaces['documentType']!,
        ),
    ];

    final component = XmlContentTypeComponent(
      applyCustomTheme: context.config.applyCustomTheme,
      overrides: allOverrides,
      extensions: <String>[
        ...mediaStore.extensions,
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
