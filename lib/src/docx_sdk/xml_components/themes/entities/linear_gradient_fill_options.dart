import 'package:xml/xml.dart';

/// Options for linear gradient fill.
class LinearGradientFillOptions {
  const LinearGradientFillOptions({
    required this.ang,
    required this.scaled,
  });

  /// Angle of the linear gradient (e.g., '5400000').
  final String ang;

  /// Scaled flag (e.g., '0').
  final String scaled;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:lin',
      attributes: [
        XmlAttribute(
          XmlName('ang'),
          ang,
        ),
        XmlAttribute(
          XmlName('scaled'),
          scaled,
        ),
      ],
    );
  }
}
