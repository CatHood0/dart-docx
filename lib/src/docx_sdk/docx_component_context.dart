import 'dart:typed_data';
import 'sdk.dart';
import 'utils/logger/logger_configs.dart';
import 'xml_components/numbering/abstract_numbering_component.dart';
import 'xml_components/numbering/concrete_numbering_component.dart';

///TODO: we will need to pass more context info
/// and make a context for every component
/// to avoid sharing some parts and avoid
/// mutation issues
class DocumentContext {
  DocumentContext({
    required this.options,
    required this.mediaStore,
    required this.hyperlinkStore,
    required this.fontStore,
    required this.numberingStore,
    required this.setNormalStyleToNotStyledParagraphs,
    required this.defaultNormalStyle,
    required this.drawingStore,
    this.noTrim = true,
  });

  DocumentContext.base({DocumentOptions? options})
      : mediaStore = MediaStore(),
        hyperlinkStore = HyperlinkStore(),
        fontStore = FontStore(),
        noTrim = true,
        drawingStore = DrawingElementCounterStore(),
        numberingStore = NumberingStore(),
        setNormalStyleToNotStyledParagraphs = true,
        defaultNormalStyle = Style.reference('Normal'),
        options = options ?? DocumentOptions.standard(title: 'unnamed');

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  final bool setNormalStyleToNotStyledParagraphs;

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  final Style defaultNormalStyle;
  final MediaStore mediaStore;
  final DrawingElementCounterStore drawingStore;
  final DocumentOptions options;
  final HyperlinkStore hyperlinkStore;
  final FontStore fontStore;
  final NumberingStore numberingStore;

  /// Determines if the run instances will be preserve its whitespaces
  /// since this confirm to the compiler to assign to every text
  /// object a "preserve" attribute
  final bool noTrim;

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

  DocumentStyles get docStyleSheet => options.docStyles;

  // all the media are saved
  // {filename: rid}
  DocxTreeNode? _currentContentPart;
  DocxTreeNode? get currentContentPart => _currentContentPart;
  set currentContentPart(DocxTreeNode? content) {
    if (_currentContentPart == content) return;
    _currentContentPart = content;
  }

  T? getAncestorOfExactType<T extends DocxTreeNode>() {
    DocxTreeNode? current = _currentContentPart;
    CompilerLogger.root.d(
      'Searching ancestor '
      'of type ${T.toString()} from '
      'node ${current?.runtimeType}:${current?.id}',
    );
    while (current != null) {
      if (current is T) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }
}

class MediaData {
  MediaData({
    required this.name,
    required this.id,
    required this.extension,
    required this.bytes,
    required this.relationshipId,
    this.fileName = '',
  });

  // this is the rId of the image
  final String relationshipId;
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
