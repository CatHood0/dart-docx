import 'package:xml/xml.dart';

import '../sdk.dart';

class DocDefaultParagraphStyles {
  DocDefaultParagraphStyles({
    double spacing = 1.0,
    this.alignment = 'left',
    this.header,
  })  : assert(
          spacing > 200 || (spacing > 0 && spacing < 5.0),
          'spacing must be into Word standard or into the range of 1.0 to 5.0',
        ),
        assert(
          alignment == 'left' ||
              alignment == 'right' ||
              alignment == 'center' ||
              (alignment == 'both' || alignment == 'justify'),
          'alignment only supported: left, right, center, justify and both',
        ) {
    this.spacing = spacing > 200 ? spacing : spacing * kDefaultSpacing1;
  }

  DocDefaultParagraphStyles.base()
      : spacing = 1.0 * kDefaultSpacing1,
        alignment = 'left',
        header = null;

  late final double spacing;
  late final String alignment;
  late final int? header;

  //TODO: we need to add indentation, borders, and other properties
  XmlElement toNode({List<XmlNode>? defaultChildren}) {
    return XmlElement.tag(
      xmlParagraphBlockAttrsNode,
      children: <XmlNode>[...?defaultChildren],
      isSelfClosing: false,
    );
  }
}
