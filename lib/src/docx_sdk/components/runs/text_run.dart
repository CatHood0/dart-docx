import 'dart:math' as math;

import 'package:xml/xml.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/extensions/style_to_from_node.dart';
import '../../sdk.dart';

/// Basic text run element for inline text content.
///
/// Represents a run of text with consistent formatting within a paragraph.
/// Text runs can have multiple styles applied (bold, italic, color, etc.)
/// and preserve whitespace when configured.
///
/// This is the fundamental building block for text content in DOCX documents.
///
/// Example usage:
/// ```dart
/// final run = TextRun.text(
///   text: 'Hello World',
///   styles: [BoldAttribute(), Style.reference('Emphasis')],
/// );
/// ```
class TextRun extends RunBase<TextPart> {
  TextRun({
    required super.child,
    super.parent,
    super.id,
  }) {
    length += child.text.length;
  }

  TextRun.text({
    required String text,
    List<Object> styles = const <Object>[],
    super.parent,
    super.id,
  }) : super(
          child: TextPart(
            text: text,
            styles: List<Object>.from(styles),
          ),
        ) {
    length += child.text.length;
  }

  TextRun.empty({
    super.parent,
    super.id,
  }) : super(
          child: TextPart(
            text: '',
            styles: <Object>[],
          ),
        );

  /// Regular expression to detect consecutive whitespace characters.
  static final RegExp _consecutiveWhitespacesRegExp = RegExp(r'\s{2,}');

  @override
  TextRun cut(int offset, int offsetEnd) {
    final int length = math.min(dataLength, offsetEnd);
    final int start = math.min(0, offset);

    return TextRun.text(
      text: child._text.substring(
        start,
        length,
      ),
      styles: child.styles.toList(),
      parent: parent,
    );
  }

  @override
  (TextRun, TextRun) cutTwo(int offset, int offsetEnd) {
    final int length = math.min(dataLength, offsetEnd);
    final int start = math.min(0, offset);

    return (
      TextRun.text(
        text: child._text.substring(
          0,
          start,
        ),
        styles: child.styles.toList(),
        parent: parent,
      ),
      TextRun.text(
        text: child._text.substring(
          start,
          length,
        ),
        styles: child.styles.toList(),
        parent: parent,
      )
    );
  }

  @override
  (TextRun, TextRun, TextRun) cutAll(int offset, int offsetEnd) {
    final int length = math.min(dataLength, offsetEnd);
    final int start = math.min(0, offset);

    return (
      TextRun.text(
        text: child._text.substring(
          0,
          start,
        ),
        styles: child.styles.toList(),
        parent: parent,
      ),
      TextRun.text(
        text: child._text.substring(
          start,
          length,
        ),
        styles: child.styles.toList(),
        parent: parent,
      ),
      TextRun.text(
        text: child._text.substring(
          length,
        ),
        styles: child.styles.toList(),
        parent: parent,
      ),
    );
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
    child._text = child.text.replaceRange(offset, offset, text);
  }

  @override
  void deleteText({
    required int start,
    required int length,
    int? path,
  }) {
    child._text = child.text.replaceRange(start, length, '');
  }

  @override
  TextRun get copy => TextRun(
        id: id,
        child: TextPart(
          text: child.text,
          styles: child.styles,
        ),
        parent: parent,
      );

  @override
  bool shouldIgnore() {
    return false;
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      super.runParent(
        runProperties: buildXmlStyle(context: context),
        nodes: <XmlNode>[
          XmlElement.tag(
            xmlTextNode,
            attributes: <XmlAttribute>[
              if (requirePreserve || context.noTrim)
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
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    final List<Object> styles = <Object>[...child.styles];
    if (styles.any(
      (Object e) => e is TextRunAttribution && e.scope != Scope.portion,
    )) {
      throw Exception('The styles passed in $runtimeType are invalid. '
          'All of them must implement "Scope.portion" value');
    }
    final List<XmlElement> xmlStyles = <XmlElement>[];
    for (final Object style in styles) {
      if (style is Style && style.isInvalid) continue;
      if (style is TextRunAttribution) {
        final XmlElement? el = style.toXml();
        if (el != null) xmlStyles.add(el);
      } else {
        final List<XmlElement> elements = (style as Style).forRunStyle(
          // only not reference styles have configurators
          useConfigurators: !style.isReference,
          shouldShowStyleRef: style.isReference,
        );
        xmlStyles.addAll(elements);
      }
    }
    return <XmlElement>[
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
    this.styles = const <Object>[],
  })  : _text = text,
        assert(
          !text.contains('\n'),
          'text cannot '
          'contains \\n in it. Please, divide your '
          'text in multiple paragraph to avoid '
          'this error',
        ),
        assert(styles.every(
          (
            Object element,
          ) =>
              element is Style || element is TextRunAttribution,
        ));

  String _text;

  /// The text content.
  String get text => _text;

  /// All the related styles with this run
  ///
  /// Only two objects are accepted:
  ///  * Style
  ///  * TextRunAttribution
  final List<Object> styles;

  @override
  String toString() {
    return 'TextPart(data: $text, styles: $styles)';
  }
}
