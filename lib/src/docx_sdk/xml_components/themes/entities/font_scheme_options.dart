import 'package:xml/xml.dart';

import 'major_minor_font_options.dart';

/// Options for a font scheme.
class FontSchemeOptions {
  const FontSchemeOptions({
    required this.name,
    required this.majorFont,
    required this.minorFont,
  });

  final String name;
  final MajorMinorFontOptions majorFont;
  final MajorMinorFontOptions minorFont;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:fontScheme',
      attributes: <XmlAttribute>[
        XmlAttribute(
          XmlName('name'),
          name,
        ),
      ],
      children: <XmlNode>[
        majorFont.buildMajorFontXml(),
        minorFont.buildMinorFontXml(),
      ],
    );
  }
}
