import 'package:xml/xml.dart';
import '../../../../../../docx.dart';
import '../../shared/effects.dart';

/// Soft edge effect applied to a shape (a:softEdge).
///
/// Blurs the edges of the shape, creating a feathered or vignette-like effect.
///
/// Useful for creating gentle transitions or dreamy visuals.
class SoftEdgeEffectComponent extends Effect<SoftEdgeEffect> {
  SoftEdgeEffectComponent({required super.data});

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:softEdge',
        attributes: <XmlAttribute>[
          XmlAttribute(
            XmlName.fromString('rad'),
            data.radius.toString(),
          ),
        ],
        isSelfClosing: true,
      ),
    ];
  }

  @override
  SoftEdgeEffectComponent get copy => SoftEdgeEffectComponent(data: data);

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxTreeNode<dynamic>>[this];
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

/// Soft edge effect configuration.
class SoftEdgeEffect {
  const SoftEdgeEffect({required this.radius});

  SoftEdgeEffect.inches({required double radius})
      : radius = radius.toEmuFromInches();

  SoftEdgeEffect.points({required double radius})
      : radius = radius.toEmuFromPoints();

  final int radius;
}
