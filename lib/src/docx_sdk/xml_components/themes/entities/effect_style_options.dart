import 'package:xml/xml.dart';

import 'outer_shadow_options.dart';

/// Options for an effect style.
class EffectStyleOptions {
  const EffectStyleOptions({
    this.outerShadow,
  });

  final OuterShadowOptions? outerShadow;

  XmlElement buildXml() {
    final List<XmlNode> children = [];
    if (outerShadow != null) {
      children.add(outerShadow!.buildXml());
    }
    return XmlElement.tag(
      'a:effectStyle',
      children: <XmlNode>[
        XmlElement.tag(
          'a:effectLst',
          children: children,
        ),
      ],
    );
  }
}
