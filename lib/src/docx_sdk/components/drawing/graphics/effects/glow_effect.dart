import 'package:xml/xml.dart';
import '../../../../../../docx.dart';
import '../../shared/effects.dart';

/// Glow effect applied to a shape (a:glow).
///
/// Creates a colored halo around the shape, often used for emphasis or
/// to simulate light emission. The glow is typically soft and diffuse.
class GlowEffectComponent extends Effect<GlowEffect> {
  GlowEffectComponent({required super.child});

  @override
  GlowEffectComponent get copy => GlowEffectComponent(child: child.copy);

  @override
  GlowEffectComponent copyWith({
    GlowEffect? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return GlowEffectComponent(
      child: child ?? this.child.copy,
    )..parent = parent ?? this.parent;
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final XmlElement colorElement = XmlElement.tag(
      'a:glow',
      attributes: <XmlAttribute>[
        if (child.radius != 0) XmlAttribute(XmlName.fromString('rad'), child.radius.toString()),
      ],
      children: <XmlNode>[
        XmlElement.tag(
          'a:srgbClr',
          attributes: <XmlAttribute>[
            XmlAttribute(
              XmlName.fromString('val'),
              child.color.rgbValue!.toRadixString(16).padLeft(6, '0').toUpperCase(),
            ),
          ],
          children: <XmlNode>[
            if (child.transparency != 0)
              XmlElement.tag(
                'a:alpha',
                attributes: <XmlAttribute>[
                  XmlAttribute(XmlName.fromString('val'), (100000 - child.transparency).toString()),
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
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <GlowEffectComponent>[this];
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

/// Glow effect configuration.
class GlowEffect {
  const GlowEffect({
    required this.color,
    this.radius = 38100,
    this.transparency = 0,
  });

  GlowEffect.points({
    required this.color,
    double radius = 1.0,
    double transparency = 0,
  })  : radius = radius.ptToEmu(),
        transparency = transparency.ptToEmu();

  GlowEffect.inches({
    required this.color,
    //TODO: fix this
    double radius = 0.1,
    double transparency = 0,
  })  : radius = radius.inchesToEmu(),
        transparency = transparency.inchesToEmu();

  final Color color;

  /// The radius of this effect in EMU units
  final int radius;

  /// The transparency of this effect
  ///
  /// Allowed:
  /// Low: 0 (no transparent effect)
  /// High: 100000 (fully transparent)
  final int transparency;

  GlowEffect get copy => GlowEffect(
        color: color.copy,
        radius: radius,
        transparency: transparency,
      );
}
