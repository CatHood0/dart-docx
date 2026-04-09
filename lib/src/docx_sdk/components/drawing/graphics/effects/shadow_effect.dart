import 'package:xml/xml.dart';
import '../../../../../../docx.dart';
import '../../shared/effects.dart';

/// Shadow effect applied to a shape (a:outerShdw or a:innerShdw).
class ShadowEffect extends Effect<ShadowEffectData> {
  ShadowEffect({required super.child});

  @override
  ShadowEffect get copy => ShadowEffect(child: child);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlAttribute> attributes = <XmlAttribute>[
      if (child.blur != 0)
        XmlAttribute(
          XmlName.fromString('blurRad'),
          child.blur.toString(),
        ),
      if (child.distance != 0)
        XmlAttribute(
          XmlName.fromString('dist'),
          child.distance.toString(),
        ),
      if (child.direction != 0)
        XmlAttribute(
          XmlName.fromString('dir'),
          child.direction.toString(),
        ),
    ];

    final XmlElement colorElement = XmlElement.tag(
      child.isInner ? 'a:innerShdw' : 'a:outerShdw',
      attributes: attributes,
      children: <XmlNode>[
        XmlElement.tag(
          'a:srgbClr',
          attributes: <XmlAttribute>[
            XmlAttribute(
              XmlName.fromString('val'),
              child.color.rgbValue!
                  .toRadixString(16)
                  .padLeft(6, '0')
                  .toUpperCase(),
            ),
          ],
          children: <XmlNode>[
            if (child.alpha != 100000)
              XmlElement.tag(
                'a:alpha',
                attributes: <XmlAttribute>[
                  XmlAttribute(
                      XmlName.fromString('val'), child.alpha.toString()),
                ],
                isSelfClosing: true,
              ),
          ],
        ),
      ],
    );

    return <XmlElement>[colorElement];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <ShadowEffect>[this];
    if (!visitChildrenIfNeeded) return null;
    return null;
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    return null;
  }
}
