import 'package:xml/xml.dart';

/// Options for an sRGB color within a color scheme (e.g., #44546A).
class SrgbColorOptions {
  const SrgbColorOptions({
    required this.val,
  });

  /// The sRGB hexadecimal color value.
  final String val;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:srgbClr',
      attributes: [
        XmlAttribute(
          XmlName('val'),
          val,
        ),
      ],
    );
  }
}
