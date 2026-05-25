import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../core/extensions/cast_ext.dart';
import '../../../core/extensions/skippable_iterations_ext.dart';
import '../../../core/extensions/style_to_from_node.dart';
import '../../sdk.dart';

/// Text run that contains hyperlink functionality.
///
/// Represents clickable text that links to external URLs or internal
/// document locations. Hyperlink runs can be styled like regular text
/// but also contain link metadata.
///
/// Currently supports external URLs only; internal document links
/// (bookmarks, cross-references) are planned for future implementation.
///
/// ## Direct Styling Properties
///
/// Instead of using the verbose `styles` parameter with attributes, you can use
/// direct styling properties for common formatting:
///
/// ```dart
/// // Using direct properties (recommended)
/// final link = HyperlinkRun.pure(
///   link: 'https://example.com',
///   text: 'Click here',
///   bold: true,
///   color: Color(0xFF0000FF),
/// );
///
/// // Equivalent using styles parameter
/// final link = HyperlinkRun.pure(
///   link: 'https://example.com',
///   text: 'Click here',
///   styles: [BoldAttribute(), ForegroundTextColorAttribute(Color(0xFF0000FF))],
/// );
/// ```
///
/// Example usage:
/// ```dart
/// final link = HyperlinkRun.pure(
///   link: 'https://example.com',
///   text: 'Visit our website',
///   styles: [Style.reference('Hyperlink')],
/// );
/// ```
///
/// See also:
/// - [TextRun] for general text run styling
/// - [TextPart] for text content container
//NOTE: probably we will need to implement internal
// link relations. See http://officeopenxml.com/WPhyperlink.php
class HyperlinkRun extends RunBase<HyperlinkTextPart> {
  HyperlinkRun({
    required super.child,
    super.parent,
    super.id,
  }) {
    length = child.text.length;
  }

  factory HyperlinkRun.empty() {
    return HyperlinkRun(
      child: HyperlinkTextPart(
        text: '',
        hyperlink: '',
      ),
    );
  }

  /// Creates a hyperlink with the specified URL and optional display text.
  ///
  /// The [link] parameter is the URL that will be opened when clicked.
  /// The [text] parameter is the display text shown to the user (defaults to link).
  ///
  /// ## Direct Styling Properties
  ///
  /// [bold], [italic], [underline], [strikethrough] - Text formatting
  /// [fontSize], [fontFamily], [color] - Font properties
  /// [subscript], [superscript] - Script positioning
  /// [highlight] - Background highlight color
  ///
  /// Example:
  /// ```dart
  /// HyperlinkRun.pure(
  ///   link: 'https://flutter.dev',
  ///   text: 'Flutter',
  ///   bold: true,
  ///   color: Color(0xFF0563C1),
  /// );
  /// ```
  HyperlinkRun.pure({
    required String link,
    String? text,
    List<Style> styles = const <Style>[],
    super.parent,
    super.id,
    bool bold = false,
    bool italic = false,
    bool underline = false,
    bool strikethrough = false,
    UnitValue? fontSize,
    String? fontFamily,
    Color? color,
    Color? backgroundColor,
  }) : super(
          child: HyperlinkTextPart(
            text: text ?? link,
            hyperlink: link,
            styles: <Style>[
              ...styles,
              ...TextStyle(
                bold: bold,
                italic: italic,
                underline: underline,
                strikethrough: strikethrough,
                fontSize: fontSize,
                fontFamily: fontFamily,
                fontColor: color,
                backgroundColor: backgroundColor,
              ).toStyle().toList().skipNulls<Style>(),
            ],
          ),
        ) {
    length = child.text.length;
  }

  @override
  bool canMerge(RunBase node) =>
      node is HyperlinkRun && child.styles == node.child.styles;

  @protected
  @internal
  HyperlinkRun.inheritFrom({
    required String text,
    required Text element,
    String? id,
    DocxNode? parent,
  }) : super(
          id: id ?? element.id,
          parent: parent ?? element.parent,
          child: HyperlinkTextPart(
            text: text,
            hyperlink: text,
            styles: <Style>[
              ...element.styles,
              if (element.textStyle != null)
                ...element.textStyle!.toStyle().toList().skipNulls<Style>(),
            ],
          ),
        ) {
    length += child.text.length;
  }

  @override
  HyperlinkRun cut(int offset, int offsetEnd) {
    final int start = math.max(0, offset);
    final int end = math.min(dataLength, offset + offsetEnd);

    if (start >= end) return HyperlinkRun.empty();
    final bool rawHyperlink = child.text == child.hyperlink;

    return HyperlinkRun.pure(
      link: rawHyperlink
          ? child.hyperlink.substring(start, end)
          : child.hyperlink,
      text: child.text.substring(start, end),
      styles: child.styles.toList(),
      parent: parent,
    );
  }

