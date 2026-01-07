import 'package:xml/xml.dart';

import '../../sdk.dart';
import 'xml_default_doc_styles_component.dart';

class XmlStylesComponent extends XmlComponentBase<void> {
  XmlStylesComponent()
      : super(
          xmlKey: 'w:styles',
          value: null,
          attrs: XmlDocAttributes(
            mc: true,
            w: true,
            w14: true,
            w15: true,
            ignorables: 'w14',
          ),
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        XmlDefaultDocStylesComponent(
          value: context.docStyleSheet,
        ).buildXml(context),
        ...context.docStyleSheet.styles
            .where(_avoidInvalidStyles)
            .map<XmlElement>((Style e) => e.toXmlNode()!),
      ],
    );
  }

  bool _avoidInvalidStyles(Style style) => !style.isInvalid;
}
