import 'package:xml/xml.dart';

import 'gradient_fill_options.dart';
import 'solid_fill_options.dart';

/// Options for fill style list.
class FillStyleListOptions {
  const FillStyleListOptions({
    required this.solidFill,
    required this.gradFill1,
    required this.gradFill2,
  });

  final SolidFillOptions solidFill;
  final GradientFillOptions gradFill1;
  final GradientFillOptions gradFill2;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:fillStyleLst',
      children: [
        solidFill.buildXml(),
        gradFill1.buildXml(),
        gradFill2.buildXml(),
      ],
    );
  }
}
