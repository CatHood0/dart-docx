import 'package:xml/xml.dart';
import '../../../../../../docx.dart';

/// Soft edge effect applied to a shape (a:softEdge).
///
/// Blurs the edges of the shape, creating a feathered or vignette-like effect.
///
/// Useful for creating gentle transitions or dreamy visuals.
class SoftEdgeEffectComponent extends Effect<SoftEdgeEffect> {
  SoftEdgeEffectComponent({required super.child});

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'a:softEdge',
        attributes: <XmlAttribute>[
          XmlAttribute(
            XmlName.fromString('rad'),
            child.radius.toString(),
          ),
        ],
        isSelfClosing: true,
      ),
    ];
  }

  @override
  SoftEdgeEffectComponent get copy => SoftEdgeEffectComponent(child: child);

  @override
  SoftEdgeEffectComponent copyWith({
    SoftEdgeEffect? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return SoftEdgeEffectComponent(
      child: child ?? this.child,
    )..parent = parent ?? this.parent;
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxNode<dynamic>>[this];
    return null;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    return null;
  }
}

/// Soft edge effect configuration.
class SoftEdgeEffect {
  const SoftEdgeEffect({required this.radius});

  SoftEdgeEffect.inches({required double radius}) : radius = radius.inchesToEmu();

  SoftEdgeEffect.points({required double radius}) : radius = radius.ptToEmu();

  final int radius;
}
