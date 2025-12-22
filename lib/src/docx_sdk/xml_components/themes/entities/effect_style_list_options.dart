import 'package:xml/xml.dart';

import 'effect_style_options.dart';

/// Options for effect style list.
class EffectStyleListOptions {
  const EffectStyleListOptions({
    required this.effectStyle1,
    required this.effectStyle2,
    required this.effectStyle3,
  });

  final EffectStyleOptions effectStyle1;
  final EffectStyleOptions effectStyle2;
  final EffectStyleOptions effectStyle3;

  XmlElement buildXml() {
    return XmlElement.tag(
      'a:effectStyleLst',
      children: [
        effectStyle1.buildXml(),
        effectStyle2.buildXml(),
        effectStyle3.buildXml(),
      ],
    );
  }
}
