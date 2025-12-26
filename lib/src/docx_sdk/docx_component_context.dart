import 'dart:typed_data';
import 'sdk.dart';
import 'stores/font_store.dart';
import 'stores/numbering_store.dart';
import 'xml_components/numbering/abstract_numbering_component.dart';
import 'xml_components/numbering/concrete_numbering_component.dart';

class DocumentContext {
  DocumentContext({
    required this.options,
    required this.store,
    required this.hyperlinkStore,
    required this.fontStore,
    required this.numberingStore,
    required this.setNormalStyleToNotStyledParagraphs,
    required this.defaultNormalStyle,
  });

  DocumentContext.base({DocumentOptions? options})
      : store = MediaStore(),
        hyperlinkStore = HyperlinkStore(),
        fontStore = FontStore(),
        numberingStore = NumberingStore(),
        setNormalStyleToNotStyledParagraphs = true,
        defaultNormalStyle = Style.reference('Normal'),
        options = options ?? DocumentOptions.blank(title: 'unnamed');

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  final bool setNormalStyleToNotStyledParagraphs;

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  final Style defaultNormalStyle;
  final MediaStore store;
  final DocumentOptions options;
  final HyperlinkStore hyperlinkStore;
  final FontStore fontStore;
  final NumberingStore numberingStore;

  //
  late void Function(String ref, int numId)? registerInstance;
  late Iterable<XmlAbstractNumComponent> Function()?
      getAbstractNumberingTemplates;
  late Iterable<XmlConcreteNumberingComponent> Function()?
      getConcreteNumberingInstances;
  late XmlAbstractNumComponent? Function(String ref)? getAbstractNumbering;
  late XmlConcreteNumberingComponent? Function(String ref)?
      getConcreteNumbering;
  late num? Function(String ref)? getAbstractNumId;
  late num? Function(String ref)? getConcreteNumId;

  DocumentStylesSheet get docStyleSheet => options.docStyles;

  // all the media are saved
  // {filename: rid}
  DocxTreeNode? _currentContentPart;
  DocxTreeNode? get currentContentPart => _currentContentPart;
  set currentContentPart(DocxTreeNode? content) {
    if (_currentContentPart == content) return;
    _currentContentPart = content;
  }
}

class MediaData {
  MediaData({
    required this.name,
    required this.id,
    required this.extension,
    required this.bytes,
    required this.imageRefId,
    this.fileName = '',
  });

  // this is the rId of the image
  final String imageRefId;
  final Uint8List bytes;
  // the name of the image into DOCX file
  final String name;
  // the name of the image into the media folder 
  final String fileName;
  // this id is auto-generated
  // to be pasted
  final int id;
  // the extension of this media
  final String extension;

  @override
  String toString() {
    return 'MediaData(name: $name.$extension, id: $id)';
  }
}
