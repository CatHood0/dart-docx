import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';
import '../../../../xml_components/document/xml_body_component.dart';
import '../../../inherited/compiler_config_provider.dart';

class DocumentBuildStage extends PipelineStage {
  const DocumentBuildStage();

  @override
  String get name => 'DocumentBuild';

  @override
  int get order => 5;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build word/document.xml.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    // Obtener theme ID resuelto en DocumentRelsBuildStage
    final themeId = context.metadata['themeId'] as String?;

    final bodyComponent = XmlBodyComponent(
      body: CompilerConfigProvider(
        options: context.options,
        normalStyleIfNeeded: context.config.normalStyleIfNeeded,
        normalStyle: context.config.normalStyle,
        child: DocxApp(
          docRelsStore:
              context.getStoreOfExactType<DocumentRelsCounterStore>()!,
          numberingStore: context.getStoreOfExactType<NumberingStore>()!,
          mediaStore: context.getStoreOfExactType<MediaStore>()!,
          drawingStore:
              context.getStoreOfExactType<DrawingElementCounterStore>()!,
          fontStore: context.getStoreOfExactType<FontStore>()!,
          sdtStore: context.getStoreOfExactType<SdtStore>()!,
          hyperlinkStore: context.getStoreOfExactType<HyperlinkStore>()!,
          styles: context.document.options.docStyles,
          child: context.tree,
        ),
      ),
      themeId: themeId,
    );

    final documentComponent = XmlDocumentComponent(body: bodyComponent);

    final document = documentComponent.buildDocument();
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.documentFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug('Document built and added to archive.');
  }
}
