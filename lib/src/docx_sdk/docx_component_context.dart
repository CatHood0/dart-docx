import 'dart:typed_data';
import 'package:meta/meta.dart';

import 'sdk.dart';
import 'utils/logger/logger_configs.dart';
import 'xml_components/numbering/abstract_numbering_component.dart';
import 'xml_components/numbering/concrete_numbering_component.dart';

//TODO: context should behave more like BuildContext from Flutter
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
    this.checkStyleRefExistence = false,
    Map<String, int>? lastNumberingIds,
  });

  DocumentContext.base({DocumentOptions? options})
      : mediaStore = MediaStore(),
        hyperlinkStore = HyperlinkStore(),
        fontStore = FontStore(),
        noTrim = true,
        checkStyleRefExistence = false,
        drawingStore = DrawingElementCounterStore(),
        numberingStore = NumberingStore(),
        setNormalStyleToNotStyledParagraphs = true,
        defaultNormalStyle = Style.ref('Normal'),
        options = options ?? DocumentOptions.standard(title: 'unnamed');

  /// A factory designed specificaly for work during testing phases
  @visibleForTesting
  DocumentContext.test({DocumentOptions? options})
      : mediaStore = MediaStore(),
        hyperlinkStore = HyperlinkStore(),
        fontStore = FontStore(),
        noTrim = true,
        checkStyleRefExistence = false,
        drawingStore = DrawingElementCounterStore(),
        numberingStore = NumberingStore(),
        setNormalStyleToNotStyledParagraphs = true,
        defaultNormalStyle = Style.ref('Normal'),
        options = options ?? DocumentOptions.standard(title: 'unnamed'),
        registerInstance = ((String ref, int num, {int? level}) {});

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  final bool setNormalStyleToNotStyledParagraphs;

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  final Style defaultNormalStyle;
  // {filename: rid}
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

  final bool checkStyleRefExistence;

  //
  late void Function(String ref, int numId, {int? level})? registerInstance;
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

  //TODO: document context will need to be more independent
  // from its component build to allow more large lifetime
  // during compilation
  //
  // all the media are saved
  DocxNode? _currentContentPart;
  DocxNode? get currentContentPart => _currentContentPart;
  set currentContentPart(DocxNode? content) {
    if (_currentContentPart == content) return;
    _currentContentPart = content;
  }

  R? getAncestorOfExactType<R extends DocxNode<dynamic>>() {
    DocxNode? current = _currentContentPart;
    CompilerLogger.root.debug('${current?.runtimeType}:${current?.id} will try to');
    CompilerLogger.root.debug(
      '${' ' * (current?.depth ?? 0)} | search ancestor '
      'of type $R',
    );
    if (current is R || current is DocumentRoot) {
      return current is DocumentRoot ? null : current as R?;
    }
    int countTries = 0;
    String lastId = current!.id;
    int loopTraverse = 0;
    while (current != null) {
      if (current is R) {
        CompilerLogger.root.debug(
          '${' ' * _currentContentPart!.depth} |_ $R found at ${current.depth}',
        );
        return current;
      }

      if (loopTraverse > 0 && lastId == current.id) {
        CompilerLogger.root.debug(
          '${' ' * _currentContentPart!.depth}Hit element id again. Count: $countTries -> ${countTries + 1}',
        );
        countTries++;
      } else {
        lastId = current.id;
      }

      // Since at some points we could
      // have an infinite loop
      // we made these conditions to allow
      // hitting always in nodes that are being
      // repeated every time
      if (countTries > 3) {
        CompilerLogger.root.debug(
          '${' ' * _currentContentPart!.depth}Hit element ${_currentContentPart!.runtimeType} '
          'with id ${current.id} too many times. '
          'Breaking loop...',
        );
        return null;
      }
      loopTraverse++;
      current = current.parent;
    }
    CompilerLogger.root
        .debug('${' ' * _currentContentPart!.depth} |_ $R was not found');
    return null;
  }

  bool childOfAncestorOfExactType<T extends DocxNode>() {
    return getAncestorOfExactType<T>() != null;
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
