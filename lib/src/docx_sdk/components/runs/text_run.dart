import 'dart:math' as math;

import 'package:xml/xml.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/extensions/style_to_from_node.dart';
import '../../compiler/inherited/compiler_config_provider.dart';
import '../../sdk.dart';

/// Basic text run element for inline text content.
///
/// Represents a run of text with consistent formatting within a paragraph.
/// Text runs can have multiple styles applied (bold, italic, color, etc.)
/// and preserve whitespace when configured.
///
/// This is the fundamental building block for text content in DOCX documents.
///
/// ## Direct Styling Properties
///
/// Instead of using the verbose `styles` parameter with attributes, you can use
/// direct styling properties for common formatting:
///
/// ```dart
/// // Using direct properties (recommended)
/// final run = TextRun.text(
///   text: 'Hello World',
///   bold: true,
///   italic: true,
///   fontSize: 24,
///   color: Color(0xFF0000FF),
/// );
///
/// // Equivalent using styles parameter
/// final run = TextRun.text(
///   text: 'Hello World',
///   styles: [
///     BoldAttribute(),
///     ItalicAttribute(),
///     FontSizeAttribute(24),
///     ForegroundTextColorAttribute(Color(0xFF0000FF)),
///   ],
/// );
/// ```
///
/// See also:
/// - [TextPart] for the text content container
/// - [RunBase] for the base class
class TextRun extends RunBase<TextPart> {
  TextRun({
    required TextPart textPart,
    this.textStyle,
    super.parent,
    super.id,
  }) : super(child: textPart) {
    length += textPart.text.length;
  }

  TextRun.text({
    required String text,
    List<Style> styles = const <Style>[],
    this.textStyle,
    super.parent,
    super.id,
  }) : super(
          child: TextPart(
            text: text,
            styles: List.from(styles),
          ),
        ) {
    length += child.text.length;
  }

  TextRun.empty({
    super.parent,
    super.id,
    this.textStyle,
  }) : super(
          child: TextPart(
            text: '',
            styles: <Style>[],
          ),
        );

  final TextStyle? textStyle;

  @override
  bool canMerge(RunBase node) =>
      node is TextRun && child.styles == node.child.styles;

  /// Regular expression to detect consecutive whitespace characters.
  static final RegExp _consecutiveWhitespacesRegExp = RegExp(r'\s{2,}');

  @override
  TextRun cut(int offset, int offsetEnd) {
    final int start = math.max(0, offset);
    final int end = math.min(dataLength, offset + offsetEnd);

    if (start >= end) return TextRun.empty();

    return TextRun.text(
      text: child._text.substring(start, end),
      styles: child.styles.toList(),
      textStyle: textStyle,
      parent: parent,
    );
  }

  @override
  (TextRun, TextRun) cutTwo(int offset, int offsetEnd) {
    final int cutPoint = math.max(0, math.min(dataLength, offset));

    final TextRun left = cutPoint > 0
        ? TextRun.text(
            text: child._text.substring(0, cutPoint),
            styles: child.styles.toList(),
            textStyle: textStyle,
            parent: parent,
          )
        : TextRun.empty();

    final TextRun right = cutPoint < dataLength
        ? TextRun.text(
            text: child._text.substring(cutPoint),
            styles: child.styles.toList(),
            textStyle: textStyle,
            parent: parent,
          )
        : TextRun.empty();

    return (left, right);
  }

  @override
  (TextRun, TextRun, TextRun) cutAll(int offset, int offsetEnd) {
    final int relativeStart = math.max(0, offset);
    final int relativeEnd = math.min(dataLength, offset + offsetEnd);
    final int cutLength = relativeEnd - relativeStart;

    final TextRun left = relativeStart > 0
        ? TextRun.text(
            text: child._text.substring(0, relativeStart),
            styles: child.styles.toList(),
            textStyle: textStyle,
            parent: parent,
          )
        : TextRun.empty();

    final TextRun center = cutLength > 0
        ? TextRun.text(
            text: child._text.substring(relativeStart, relativeEnd),
            styles: child.styles.toList(),
            textStyle: textStyle,
            parent: parent,
          )
        : TextRun.empty();

    final TextRun right = relativeEnd < dataLength
        ? TextRun.text(
            text: child._text.substring(relativeEnd),
            styles: child.styles.toList(),
            textStyle: textStyle,
            parent: parent,
          )
        : TextRun.empty();

    return (left, center, right);
  }

