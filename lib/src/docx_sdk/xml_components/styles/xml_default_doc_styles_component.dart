import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/style_to_from_node.dart';

class XmlDefaultDocStylesComponent extends XmlComponentBase<DocumentStyles> {
  XmlDefaultDocStylesComponent({required super.value})
      : components = <XmlComponentBase<dynamic>>[
          XmlDefaultParagraphStylesComponent(
            value: value.docDefaultParagraphStyles.values.toList(),
          ),
          XmlDefaultRunStylesComponent(
            value: value.docDefaultRunStyles.values.toList(),
          ),
        ],
        super(xmlKey: 'w:docDefaults');
  final List<XmlComponentBase> components;

  @override
  XmlElement buildXml() {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: false,
      children: <XmlNode>[
        ...components.map((
          XmlComponentBase<dynamic> e,
        ) =>
            e.buildXml()),
      ],
    );
  }
}

class XmlDefaultParagraphStylesComponent extends XmlComponentBase<List<Style>> {
  XmlDefaultParagraphStylesComponent({
    required super.value,
  }) : super(xmlKey: 'w:pPrDefault');

  @override
  XmlElement buildXml() {
    final List<XmlElement> styles = <XmlElement>[];
    for (final Style n in value) {
      styles.addAll(n.forParagraphStyle(
        shouldShowStyleRef: false,
        useConfigurators: true,
      ));
    }
    return XmlElement.tag(
      xmlKey,
      isSelfClosing: false,
      children: <XmlNode>[
        XmlElement.tag(
          xmlParagraphBlockAttrsNode,
          isSelfClosing: false,
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
  XmlElement buildXml() {
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
          isSelfClosing: false,
          children: <XmlNode>[
            ...styles,
          ],
        ),
      ],
    );
  }
}
