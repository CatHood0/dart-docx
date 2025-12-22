import 'package:xml/xml.dart';

import 'theme_color_options.dart';

/// Options for a color scheme.
class ColorSchemeOptions {
  const ColorSchemeOptions({
    required this.name,
    required this.dk1,
    required this.lt1,
    required this.dk2,
    required this.lt2,
    required this.accent1,
    required this.accent2,
    required this.accent3,
    required this.accent4,
    required this.accent5,
    required this.accent6,
    required this.hlink,
    required this.folHlink,
  });

  final String name;
  final ThemeColorOptions dk1;
  final ThemeColorOptions lt1;
  final ThemeColorOptions dk2;
  final ThemeColorOptions lt2;
  final ThemeColorOptions accent1;
  final ThemeColorOptions accent2;
  final ThemeColorOptions accent3;
  final ThemeColorOptions accent4;
  final ThemeColorOptions accent5;
  final ThemeColorOptions accent6;
  final ThemeColorOptions hlink;
  final ThemeColorOptions folHlink;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:clrScheme',
      attributes: <XmlAttribute>[
        XmlAttribute(
          XmlName('name'),
          name,
        ),
      ],
      children: <XmlNode>[
        dk1.buildXml(),
        lt1.buildXml(),
        dk2.buildXml(),
        lt2.buildXml(),
        accent1.buildXml(),
        accent2.buildXml(),
        accent3.buildXml(),
        accent4.buildXml(),
        accent5.buildXml(),
        accent6.buildXml(),
        hlink.buildXml(),
        folHlink.buildXml(),
      ],
    );
  }
}
