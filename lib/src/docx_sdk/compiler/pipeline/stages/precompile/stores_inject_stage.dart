import '../../../../../../docx.dart';
import '../../../../stores/glossary_store.dart';

class StoresInjectionStage extends PipelineStage {
  const StoresInjectionStage();

  @override
  String get name => 'StoreInjection';

  @override
  int get order => 1;

  @override
  StageCategory get category => StageCategory.preCompile;

  @override
  String get description => 'Wraps all the tree with the providers to '
      'ensure that all elements can '
      'access to them without troubles';

  @override
  bool shouldExecute(PipelineContext context) => true;

  @override
  void execute(PipelineContext context) {
    CompilerLogger.root.debug(
        'Injecting stores at element ${context.tree.runtimeType}:${context.tree.id}');
    context.tree = CompilerConfigProvider(
      options: context.options,
      normalStyleIfNeeded: context.config.normalStyleIfNeeded,
      normalStyle: context.config.normalStyle,
      noTrim: context.config.noTrim,
      checkStyleRefExistence: context.config.checkStyleRefExistence,
      child: DocxStandardStores(
        docRelsStore: context.getStoreOfExactType<DocumentRelsCounterStore>() ??
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
        glossaryStore: context.getStoreOfExactType<GlossaryStore>() ?? GlossaryStore(),
        styles: context.document.options.docStyles,
        root: context.tree,
      ),
    );
    CompilerLogger.root.debug('End inject of stores');

    if (DocxElements.instance.needsPreviousInitialization) {
      final Stopwatch watch = Stopwatch()..start();
      CompilerLogger.root.debug('Ensuring initializatin start');
      context.document.options.docStyles.index();
      context.tree.visitAllElement(
        visitChildrenIfNeeded: true,
        (DocxNode<dynamic> e) {
          e
            ..init()
            ..perform();
          return false;
        },
      );
      watch.stop();
      CompilerLogger.root.debug(
        'Ensuring initializatin end '
        'time ${watch.elapsedMilliseconds > 0 ? '${watch.elapsedMilliseconds}ms' : '${watch.elapsedMicroseconds}ns'}',
      );
    }
  }
}
