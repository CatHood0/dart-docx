import '../../../../sdk.dart';

/// Stage that registers numbering relationships.
///
/// This stage generates the base document relationships including
/// styles.xml, settings.xml, fontTable.xml, webSettings.xml, and
/// numbering.xml (if numbering is used).
///
/// Generated relationships are stored in [context.defaultDocRelations]
/// for use in [DocumentRelsBuildStage].
class RelationsRegistrationStage extends PipelineStage {
  const RelationsRegistrationStage();

  @override
  String get name => 'NumberingRegistration';

  @override
  int get order => 1;

  @override
  StageCategory get category => StageCategory.processing;

  @override
  String get description => 'Generates numbering relationships for document.xml.rels.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipNumberingRegistration ;
  }

  @override
  void execute(PipelineContext context) {
    final hasNumberingUsage = context.metadata['hasNumberingUsage'] as bool? ?? true;
    final applyCustomTheme = context.config.applyCustomTheme;

    // Generate base document relationships
    // Includes styles.xml, settings.xml, fontTable.xml, webSettings.xml, numbering.xml (if applicable)
    context.defaultDocRelations = XmlDocumentRelsComponent.defaultDocumentFileRelations(
      applyCustomTheme,
      context.getStoreOfExactType(),
      hasNumberingUsage,
    );

    CompilerLogger.root.debug(
      'Numbering relations registered. '
      '${context.defaultDocRelations.length} total relations.',
    );
  }
}
