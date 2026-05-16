import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

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
    List<Object> styles = const <Object>[],
    super.parent,
    super.id,
    bool bold = false,
    bool italic = false,
    bool underline = false,
    bool strikethrough = false,
    num? fontSize,
    String? fontFamily,
    Color? color,
    Color? backgroundColor,
    bool? subscript,
    bool? superscript,
  }) : super(
          child: HyperlinkTextPart(
            text: text ?? link,
            hyperlink: link,
            styles: _buildStyles(
              baseStyles: styles,
              bold: bold,
              italic: italic,
              underline: underline,
              strikethrough: strikethrough,
              fontSize: fontSize,
              fontFamily: fontFamily,
              color: color,
              subscript: subscript,
              superscript: superscript,
            ),
          ),
        ) {
    length = child.text.length;
  }

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
            styles: _buildStyles(
              baseStyles: element.styles,
              bold: element.bold,
              italic: element.italic,
              underline: element.underline,
              strikethrough: element.strikethrough,
              fontSize: element.size,
              fontFamily: element.family,
              color: element.color,
              backgroundColor: element.backgroundColor,
              subscript: element.subscript,
              superscript: element.superscript,
            ),
          ),
        ) {
    length += child.text.length;
  }

  /// Builds the list of styles from direct properties.
  static List<Object> _buildStyles({
    required List<Object> baseStyles,
    bool bold = false,
    bool italic = false,
    bool underline = false,
    bool strikethrough = false,
    num? fontSize,
    String? fontFamily,
    Color? color,
    Color? backgroundColor,
    bool? subscript,
    bool? superscript,
  }) {
    final List<Object> allStyles = List<Object>.from(baseStyles);

    // Text formatting
    if (bold) allStyles.add(BoldAttribute());
    if (italic) allStyles.add(ItalicAttribute());
    if (underline) allStyles.add(UnderlineAttribute());
    if (strikethrough) allStyles.add(StrikeAttribute());

    // Font properties
    if (fontSize != null) allStyles.add(FontSizeAttribute(fontSize.toInt()));
    if (fontFamily != null) allStyles.add(FontFamilyAttribute(fontFamily));
    if (color != null) allStyles.add(ForegroundTextColorAttribute(color));

    // Scripts
    if (subscript == true) allStyles.add(SubscriptAttribute());
    if (superscript == true) allStyles.add(SuperscriptAttribute());

    if (backgroundColor != null)
      allStyles.add(BackgroundTextColorAttribute(
          backgroundColor.toColorValue()!.toUpperCase()));

    return allStyles;
  }

  @override
  HyperlinkRun cut(int offset, int offsetEnd) {
    final int length = math.min(dataLength, offsetEnd);
    final int start = math.min(0, offset);

    return HyperlinkRun.pure(
      link: child.hyperlink.substring(
        start,
        length,
      ),
      styles: child.styles.toList(),
      parent: parent,
    );
  }

  @override
  (HyperlinkRun, HyperlinkRun) cutTwo(int offset, int offsetEnd) {
    final int length = math.min(dataLength, offsetEnd);
    final int start = math.min(0, offset);

    return (
      HyperlinkRun.pure(
        link: child.hyperlink.substring(
          0,
          start,
        ),
        styles: child.styles.toList(),
        parent: parent,
      ),
      HyperlinkRun.pure(
        link: child.hyperlink.substring(
          start,
          length,
        ),
        styles: child.styles.toList(),
        parent: parent,
      )
    );
  }

  @override
  (HyperlinkRun, HyperlinkRun, HyperlinkRun) cutAll(int offset, int offsetEnd) {
    final int length = math.min(dataLength, offsetEnd);
    final int start = math.min(0, offset);

    return (
      HyperlinkRun.pure(
        link: child.hyperlink.substring(
          0,
          start,
        ),
        styles: child.styles.toList(),
        parent: parent,
      ),
      HyperlinkRun.pure(
        link: child.hyperlink.substring(
          start,
          length,
        ),
        styles: child.styles.toList(),
        parent: parent,
      ),
      HyperlinkRun.pure(
        link: child.hyperlink.substring(
          length,
        ),
        styles: child.styles.toList(),
        parent: parent,
      )
    );
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
    return child.hyperlink.isEmpty;
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      super.runParent(
        runProperties: buildXmlStyle(context: context),
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
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    final List<Object> styles = <Object>[...child.styles];
    if (styles.any(
        (Object e) => e is TextRunAttribution && e.scope != Scope.portion)) {
      throw Exception('The styles passed in $runtimeType are invalid. '
          'All of them must implement "Scope.portion" value');
    }
    final List<XmlElement> xmlStyles = <XmlElement>[];
    for (final Object style in styles) {
      if (style is Style && style.isInvalid) continue;
      if (style is TextRunAttribution) {
        final el = style.toXml();
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
