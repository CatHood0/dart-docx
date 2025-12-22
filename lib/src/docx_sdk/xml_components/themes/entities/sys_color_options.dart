import 'package:xml/xml.dart';

import 'enums.dart';

/// Options for a system color within a color scheme (e.g., windowText).
class SysColorOptions {
  const SysColorOptions({
    required this.val,
    required this.lastClr,
  });

  /// The value of the system color.
  final SysColorValue val;

  /// The last color used (hex value).
  final String lastClr;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:sysClr',
      attributes: <XmlAttribute>[
        XmlAttribute(
          XmlName('val'),
          val.value,
        ),
        XmlAttribute(
          XmlName('lastClr'),
          lastClr,
        ),
      ],
    );
  }
}
