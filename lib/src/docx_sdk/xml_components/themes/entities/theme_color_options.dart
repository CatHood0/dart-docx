import 'package:xml/xml.dart';

import 'srgb_color_options.dart';
import 'sys_color_options.dart';

/// Options for a theme color (e.g., dk1, lt1, accent1).
class ThemeColorOptions {
  const ThemeColorOptions({
    required this.xmlKey,
    this.sysClr,
    this.srgbClr,
  });

  final String xmlKey;
  final SysColorOptions? sysClr;
  final SrgbColorOptions? srgbClr;

  XmlElement buildXml() {
    final List<XmlNode> children = [];
    if (sysClr != null) {
      children.add(sysClr!.buildXml());
    }
    if (srgbClr != null) {
      children.add(srgbClr!.buildXml());
    }
    return XmlElement.tag(
      xmlKey,
      children: children,
    );
  }
}
