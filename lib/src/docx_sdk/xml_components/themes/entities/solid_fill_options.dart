import 'package:xml/xml.dart';

import 'enums.dart';
import 'scheme_color_mod_options.dart';
import 'srgb_color_options.dart';
import 'sys_color_options.dart';

/// Options for a solid fill.
class SolidFillOptions {
  const SolidFillOptions({
    required this.schemeClrVal,
    this.sysClr,
    this.srgbClr,
    this.mods,
  });

  final SchemeColorType schemeClrVal;
  final SysColorOptions? sysClr;
  final SrgbColorOptions? srgbClr;
  final SchemeColorModOptions? mods;

  XmlElement buildXml() {
    final List<XmlNode> children = <XmlNode>[];
    if (sysClr != null) {
      children.add(sysClr!.buildXml());
    } else if (srgbClr != null) {
      children.add(srgbClr!.buildXml());
    } else {
      children.add(
        XmlElement.tag(
          'a:schemeClr',
          attributes: [
            XmlAttribute(
              XmlName('val'),
              schemeClrVal.value,
            ),
          ],
          children: mods?.buildXml() ?? [],
        ),
      );
    }
    return XmlElement.tag(
      'a:solidFill',
      children: children,
    );
  }
}