  @override
  (HyperlinkRun, HyperlinkRun) cutTwo(int offset, int offsetEnd) {
    final int cutPoint = math.max(0, math.min(dataLength, offset));
    final bool rawHyperlink = child.text == child.hyperlink;

    final HyperlinkRun left = cutPoint > 0
        ? HyperlinkRun.pure(
            link: rawHyperlink
                ? child.hyperlink.substring(0, cutPoint)
                : child.hyperlink,
            text: child.text.substring(0, cutPoint),
            styles: child.styles.toList(),
            parent: parent,
          )
        : HyperlinkRun.empty();

    final HyperlinkRun right = cutPoint < dataLength
        ? HyperlinkRun.pure(
            link: rawHyperlink
                ? child.hyperlink.substring(cutPoint)
                : child.hyperlink,
            text: child.text.substring(cutPoint),
            styles: child.styles.toList(),
            parent: parent,
          )
        : HyperlinkRun.empty();

    return (left, right);
  }

  @override
  (HyperlinkRun, HyperlinkRun, HyperlinkRun) cutAll(int offset, int offsetEnd) {
    final int relativeStart = math.max(0, offset);
    final int relativeEnd = math.min(dataLength, offset + offsetEnd);
    final int cutLength = relativeEnd - relativeStart;
    final bool rawHyperlink = child.text == child.hyperlink;

    final HyperlinkRun left = relativeStart > 0
        ? HyperlinkRun.pure(
            link: rawHyperlink
                ? child.hyperlink.substring(0, relativeStart)
                : child.hyperlink,
            text: child.text.substring(0, relativeStart),
            styles: child.styles.toList(),
            parent: parent,
          )
        : HyperlinkRun.empty();

    final HyperlinkRun center = cutLength > 0
        ? HyperlinkRun.pure(
            link: rawHyperlink
                ? child.hyperlink.substring(relativeStart, relativeEnd)
                : child.hyperlink,
            text: child.text.substring(relativeStart, relativeEnd),
            styles: child.styles.toList(),
            parent: parent,
          )
        : HyperlinkRun.empty();

    final HyperlinkRun right = relativeEnd < dataLength
        ? HyperlinkRun.pure(
            link: rawHyperlink
                ? child.hyperlink.substring(relativeEnd)
                : child.hyperlink,
            text: child.text.substring(relativeEnd),
            styles: child.styles.toList(),
            parent: parent,
          )
        : HyperlinkRun.empty();

    return (left, center, right);
  }

  @override
  void insertText(
    String text, {
    int? offset,
    int? path,
    List<Object>? styles,
    bool mergeStyles = true,
  }) {
    offset ??= dataLength - 1;
    child._hyperlink = child.text.replaceRange(offset, offset, text);
  }

  @override
  void deleteText({
    required int start,
    required int length,
    int? path,
  }) {
    child._hyperlink = child.text.replaceRange(start, length, '');
  }

  @override
  bool get isEmptyData => child.text.isEmpty;

  @override
  int get dataLength => child.text.length;

  @override
  HyperlinkRun get copy => HyperlinkRun(
        id: id,
        child: HyperlinkTextPart(
          hyperlink: child.hyperlink,
          text: child.text,
          styles: child.styles,
        ),
        parent: parent,
      );

  @override
  HyperlinkRun copyWith({
    HyperlinkTextPart? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return HyperlinkRun(
      id: id ?? this.id,
      child: child ?? this.child,
      parent: parent ?? this.parent,
    );
  }

  @override
  bool shouldIgnore() {
    return isEmptyNode();
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      super.runParent(
        runProperties: buildXmlStyle(),
        nodes: [
          if (child.text.isNotEmpty && child.text != '\n')
            XmlElement.tag(
              xmlTextNode,
              children: [
                XmlText(child.text.isEmpty ? child.hyperlink : child.text),
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
    final List<XmlElement> xmlStyles = <XmlElement>[];
    for (final Style style in styles) {
      if (style.isInvalid) continue;
      final List<XmlElement> elements = style.forRunStyle(
        // only not reference styles have configurators
        useConfigurators: !style.isReference,
        shouldShowStyleRef: style.isReference,
      );
      xmlStyles.addAll(elements);
    }
    return xmlStyles;
  }

  @override
  String toPlainText() {
    return child.text;
  }

  @override
  String toString() {
    return 'HyperlinkRun(id: $id, data: $child)';
  }

  @override
  HyperlinkRun? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    if (shouldGetElement(this)) return this;
    return null;
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxNode<dynamic>>[this];
    return null;
  }
}

/// Text part specialized for hyperlink content.
///
/// Extends [TextPart] with a hyperlink URL and validation to ensure
/// the URL is properly formatted.
class HyperlinkTextPart extends TextPart {
  HyperlinkTextPart({
    required super.text,
    required String hyperlink,
    super.styles,
  })  : _hyperlink = hyperlink,
        assert(linkDetectorMatcher.hasMatch(hyperlink),
            'The link: "$hyperlink" is not a valid like');

  String get hyperlink => _hyperlink;

  String _hyperlink;

  @override
  String toString() {
    return 'Hyperlink(link: $hyperlink)';
  }
}
