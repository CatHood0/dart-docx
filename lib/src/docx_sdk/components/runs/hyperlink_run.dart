import 'package:xml/xml.dart';

import '../../../core/extensions/style_to_from_node.dart';
import '../../sdk.dart';

//NOTE: probably we will need to implement internal
// link relations. See http://officeopenxml.com/WPhyperlink.php
class HyperlinkRun extends RunBase<HyperlinkTextPart> {
  HyperlinkRun({
    required super.data,
    super.parent,
    super.id,
  });

  HyperlinkRun.pure({
    required String link,
    List<Object> styles = const <Object>[],
    super.parent,
    super.id,
  }) : super(
          data: HyperlinkTextPart(
            text: link,
            hyperlink: link,
            styles: List<Object>.from(styles),
          ),
        );

  @override
  bool get isEmptyData => data.text.isEmpty;

  @override
  HyperlinkRun get copy => HyperlinkRun(
        id: id,
        data: HyperlinkTextPart(
          hyperlink: data.hyperlink,
          text: data.text,
          styles: data.styles,
        ),
        parent: parent,
      );

  @override
  bool shouldIgnore() {
    return data.hyperlink.isEmpty;
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      super.runParent(
        runProperties: buildXmlStyle(context: context),
        nodes: [
          if (data.text.isNotEmpty && data.text != '\n')
            XmlElement.tag(
              xmlTextNode,
              children: [
                XmlText(data.text.isEmpty ? data.hyperlink : data.text),
              ],
              isSelfClosing: false,
            )
        ],
      ),
    ];
  }

  @override
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    final List<Object> styles = <Object>[...data.styles];
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
    return data.text;
  }

  @override
  String toString() {
    return 'HyperlinkRun(id: $id, data: $data)';
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

class HyperlinkTextPart extends TextPart {
  HyperlinkTextPart({
    required super.text,
    required this.hyperlink,
    super.styles,
  }) : assert(linkDetectorMatcher.hasMatch(hyperlink),
            'The link: "$hyperlink" is not a valid like');
  final String hyperlink;

  @override
  String toString() {
    return 'Hyperlink(link: $hyperlink)';
  }
}
