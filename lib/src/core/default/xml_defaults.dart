import 'package:xml/xml.dart';

/// These are all the default xml nodes that are used
class XmlDefaults {
  const XmlDefaults._();

  static XmlText text(String text) {
    return XmlText(text);
  }

  /// this is the main declaration that is used by default in xml lan
  static XmlDeclaration get declaration => XmlDeclaration(
        <XmlAttribute>[
          XmlAttribute(XmlName.fromString('version'), '1.0'),
          XmlAttribute(XmlName.fromString('encoding'), 'UTF-8'),
          XmlAttribute(XmlName.fromString('standalone'), 'yes'),
        ],
      );
}
