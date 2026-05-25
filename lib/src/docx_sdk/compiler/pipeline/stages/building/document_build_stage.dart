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
  bool shouldExecute(PipelineContext context) => !context.flags.skipDocumentBuild;

  @override
  void execute(PipelineContext context) {
    // Obtener theme ID resuelto en DocumentRelsBuildStage
    final String? themeId = context.metadata['themeId'] as String?;

    final XmlBodyComponent bodyComponent = XmlBodyComponent(
      options: context.options,
      // Should we wrap in a ThemeData?
      body: CompilerConfigProvider(
        options: context.options,
        normalStyleIfNeeded: context.config.normalStyleIfNeeded,
        normalStyle: context.config.normalStyle,
        noTrim: context.config.noTrim,
        checkStyleRefExistence: context.config.checkStyleRefExistence,
        child: DocxApp(
          docRelsStore:
              context.getStoreOfExactType<DocumentRelsCounterStore>() ??
                  DocumentRelsCounterStore(),
          numberingStore:
              context.getStoreOfExactType<NumberingStore>() ?? NumberingStore(),
          mediaStore: context.getStoreOfExactType<MediaStore>() ?? MediaStore(),
          drawingStore:
              context.getStoreOfExactType<DrawingElementCounterStore>() ??
                  DrawingElementCounterStore(),
          fontStore: context.getStoreOfExactType<FontStore>() ?? FontStore(),
          sdtStore: context.getStoreOfExactType<SdtStore>() ?? SdtStore(),
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
