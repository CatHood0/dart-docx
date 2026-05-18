import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:xfrm
class Transform2D extends DocxNode<dynamic> {
  Transform2D({
    required this.offset,
    required this.extents,
    int rotation = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    super.id,
    super.parent,
  })  : rotation =
            rotation > 360 ? rotation : (rotation * (degressTh / 360)).toInt(),
        super(child: null);

  Transform2D.zero({
    Offset? offset,
    AnnotationExtents? extents,
    int rotation = 0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    super.id,
    super.parent,
  })  : offset = offset ?? Offset.zero(),
        extents = extents ?? AnnotationExtents.zero(),
        rotation =
            rotation > 360 ? rotation : (rotation * (degressTh / 360)).toInt(),
        super(child: null);

  Transform2D.degre90({
    Offset? offset,
    AnnotationExtents? extents,
    this.flipHorizontal = false,
    this.flipVertical = false,
    super.id,
    super.parent,
  })  : offset = offset ?? Offset.zero(),
        extents = extents ?? AnnotationExtents.zero(),
        rotation = (90 * (degressTh / 360)).toInt(),
        super(child: null);

  Transform2D.degre180({
    Offset? offset,
    AnnotationExtents? extents,
    this.flipHorizontal = false,
    this.flipVertical = false,
    super.id,
    super.parent,
  })  : offset = offset ?? Offset.zero(),
        extents = extents ?? AnnotationExtents.zero(),
        rotation = (180 * (degressTh / 360)).toInt(),
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
        parent: parent,
        id: id,
      );

  @override
  Transform2D copyWith({
    String? id,
    DocxNode<dynamic>? parent,
    Offset? offset,
    AnnotationExtents? extents,
    int? rotation,
    bool? flipHorizontal,
    bool? flipVertical,
  }) {
    return Transform2D(
      offset: offset ?? this.offset.copy,
      extents: extents ?? this.extents.copy,
      rotation: rotation ?? this.rotation,
      flipHorizontal: flipHorizontal ?? this.flipHorizontal,
      flipVertical: flipVertical ?? this.flipVertical,
      parent: parent ?? this.parent,
      id: id ?? this.id,
    );
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'a:xfrm',
        isSelfClosing: false,
        attributes: buildXmlStyle().cast<XmlAttribute>(),
        children: <XmlNode>[
          ...offset.ensureInitialized(context).buildXml(),
          ...extents.ensureInitialized(context).buildXml(),
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
  List<XmlNode> buildXmlStyle() {
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
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxNode<dynamic>>[this];
    if (!visitChildrenIfNeeded) return null;
    return offset.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        extents.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
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
