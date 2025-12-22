import 'package:xml/xml.dart';

import 'typeface_options.dart';

/// Options for major or minor fonts within a font scheme.
class MajorMinorFontOptions {
  const MajorMinorFontOptions({
    required this.typeface,
  });

  final TypefaceOptions typeface;

  XmlElement buildMajorFontXml() {
    return XmlElement.tag(
      'a:majorFont',
      children: <XmlNode>[
        typeface.buildLatinXml(),
        typeface.buildEastAsiaXml(),
        typeface.buildComplexScriptXml(),
      ],
    );
  }

  XmlElement buildMinorFontXml() {
    return XmlElement.tag(
      'a:minorFont',
      children: <XmlNode>[
        typeface.buildLatinXml(),
        typeface.buildEastAsiaXml(),
        typeface.buildComplexScriptXml(),
      ],
    );
  }
}
