import 'dart:math' as math;

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
/// Example usage:
/// ```dart
/// final link = HyperlinkRun.pure(
///   link: 'https://example.com',
///   styles: [Style.reference('Hyperlink')],
/// );
/// ```
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

  HyperlinkRun.pure({
    required String link,
    List<Object> styles = const <Object>[],
    super.parent,
    super.id,
  }) : super(
          child: HyperlinkTextPart(
            text: link,
            hyperlink: link,
            styles: List<Object>.from(styles),
          ),
        ) {
    length = child.text.length;
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
    bool Function(DocxTreeNode element) shouldGetElement, {
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
