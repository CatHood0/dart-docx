import 'package:xml/xml.dart';
import '../../../../../docx.dart';

/// Represents the `<w:decimalSymbol>` element in WordML settings.
class XmlDecimalSymbolComponent extends XmlComponentBase {
  XmlDecimalSymbolComponent({required String val})
      : super(
          xmlKey: 'w:decimalSymbol',
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
