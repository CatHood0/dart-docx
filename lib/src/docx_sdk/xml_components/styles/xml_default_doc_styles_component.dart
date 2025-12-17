import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/style_to_from_node.dart';

class XmlDefaultDocStylesComponent
    extends XmlComponentBase<DocumentStylesSheet> {
  XmlDefaultDocStylesComponent({required super.value})
      : components = <XmlComponentBase<dynamic>>[
          XmlDefaultParagraphStylesComponent(
            value: value.docDefaultParagraphStyles,
          ),
          XmlDefaultRunStylesComponent(value: value.docDefaultParagraphStyles),
        ],
        super(xmlKey: 'w:docDefaults');
  final List<XmlComponentBase> components;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      children: <XmlNode>[
        ...components.map((
          XmlComponentBase<dynamic> e,
        ) =>
            e.buildXml(context)),
      ],
    );
  }
}

class XmlDefaultParagraphStylesComponent extends XmlComponentBase<List<Style>> {
  XmlDefaultParagraphStylesComponent({
    required super.value,
  }) : super(xmlKey: 'w:pPrDefault');

  @override
  XmlElement buildXml(DocumentContext context) {
    final List<XmlElement> styles = <XmlElement>[];
    for (final Style n in value) {
      styles.addAll(n.toParagraphStyleNodes(
        shouldShowStyleRef: false,
      ));
    }
    return XmlElement.tag(
      xmlKey,
      children: [
        ...styles,
      ],
    );
  }
}

class XmlDefaultRunStylesComponent extends XmlComponentBase<List<Style>> {
  XmlDefaultRunStylesComponent({
    required super.value,
  }) : super(xmlKey: 'w:rPrDefault');

  @override
  XmlElement buildXml(DocumentContext context) {
    final List<XmlElement> styles = <XmlElement>[];
    for (final Style n in value) {
      styles.addAll(n.toRunStyleNodes(
        shouldShowStyleRef: false,
      ));
    }
    return XmlElement.tag(
      xmlKey,
      children: [
        ...styles,
      ],
    );
  }
}
