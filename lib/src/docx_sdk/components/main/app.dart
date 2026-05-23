import 'package:xml/xml.dart';

import '../../sdk.dart';

class DocxApp extends DocxNode<DocxNode> {
  DocxApp({
    required DocumentRelsCounterStore docRelsStore,
    required NumberingStore numberingStore,
    required MediaStore mediaStore,
    required DrawingElementCounterStore drawingStore,
    required FontStore fontStore,
    required SdtStore sdtStore,
    required HyperlinkStore hyperlinkStore,
    required DocxNode child,
    this.styles,
  })  : _sdtStore = sdtStore,
        _fontStore = fontStore,
        _drawingStore = drawingStore,
        _mediaStore = mediaStore,
        _numberingStore = numberingStore,
        _docRelsStore = docRelsStore,
        _hyperlinkStore = hyperlinkStore,
        super(
          id: 'docx_app_node',
          child: () {
            DocxNode c = Theme(
              child: child,
              styles: styles ?? DocumentStyles.base(),
            );

            c = DocumentRelsProvider(
              child: c,
              store: docRelsStore,
            );
            c = FontsProvider(
              child: c,
              store: fontStore,
            );
            c = SdtStoreProvider(
              child: c,
              store: sdtStore,
            );
            c = HyperlinksProvider(
              child: c,
              store: hyperlinkStore,
            );
            c = NumberingStoreProvider(
              child: c,
              store: numberingStore,
            );

            return DrawingCounterProvider(
              child: c,
              store: drawingStore,
            );
          }(),
        );

  final DocumentStyles? styles;
  final DocumentRelsCounterStore _docRelsStore;
  final NumberingStore _numberingStore;
  final MediaStore _mediaStore;
  final DrawingElementCounterStore _drawingStore;
  final FontStore _fontStore;
  final SdtStore _sdtStore;
  final HyperlinkStore _hyperlinkStore;

  @override
  List<XmlNode> buildXml() {
    return child.buildXml();
  }

  @override
  DocxApp get copy => DocxApp(
        docRelsStore: _docRelsStore,
        numberingStore: _numberingStore,
        mediaStore: _mediaStore,
        drawingStore: _drawingStore,
        fontStore: _fontStore,
        sdtStore: _sdtStore,
        styles: styles,
        hyperlinkStore: _hyperlinkStore,
        child: child,
      );

  @override
  DocxApp copyWith({
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return copy;
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return child.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return child.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }
}
