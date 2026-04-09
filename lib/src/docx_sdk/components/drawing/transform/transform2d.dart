import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:xfrm
class Transform2D extends DocxTreeNode<dynamic> {
  Transform2D({
    required this.offset,
    required this.extents,
    int rotation = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
  })  : rotation =
            rotation > 360 ? rotation : (rotation * (degressTh / 360)).toInt(),
        super(child: null);

  final Offset offset;
  //NOTE: maybe we should assume that the element
  // has an ancestor width sizing properties?
  // for the same goal?
  final AnnotationExtents extents;

  /// Rotation angle in 60,000ths of a degree (21600000 = 360°).
  ///
  /// You can use directly points between 1 to 360
  /// the constructor makes the transform operation
  /// to avoid making too many weird code
  final int rotation;

  /// Mirror the shape horizontally.
  final bool flipHorizontal;

  /// Mirror the shape vertically.
  final bool flipVertical;

  @override
  Transform2D get copy => Transform2D(
        offset: offset.copy,
        extents: extents.copy,
        rotation: rotation,
        flipHorizontal: flipHorizontal,
        flipVertical: flipVertical,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:xfrm',
        isSelfClosing: false,
        attributes: buildXmlStyle(context: context).cast<XmlAttribute>(),
        children: <XmlNode>[
          ...offset.buildXml(context: context),
          ...extents.buildXml(context: context),
          if (rotation != 0)
            XmlElement.tag(
              'a:rot',
              attributes: <XmlAttribute>[
                XmlAttribute(
                  XmlName.fromString('val'),
                  rotation.toString(),
                ),
              ],
              isSelfClosing: true,
            ),
        ],
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    final List<XmlAttribute> attributes = <XmlAttribute>[];

    if (flipHorizontal) {
      attributes.add(XmlAttribute(XmlName.fromString('flipH'), '1'));
    }
    if (flipVertical) {
      attributes.add(XmlAttribute(XmlName.fromString('flipV'), '1'));
    }

    return attributes;
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxTreeNode<dynamic>>[this];
    if (!visitChildrenIfNeeded) return null;
    return offset.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        extents.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return offset.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        extents.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }
}
