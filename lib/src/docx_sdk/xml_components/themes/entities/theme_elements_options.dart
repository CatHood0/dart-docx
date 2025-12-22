import 'package:xml/xml.dart';

import 'color_scheme_options.dart';
import 'font_scheme_options.dart';
import 'format_scheme_options.dart';

/// Options for a theme's elements (color scheme, font scheme, format scheme).
class ThemeElementsOptions {
  const ThemeElementsOptions({
    required this.clrScheme,
    required this.fontScheme,
    required this.fmtScheme,
  });

  final ColorSchemeOptions clrScheme;
  final FontSchemeOptions fontScheme;
  final FormatSchemeOptions fmtScheme;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:themeElements',
      children: <XmlNode>[
        clrScheme.buildXml(),
        fontScheme.buildXml(),
        fmtScheme.buildXml()
      ],
    );
  }
}
