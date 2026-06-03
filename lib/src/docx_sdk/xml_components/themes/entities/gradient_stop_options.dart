import 'package:xml/xml.dart';

import 'enums.dart';
import 'scheme_color_mod_options.dart';
import 'srgb_color_options.dart';
import 'sys_color_options.dart';

/// Options for a gradient stop within a gradient fill.
class GradientStopOptions {
  const GradientStopOptions({
    required this.pos,
    required this.schemeClrVal,
    this.sysClr,
    this.srgbClr,
    this.mods,
  });

  /// Position of the gradient stop (e.g., '0', '50000', '100000').
  final String pos;

  /// The scheme color value for this stop.
  final SchemeColorType schemeClrVal;

  /// Optional system color (if not using scheme color).
  final SysColorOptions? sysClr;

  /// Optional sRGB color (if not using scheme color).
  final SrgbColorOptions? srgbClr;

  /// Modifications to the scheme color.
  final SchemeColorModOptions? mods;

  XmlElement buildXml() {
    final List<XmlNode> children = [];
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
          children: mods?.buildXml() ?? <XmlNode>[],
        ),
      );
    }

    return XmlElement.tag(
      'a:gs',
      attributes: [
        XmlAttribute(
          XmlName('pos'),
          pos,
        ),
      ],
      children: children,
    );
  }
}
