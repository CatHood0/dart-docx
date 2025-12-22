import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import 'enums.dart';
import 'solid_fill_options.dart';

/// Options for a line style.
class LineStyleOptions {
  const LineStyleOptions({
    required this.width,
    required this.cap,
    required this.cmpd,
    required this.algn,
    required this.solidFill,
    required this.prstDash,
    required this.miter,
  });

  /// The width in inches units
  final String width;
  final LineCapType cap;
  final CompoundLineType cmpd;
  final LineAlignmentType algn;
  final SolidFillOptions solidFill;
  final DashType prstDash;

  /// The Miter limit
  final String miter;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:ln',
      attributes: <XmlAttribute>[
        XmlAttribute(
          XmlName('w'),
          num.tryParse(width)!.toEmuFromInches().toString(),
        ),
        XmlAttribute(
          XmlName('cap'),
          cap.value,
        ),
        XmlAttribute(
          XmlName('cmpd'),
          cmpd.value,
        ),
        XmlAttribute(
          XmlName('algn'),
          algn.value,
        ),
      ],
      children: <XmlNode>[
        solidFill.buildXml(),
        XmlElement(
          XmlName('a:prstDash'),
          <XmlAttribute>[
            XmlAttribute(
              XmlName('val'),
              prstDash.value,
            ),
          ],
        ),
        XmlElement(
          XmlName('a:miter'),
          <XmlAttribute>[
            XmlAttribute(
              XmlName('lim'),
              miter,
            ),
          ],
        ),
      ],
    );
  }
}
