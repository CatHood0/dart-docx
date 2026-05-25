import '../../../../../../docx.dart';

/// Stage that discovers SDTs in the document.
///
/// SDTs are Word "Content Controls" (text fields, checkboxes,
/// date pickers, etc.). This stage detects all SDTs and registers
/// their IDs in [SdtStore] to avoid conflicts.
class SdtDiscoveryStage extends PipelineStage {
  const SdtDiscoveryStage();

  @override
  String get name => 'SdtDiscovery';

  @override
  int get order => 5;

  @override
  StageCategory get category => StageCategory.discovery;

  @override
  String get description => 'Detects and registers SDTs in the document.';

  @override
  bool shouldExecute(PipelineContext context) {
    return !context.flags.skipSdtDiscovery;
  }

  @override
  void execute(PipelineContext context) {
    context.emit(DocxEvent.searching(subject: 'Detecting SDTs'));
    CompilerLogger.root.debug('Initiating SDT discovery.');

    final List<Sdt>? sdts = context.document.root
        .visitAllElement(
          visitChildrenIfNeeded: true,
          (DocxNode<dynamic> el) => el is Sdt,
        )
        ?.cast<Sdt>();

    if (sdts != null &&
        sdts.isNotEmpty &&
        context.getStoreOfExactType<SdtStore>() == null) {
      throw Exception(
        'Found SDT elements inserted in tree, '
        'but not found SdtStore provided in configurations',
      );
    }

    if (sdts != null && sdts.isNotEmpty) {
      for (final sdt in sdts) {
        if (sdt.sdtId == null) {
          final int id = context
              .getStoreOfExactType<SdtStore>()!
              .getNextId(nodeId: sdt.id);
          sdt.sdtId = id;
          continue;
        }
        context.getStoreOfExactType<SdtStore>()!.registerId(
              sdt.id,
              sdt.sdtId!,
            );
      }
    }

    CompilerLogger.root.debug(
      'SDT discovery completed. '
      'Registered ${sdts?.length ?? 0} SDTs.',
    );
  }
}
