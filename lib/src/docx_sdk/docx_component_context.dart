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
  });

  DocumentContext.base({DocumentOptions? options})
      : store = MediaStore(),
        hyperlinkStore = HyperlinkStore(),
        fontStore = FontStore(),
        numberingStore = NumberingStore(),
        options = options ?? DocumentOptions.blank(title: 'unnamed');

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
  DocxContent? _currentContentPart;
  DocxContent? get currentContentPart => _currentContentPart?.copy;
  set currentContentPart(DocxContent? content) {
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
  });

  // this is the rId of the image
  final String imageRefId;
  final Uint8List bytes;
  // the name of the image into DOCX file
  final String name;
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
