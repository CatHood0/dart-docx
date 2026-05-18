import 'dart:typed_data';

import '../core/extensions/cast_ext.dart';
import 'sdk.dart';

//TODO: commonly BuildContext is basically an Element object
// so, we probably can create a context using nodes
class BuildNodeContext {
  BuildNodeContext({
    required this.options,
    required this.element,
    required this.setNormalStyleToNotStyledParagraphs,
    required this.defaultNormalStyle,
    this.noTrim = true,
    this.checkStyleRefExistence = false,
    Map<String, int>? lastNumberingIds,
    Map<Type, Store>? stores,
  }) : _stores = <Type, Store>{...?stores};

  BuildNodeContext.base({DocumentOptions? options, this.element})
      : noTrim = true,
        checkStyleRefExistence = false,
        _stores = {},
        setNormalStyleToNotStyledParagraphs = true,
        defaultNormalStyle = Style.ref('Normal'),
        options = options ?? DocumentOptions.standard(title: 'unnamed');

  BuildNodeContext.inherited(BuildNodeContext context, this.element)
      : noTrim = context.noTrim,
        _stores = context._stores,
        checkStyleRefExistence = context.checkStyleRefExistence,
        setNormalStyleToNotStyledParagraphs =
            context.setNormalStyleToNotStyledParagraphs,
        defaultNormalStyle = context.defaultNormalStyle,
        options = context.options;

  final DocxNode? element;

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  final bool setNormalStyleToNotStyledParagraphs;

  /// Determines if the paragraph will be created referencing the
  /// "Normal" style
  final Style defaultNormalStyle;

  final DocumentOptions options;

  final Map<Type, Store> _stores;

  // {filename: rid}
  MediaStore get mediaStore => getAncestorOfExactType<MediaStore>()!;
  DrawingElementCounterStore get drawingStore =>
      getAncestorOfExactType<DrawingElementCounterStore>()!;
  HyperlinkStore get hyperlinkStore =>
      getAncestorOfExactType<HyperlinkStore>()!;
  FontStore get fontStore => getAncestorOfExactType<FontStore>()!;
  NumberingStore get numberingStore =>
      getAncestorOfExactType<NumberingStore>()!;
  SdtStore get sdtStore => getAncestorOfExactType<SdtStore>()!;

  /// Determines if the run instances will be preserve its whitespaces
  /// since this confirm to the compiler to assign to every text
  /// object a "preserve" attribute
  final bool noTrim;

  final bool checkStyleRefExistence;

  DocumentStyles get docStyleSheet => options.docStyles;

  R? getAncestorOfExactType<R>() {
    if (_stores.containsKey(R)) {
      return _stores[R]?.castOrNull<R>();
    }

    DocxNode? current = element;
    CompilerLogger.root
        .debug('${current?.runtimeType}:${current?.id} will try to');
    CompilerLogger.root.debug(
      '${' ' * (current?.depth ?? 0)} | search ancestor '
      'of type $R',
    );
    if (current is R || current is DocxRoot) {
      return current is DocxRoot ? null : current as R?;
    }
    int countTries = 0;
    String lastId = current!.id;
    int loopTraverse = 0;
    while (current != null) {
      if (current is R) {
        CompilerLogger.root.debug(
          '${' ' * element!.depth} |_ $R found at ${current.depth}',
        );
        return current as R;
      }

      if (loopTraverse > 0 && lastId == current.id) {
        CompilerLogger.root.debug(
          '${' ' * element!.depth}Hit element id again. Count: $countTries -> ${countTries + 1}',
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
          '${' ' * element!.depth}Hit element ${element!.runtimeType} '
          'with id ${current.id} too many times. '
          'Breaking loop...',
        );
        return null;
      }
      loopTraverse++;
      current = current.parent;
    }
    CompilerLogger.root.debug('${' ' * element!.depth} |_ $R was not found');
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