  @override
  bool get isEmptyData => child.text.replaceAll('\n', '').isEmpty;

  /// Determines if this text run requires whitespace preservation.
  bool get requirePreserve => _consecutiveWhitespacesRegExp.hasMatch(
        child.text,
      );

  @override
  void insertText(
    String text, {
    int? offset,
    int? path,
    List<Object>? styles,
    bool mergeStyles = true,
  }) {
    offset ??= dataLength - 1;
    child._text = child.text.replaceRange(
      offset,
      offset,
      text,
    );
    length += text.length;
  }

  @override
  void deleteText({
    required int start,
    required int length,
    int? path,
  }) {
    child._text = child.text.replaceRange(
      start,
      length,
      '',
    );
    this.length -= length;
  }

  @override
  TextRun get copy => TextRun(
        id: id,
        textPart: TextPart(
          text: child.text,
          styles: child.styles,
        ),
        textStyle: textStyle,
        parent: parent,
      );

  @override
  TextRun copyWith({
    TextPart? child,
    String? id,
    DocxNode<dynamic>? parent,
    TextStyle? textStyle,
  }) {
    return TextRun(
      id: id ?? this.id,
      textPart: child ?? this.child,
      parent: parent ?? this.parent,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  bool shouldIgnore() {
    return false;
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      super.runParent(
        runProperties: buildXmlStyle(),
        nodes: <XmlNode>[
          XmlElement.tag(
            xmlTextNode,
            attributes: <XmlAttribute>[
              if (requirePreserve ||
                  CompilerConfigProvider.of(this)?.noTrim == true)
                XmlAttribute(
                  'xml:space'.toName(),
                  'preserve',
                ),
            ],
            children: <XmlNode>[
              XmlText(child.text),
            ],
            isSelfClosing: false,
          )
        ],
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle() {
    final List<Style> styles = <Style>[...child.styles];
    //TODO: we need to apply rules that avoid runs or non block parts to have only
    // inline properties defined and show that errors as stacktraces using exceptions
    if (textStyle != null) {
      final Style? style = textStyle?.toStyle();
      if (style != null) styles.add(style);
    }
    final List<XmlElement> xmlStyles = <XmlElement>[];
    for (final Style style in styles) {
      if (style.isInvalid) continue;
      final List<XmlElement> elements = style.forRunStyle(
        useConfigurators: !style.isReference,
        shouldShowStyleRef: style.isReference,
      );
      xmlStyles.addAll(elements);
    }
    return <XmlNode>[
      ...xmlStyles,
    ];
  }

  @override
  int get dataLength => child.text.length;

  @override
  String toPlainText() {
    return child.text;
  }

  @override
  String toString() {
    return 'TextRun(id: $id, data: $child)';
  }
}

/// Container for text content and its associated styles.
///
/// This class holds the actual text string and the styles that should be
/// applied to it. It's used as the data payload for [TextRun] elements.
///
/// Note: Text cannot contain newline characters ('\n') - use separate
/// paragraphs for multi-line text.
class TextPart {
  TextPart({
    required String text,
    List<Style> styles = const <Style>[],
  })  : _text = text,
        styles = List.from(styles),
        assert(
          !text.contains('\n'),
          'text cannot '
          'contains \\n in it. Please, divide your '
          'text in multiple paragraph to avoid '
          'this error',
        );

  String _text;

  /// The text content.
  String get text => _text;

  /// All the related styles with this run
  final List<Style> styles;

  @override
  String toString() {
    return 'TextPart(data: $text, styles: $styles)';
  }
}
