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
          XmlDefaultRunStylesComponent(value: value.docDefaultRunStyles),
        ],
        super(xmlKey: 'w:docDefaults');
  final List<XmlComponentBase> components;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
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
      styles.addAll(n.forParagraphStyle(
        shouldShowStyleRef: false,
        useConfigurators: true,
      ));
    }
    return XmlElement.tag(
      xmlKey,
      children: <XmlNode>[
        XmlElement.tag(
          xmlParagraphBlockAttrsNode,
          children: <XmlNode>[
            ...styles,
          ],
        ),
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
      styles.addAll(
        n.forRunStyle(
          shouldShowStyleRef: false,
          useConfigurators: true,
        ),
      );
    }
    return XmlElement.tag(
      xmlKey,
      isSelfClosing: false,
      children: <XmlNode>[
        XmlElement.tag(
          xmlParagraphInlineAttsrNode,
          children: <XmlNode>[
            ...styles,
          ],
        ),
      ],
    );
  }
}
