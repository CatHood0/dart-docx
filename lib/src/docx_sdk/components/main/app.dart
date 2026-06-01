import '../../sdk.dart';
import '../../stores/glossary_store.dart';
import '../../stores/inherited_stores/glossary_provider.dart';

class DocxStandardStores extends StatelessWidget {
  DocxStandardStores({
    required this.docRelsStore,
    required this.numberingStore,
    required this.mediaStore,
    required this.drawingStore,
    required this.fontStore,
    required this.sdtStore,
    required this.hyperlinkStore,
    required this.glossaryStore,
    required this.root,
    required this.styles,
    super.key,
  });

  final DocumentRelsCounterStore docRelsStore;
  final NumberingStore numberingStore;
  final MediaStore mediaStore;
  final DrawingElementCounterStore drawingStore;
  final FontStore fontStore;
  final SdtStore sdtStore;
  final HyperlinkStore hyperlinkStore;
  final GlossaryStore glossaryStore;
  final DocumentStyles? styles;
  final DocxNode root;

  @override
  DocxNode<dynamic> build() {
    return Theme(
      parent: this,
      styles: styles ?? DocumentStyles.base(),
      child: DrawingCounterProvider(
        store: drawingStore,
        child: NumberingStoreProvider(
          store: numberingStore,
          child: HyperlinksProvider(
            store: hyperlinkStore,
            child: SdtStoreProvider(
              store: sdtStore,
              child: GlossaryProvider(
                store: glossaryStore,
                child: FontsProvider(
                  store: fontStore,
                  child: DocumentRelsProvider(
                    store: docRelsStore,
                    child: root,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
