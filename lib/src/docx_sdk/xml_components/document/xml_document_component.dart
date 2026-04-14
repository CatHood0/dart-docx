import 'package:xml/xml.dart';
import '../../sdk.dart';
import 'xml_body_component.dart';

class XmlDocumentComponent extends XmlComponentBase<XmlBodyComponent> {
  XmlDocumentComponent({
    required XmlBodyComponent body,
  }) : super(
          value: body,
          xmlKey: 'w:document',
          attrs: XmlDocAttributes(
            ignorables: 'w14 w15 w16',
            wpc: true,
            pic: true,
            a: true,
            mc: true,
            o: true,
            r: true,
            m: true,
            v: true,
            wp14: true,
            wp: true,
            w10: true,
            w: true,
            w14: true,
            w15: true,
            wpg: true,
            wpi: true,
            wne: true,
            wps: true,
            cx: true,
            cx1: true,
            cx2: true,
            cx3: true,
            cx4: true,
            cx5: true,
            cx6: true,
            cx7: true,
            cx8: true,
            aink: true,
            am3d: true,
            w16cex: true,
            w16cid: true,
            w16: true,
            w16sdtdh: true,
            w16se: true,
          ),
        );

  @override
  String get name => 'Document';

  @override
  String get path => DocxPaths.documentFilePath;

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      children: <XmlNode>[
        value.buildXml(context),
      ],
    );
  }
}
