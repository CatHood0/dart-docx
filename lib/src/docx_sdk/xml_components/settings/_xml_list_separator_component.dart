import 'package:xml/xml.dart';
import '../../../../../docx.dart';

/// Represents the `<w:listSeparator>` element in WordML settings.
class XmlListSeparatorComponent extends XmlComponentBase {
  XmlListSeparatorComponent({required String val})
      : super(
          xmlKey: 'w:listSeparator',
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
