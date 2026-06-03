import 'package:xml/xml.dart';

import 'enums.dart';

/// Options for an outer shadow effect.
class OuterShadowOptions {
  const OuterShadowOptions({
    required this.blurRad,
    required this.dist,
    required this.dir,
    required this.algn,
    required this.rotWithShape,
    required this.srgbClrVal,
    required this.alphaVal,
  });

  final String blurRad;
  final String dist;
  final String dir;
  final String algn;
  final RotWithShapeType rotWithShape;
  /// Hex color
  final String srgbClrVal;
  final String alphaVal;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:outerShdw',
      attributes: <XmlAttribute>[
        XmlAttribute(XmlName('blurRad'), blurRad),
        XmlAttribute(XmlName('dist'), dist),
        XmlAttribute(XmlName('dir'), dir),
        XmlAttribute(XmlName('algn'), algn),
        XmlAttribute(XmlName('rotWithShape'), rotWithShape.value),
      ],
      children: [
        XmlElement.tag(
          'a:srgbClr',
          attributes: <XmlAttribute>[
            XmlAttribute(
              XmlName('val'),
              srgbClrVal,
            ),
          ],
          children: <XmlNode>[
            XmlElement(
              XmlName('a:alpha'),
              [
                XmlAttribute(
                  XmlName('val'),
                  alphaVal,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
