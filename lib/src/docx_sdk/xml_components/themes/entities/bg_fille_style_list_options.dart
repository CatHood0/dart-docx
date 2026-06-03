import 'package:xml/xml.dart';

import 'gradient_fill_options.dart';
import 'solid_fill_options.dart';

/// Options for background fill style list.
class BgFillStyleListOptions {
  const BgFillStyleListOptions({
    required this.solidFill1,
    required this.solidFill2,
    required this.gradFill,
  });

  final SolidFillOptions solidFill1;
  final SolidFillOptions solidFill2;
  final GradientFillOptions gradFill;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:bgFillStyleLst',
      children: <XmlNode>[
        solidFill1.buildXml(),
        solidFill2.buildXml(),
        gradFill.buildXml()
      ],
    );
  }
}
