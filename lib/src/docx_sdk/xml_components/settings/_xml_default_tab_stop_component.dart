import 'package:xml/xml.dart';
import '../../../../../docx.dart';

/// Represents the `<w:defaultTabStop>` element in WordML settings.
class XmlDefaultTabStopComponent extends XmlComponentBase {
  XmlDefaultTabStopComponent({required String val})
      : super(
          xmlKey: 'w:defaultTabStop',
          value: null,
          attrs: Attributes(val: val),
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      attributes: attributes.buildXml(),
      isSelfClosing: true,
    );
  }
}
