import 'package:xml/xml.dart';

import 'line_style_options.dart';

/// Options for line style list.
class LineStyleListOptions {
  const LineStyleListOptions({
    required this.ln1,
    required this.ln2,
    required this.ln3,
  });

  final LineStyleOptions ln1;
  final LineStyleOptions ln2;
  final LineStyleOptions ln3;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:lnStyleLst',
      children: [
        ln1.buildXml(),
        ln2.buildXml(),
        ln3.buildXml(),
      ],
    );
  }
}
