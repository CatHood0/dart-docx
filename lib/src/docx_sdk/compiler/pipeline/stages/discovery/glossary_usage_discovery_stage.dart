import '../../../../sdk.dart';

/// Discovers and registers glossary entries from DocumentOptions.
///
/// This stage runs early in the pipeline (precompile phase) to transfer
/// glossary entries defined in DocumentOptions to the GlossaryStore.
class GlossaryUsageDiscoveryStage extends PipelineStage {
  const GlossaryUsageDiscoveryStage();

  @override
  String get name => 'GlossaryUsageDiscovery';

  @override
  int get order => 0;

  @override
  StageCategory get category => StageCategory.preCompile;

  @override
  String get description =>
      'Discovers and registers glossary entries from DocumentOptions.';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    final GlossaryStore store = context.getStoreOfExactType<GlossaryStore>()!;
    final List<GlossaryEntry> options = context.document.options.glossaryEntries;

    if (options.isEmpty) {
      CompilerLogger.root.debug('No glossary entries in DocumentOptions, skipping.');
      return;
    }

    CompilerLogger.root.debug(
      'Registering ${options.length} glossary entries from DocumentOptions',
    );

    for (final GlossaryEntry entry in options) {
      store.addEntry(entry);
    }

    CompilerLogger.root.debug(
      'Glossary entries registered. Total entries in store: ${store.entryCount}',
    );
  }
}
