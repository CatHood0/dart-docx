import 'package:xml/xml.dart';

import 'enums.dart';
import 'gradient_stop_list_options.dart';
import 'linear_gradient_fill_options.dart';

/// Options for a gradient fill.
class GradientFillOptions {
  const GradientFillOptions({
    required this.rotWithShape,
    required this.gsLst,
    this.lin,
  });

  final RotWithShapeType rotWithShape;
  final GradientStopListOptions gsLst;
  final LinearGradientFillOptions? lin;

  XmlElement buildXml() {
    final List<XmlNode> children = [gsLst.buildXml()];
    if (lin != null) {
      children.add(lin!.buildXml());
    }
    return XmlElement.tag(
      'a:gradFill',
      attributes: <XmlAttribute>[
        XmlAttribute(
          XmlName('rotWithShape'),
          rotWithShape.value,
        ),
      ],
      children: children,
    );
  }
}
