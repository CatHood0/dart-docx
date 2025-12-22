import 'package:xml/xml.dart';
import '../../../../../docx.dart';

/// Represents the `<w:characterSpacingControl>` element in WordML settings.
class XmlCharacterSpacingControlComponent extends XmlComponentBase {
  XmlCharacterSpacingControlComponent({required String val})
      : super(
          xmlKey: 'w:characterSpacingControl',
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
