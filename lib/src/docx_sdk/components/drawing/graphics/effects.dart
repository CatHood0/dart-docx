import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../shared/effects.dart';

/// Container for visual effects applied to a shape (a:effectLst).
///
/// Can include multiple effects like shadows, glows, reflections,
/// soft edges, and 3D effects that are rendered in sequence.
class EffectList extends Effect<Iterable<DocxTreeNode>> {
  EffectList({
    required Iterable<DocxTreeNode<dynamic>> children,
  }) : super(data: children) {
    int index = 0;
    for (final DocxTreeNode<dynamic> comp in data) {
      comp
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  @override
  EffectList get copy => EffectList(
        children: data,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlNode> effectElements = <XmlNode>[];

    for (final DocxTreeNode<dynamic> child in data) {
      effectElements.addAll(child.buildXml(context: context));
    }

    return <XmlElement>[
      XmlElement.tag(
        'a:effectLst',
        children: effectElements,
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxTreeNode<dynamic>>[this];

    if (!visitChildrenIfNeeded) return null;

    final List<DocxTreeNode<dynamic>> results = <DocxTreeNode<dynamic>>[];
    for (final DocxTreeNode<dynamic> child in data) {
      final List<DocxTreeNode<dynamic>>? childResult = child.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (childResult != null) results.addAll(childResult);
    }

    return results.isNotEmpty ? results : null;
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;

    if (!visitChildrenIfNeeded) return null;

    for (final DocxTreeNode<dynamic> child in data) {
      final DocxTreeNode<dynamic>? result = child.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }

    return null;
  }
}

/// Shadow effect applied to a shape (a:outerShdw or a:innerShdw).
class ShadowEffect extends DocxTreeNode<ShadowEffectData> {
  ShadowEffect({required super.data});

  @override
  ShadowEffect get copy => ShadowEffect(data: data);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlAttribute> attributes = <XmlAttribute>[
      if (data.blur != 0)
        XmlAttribute(
          XmlName.fromString('blurRad'),
          data.blur.toString(),
        ),
      if (data.distance != 0)
        XmlAttribute(
          XmlName.fromString('dist'),
          data.distance.toString(),
        ),
      if (data.direction != 0)
        XmlAttribute(
          XmlName.fromString('dir'),
          data.direction.toString(),
        ),
    ];

    final XmlElement colorElement = XmlElement.tag(
      data.isInner ? 'a:innerShdw' : 'a:outerShdw',
      attributes: attributes,
      children: <XmlNode>[
        XmlElement.tag(
          'a:srgbClr',
          attributes: <XmlAttribute>[
            XmlAttribute(
              XmlName.fromString('val'),
              data.color.rgbValue!
                  .toRadixString(16)
                  .padLeft(6, '0')
                  .toUpperCase(),
            ),
          ],
          children: <XmlNode>[
            if (data.alpha != 100000)
              XmlElement.tag(
                'a:alpha',
                attributes: <XmlAttribute>[
                  XmlAttribute(
                      XmlName.fromString('val'), data.alpha.toString()),
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
