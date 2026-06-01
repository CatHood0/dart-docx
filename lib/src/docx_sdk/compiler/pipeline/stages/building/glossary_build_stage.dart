import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import '../../../../sdk.dart';
import '../../../../stores/glossary_store.dart';

/// Builds the glossary document (`word/glossary/document.xml`) and adds it to the archive.
///
/// This stage is responsible for:
/// - Building the glossary XML document from registered entries
/// - Adding the glossary file to the archive
///
/// The glossary is only created if there are entries registered in [GlossaryStore].
class GlossaryBuildStage extends PipelineStage {
  const GlossaryBuildStage();

  @override
  String get name => 'GlossaryBuild';

  @override
  int get order => 10;

  @override
  StageCategory get category => StageCategory.build;

  @override
  String get description => 'Build word/glossary/document.xml from registered entries.';

  @override
  bool shouldExecute(PipelineContext context) {
    final GlossaryStore store = context.getStoreOfExactType<GlossaryStore>()!;
    return store.hasEntries;
  }

  @override
  void execute(PipelineContext context) {
    CompilerLogger.root.debug('Starting $description');

    final GlossaryStore store = context.getStoreOfExactType<GlossaryStore>()!;

    if (!store.hasEntries) {
      CompilerLogger.root.debug('No glossary entries found, skipping build.');
      return;
    }

    final XmlDocument? glossaryDoc = store.buildGlossaryXmlDocument();
    if (glossaryDoc == null) {
      CompilerLogger.root.debug('Failed to build glossary document, skipping.');
      return;
    }

    context.archive.add(
      ArchiveFile.bytes(
        DocxPaths.glossaryFilePath,
        utf8.encode(glossaryDoc.toXmlString()),
      ),
    );

    CompilerLogger.root.debug(
      'Glossary document added to archive at: ${DocxPaths.glossaryFilePath}',
    );
  }
}
