import 'package:xml/xml.dart';
import '../../../../../docx.dart';

/// Represents the `<w:zoom>` element in WordML settings.
class XmlZoomComponent extends XmlComponentBase {
  XmlZoomComponent({required String percent,})
      : super(
          xmlKey: 'w:zoom',
          value: null,
          attrs: XmlComponentAttributes(
            xmlAttributes: <String, Object>{
              'w:percent': percent, 
            },
          ),
        );

  @override
  XmlElement buildXml(BuildNodeContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: true,
    );
  }
}
