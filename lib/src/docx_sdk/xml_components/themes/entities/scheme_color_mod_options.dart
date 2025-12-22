import 'package:xml/xml.dart';

/// Options for a scheme color modification (e.g., tint, shade, lumMod).
class SchemeColorModOptions {
  const SchemeColorModOptions({
    this.lumMod,
    this.satMod,
    this.tint,
    this.shade,
  });

  final String? lumMod;
  final String? satMod;
  final String? tint;
  final String? shade;

  List<XmlElement> buildXml() {
    final List<XmlElement> children = [];
    if (lumMod != null) {
      children.add(
        XmlElement(
          XmlName('a:lumMod'),
          [
            XmlAttribute(
              XmlName('val'),
              lumMod!,
            ),
          ],
        ),
      );
    }
    if (satMod != null) {
      children.add(
        XmlElement(
          XmlName('a:satMod'),
          [
            XmlAttribute(
              XmlName('val'),
              satMod!,
            ),
          ],
        ),
      );
    }
    if (tint != null) {
      children.add(
        XmlElement(
          XmlName('a:tint'),
          [
            XmlAttribute(
              XmlName('val'),
              tint!,
            ),
          ],
        ),
      );
    }
    if (shade != null) {
      children.add(
        XmlElement(
          XmlName('a:shade'),
          [
            XmlAttribute(
              XmlName('val'),
              shade!,
            ),
          ],
        ),
      );
    }
    return children;
  }
}
