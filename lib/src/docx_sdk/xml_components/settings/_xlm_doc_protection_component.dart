import 'package:xml/xml.dart';
import '../../../../../docx.dart';

/// Represents the `<w:documentProtection>` element in WordML settings.
class XmlDocumentProtectionComponent extends XmlComponentBase {
  XmlDocumentProtectionComponent()
      : super(
          xmlKey: 'w:documentProtection',
          value: null,
        );

  @override
  XmlElement buildXml() {
    return XmlElement.tag(xmlKey);
  }
}
