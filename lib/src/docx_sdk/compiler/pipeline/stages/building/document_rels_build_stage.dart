import 'dart:convert';

import 'package:archive/archive.dart';

import '../../../../sdk.dart';

class DocumentRelsBuildStage extends PipelineStage {
  const DocumentRelsBuildStage();

  @override
  String get name => 'DocumentRelsBuild';

  @override
  int get order => 4;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build word/_rels/document.xml.rels relationships.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    // Combinar todas las relaciones
    final allRelations = <RelationShip>[
      ...context.defaultDocRelations,
      ...context.imageRelationships,
      ...context.hyperlinkRelationships,
    ];

    final component = XmlDocumentRelsComponent(relations: allRelations);

    // Resolver theme ID si aplica
    String? themeId;
    if (context.config.applyCustomTheme) {
      themeId = component.theme;
      context.metadata['themeId'] = themeId;
    }

    final document = component.buildDocument(context.buildDocumentContext());
    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.documentXmlRelsFilePath,
        utf8.encode(document.toXmlString()),
      ),
    );

    CompilerLogger.root.debug(
      'DocumentRels built and added to archive. Theme ID: ${themeId ?? "none"}',
    );
  }
}
