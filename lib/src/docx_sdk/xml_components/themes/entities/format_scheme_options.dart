import 'package:xml/xml.dart';

import 'bg_fille_style_list_options.dart';
import 'effect_style_list_options.dart';
import 'fill_style_list_options.dart';
import 'line_style_list_options.dart';

/// Options for a format scheme.
class FormatSchemeOptions {
  const FormatSchemeOptions({
    required this.name,
    required this.fillStyleLst,
    required this.lnStyleLst,
    required this.effectStyleLst,
    required this.bgFillStyleLst,
  });

  final String name;
  final FillStyleListOptions fillStyleLst;
  final LineStyleListOptions lnStyleLst;
  final EffectStyleListOptions effectStyleLst;
  final BgFillStyleListOptions bgFillStyleLst;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:fmtScheme',
      attributes: <XmlAttribute>[
        XmlAttribute(
          XmlName('name'),
          name,
        ),
      ],
      children: <XmlNode>[
        fillStyleLst.buildXml(),
        lnStyleLst.buildXml(),
        effectStyleLst.buildXml(),
        bgFillStyleLst.buildXml(),
      ],
    );
  }
}
