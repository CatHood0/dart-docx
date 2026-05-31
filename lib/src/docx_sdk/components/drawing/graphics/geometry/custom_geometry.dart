import 'package:xml/xml.dart';
import '../../../../../../docx.dart';
import '../../../../../core/extensions/cast_ext.dart';

/// Custom geometry defined by vector paths (a:custGeom).
///
/// Allows creating arbitrary shapes using a series of drawing commands
/// (moveTo, lineTo, cubicBezierTo, etc.). This is the most flexible way
/// to define shapes not available in the preset list.
class CustomGeometryComponent extends Geometry<void> {
  CustomGeometryComponent({
    required this.paths,
    required this.guide,
    required this.adjustValue,
    required this.handle,
    this.boundingBox,
    this.connectionPoints = const <ConnectionPoint>[],
    super.id,
    ShapeProperties? super.parent,
  }) : super(child: null);

  factory CustomGeometryComponent.basic({
    required List<ShapePath> paths,
    String? id,
    Rect? boundingBox,
    ShapeProperties? parent,
    List<ConnectionPoint> connectionPoints = const <ConnectionPoint>[],
  }) {
    return CustomGeometryComponent(
      id: id,
      paths: paths,
      guide: GeometryGuideList(),
      adjustValue: AdjustValueList(),
      handle: HandlesList(),
      boundingBox: boundingBox,
      parent: parent,
      connectionPoints: List.from(connectionPoints),
    );
  }

  final List<ShapePath> paths;
  final Rect? boundingBox;
  final AdjustValueList adjustValue;
  final GeometryGuideList guide;
  final List<ConnectionPoint> connectionPoints;
  final HandlesList handle;

  @override
  ShapeProperties? get parent => super.parent?.castOrNull();

  @override
  CustomGeometryComponent get copy => CustomGeometryComponent(
        id: id,
        paths: paths,
        boundingBox: boundingBox,
        adjustValue: adjustValue,
        guide: guide,
        connectionPoints: connectionPoints,
        handle: handle,
        parent: parent?.castOrNull(),
      );

  @override
  CustomGeometryComponent copyWith({
    String? id,
    DocxNode? parent,
    List<ShapePath>? paths,
    Rect? boundingBox,
    AdjustValueList? adjustValue,
    GeometryGuideList? guide,
    List<ConnectionPoint>? connectionPoints,
    HandlesList? handle,
  }) {
    return CustomGeometryComponent(
      paths: paths ?? this.paths,
      boundingBox: boundingBox ?? this.boundingBox,
      adjustValue: adjustValue ?? this.adjustValue,
      guide: guide ?? this.guide,
      connectionPoints: connectionPoints ?? this.connectionPoints,
      handle: handle ?? this.handle,
      id: id ?? this.id,
      parent: parent?.castOrNull() ?? this.parent,
    );
  }

  @override
  List<XmlNode> buildXml() {
    final List<XmlNode> children = <XmlNode>[
      ...adjustValue.buildXml(),
      ...guide.buildXml(),
      ...handle.buildXml(),
    ];

    // Connection points (a:cxnLst)
    if (connectionPoints.isNotEmpty) {
      children.add(_buildConnectionList());
    } else {
      children.add(XmlElement.tag('a:cxnLst', isSelfClosing: true));
    }

    final AnnotationExtents extent = parent!.transform.extents;
    Rect? rect = boundingBox ??
        Rect(
          0,
          0,
          extent.cx.toEmu().toInt(),
          extent.cy.toEmu().toInt(),
        );

    assert(
      rect.right == extent.cx.toEmu() && rect.bottom == extent.cy.toEmu(),
      'rect.right and rect.bottom must be equals '
      'than the total size '
      'of the shape specified in the '
      'AnnotationExtents instance',
    );

    // Text rectangle (a:rect)
    children
      ..add(
        XmlElement.tag(
          'a:rect',
          attributes: <XmlAttribute>[
            XmlAttribute(
              XmlName.fromString('l'),
              rect.left.toString(),
            ),
            XmlAttribute(
              XmlName.fromString('t'),
              rect.top.toString(),
            ),
            XmlAttribute(
              XmlName.fromString('r'),
              rect.right.toString(),
            ),
            XmlAttribute(
              XmlName.fromString('b'),
              rect.bottom.toString(),
            ),
          ],
          isSelfClosing: true,
        ),
      )
      ..add(_buildPathList());

    return <XmlNode>[
      XmlElement.tag(
        'a:custGeom',
        children: children,
      ),
    ];
  }

  XmlElement _buildConnectionList() {
    return XmlElement.tag(
      'a:cxnLst',
      children: connectionPoints.map((ConnectionPoint point) {
        return XmlElement.tag(
          'a:cxn',
          attributes: <XmlAttribute>[
            XmlAttribute(
              XmlName.fromString('id'),
              point.id.toString(),
            ),
            XmlAttribute(
              XmlName.fromString('x'),
              point.x.toEmu().toString(),
            ),
            XmlAttribute(
              XmlName.fromString('y'),
              point.y.toEmu().toString(),
            ),
          ],
          isSelfClosing: true,
        );
      }).toList(),
    );
  }

  XmlElement _buildPathList() {
    final AnnotationExtents extent = parent!.transform.extents;
    final List<XmlElement> pathElements = paths.map((ShapePath path) {
      final List<XmlNode> commandElements = <XmlNode>[];
      for (final PathCommand command in path.commands) {
        commandElements.addAll(command.toXml());
      }

      return XmlElement.tag(
        'a:path',
        attributes: <XmlAttribute>[
          XmlAttribute(
            XmlName.fromString('w'),
            extent.cx.toEmu().toString(),
          ),
          XmlAttribute(
            XmlName.fromString('h'),
            extent.cy.toEmu().toString(),
          ),
          XmlAttribute(XmlName.fromString('fill'), path.fill.xmlValue),
          if (path.stroke) XmlAttribute(XmlName.fromString('stroke'), 'true'),
        ],
        children: commandElements,
      );
    }).toList();

    return XmlElement.tag(
      'a:pathLst',
      children: pathElements,
    );
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <CustomGeometryComponent>[this];
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

/// Vector path for custom geometry.
class ShapePath {
  ShapePath({
    required this.commands,
    this.fill = PathFill.normal,
    this.stroke = false,
  }) : assert(
          commands.last is ClosePathCommand,
          'commands must end with a CloseCommand instance',
        );

  final List<PathCommand> commands;
  final PathFill fill;
  final bool stroke;
}

/// Connection point for shapes.
class ConnectionPoint {
  const ConnectionPoint({
    required this.id,
    required this.x,
    required this.y,
  });

  final int id;
  final UnitValue x;
  final UnitValue y;
}
