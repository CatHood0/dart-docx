import 'package:xml/xml.dart';
import '../../../../../../docx.dart';

/// Custom geometry defined by vector paths (a:custGeom).
///
/// Allows creating arbitrary shapes using a series of drawing commands
/// (moveTo, lineTo, cubicBezierTo, etc.). This is the most flexible way
/// to define shapes not available in the preset list.
class CustomGeometryComponent extends Geometry<void> {
  CustomGeometryComponent({
    required this.paths,
    required this.boundingBox,
    required this.guide,
    required this.adjustValue,
    required this.handle,
    this.connectionPoints = const <ConnectionPoint>[],
    super.id,
    super.parent,
  })  : assert(
          paths.every((ShapePath e) => e.width <= boundingBox.width),
          'All the paths provided must be have and less or same '
          'equals width from the specified in boundingBox: $boundingBox',
        ),
        assert(
          paths.every((ShapePath e) => e.height <= boundingBox.height),
          'All the paths provided must be have and less or same '
          'equals height from the specified in boundingBox: $boundingBox',
        ),
        super(child: null);

  final List<ShapePath> paths;
  final Rect boundingBox;
  final AdjustValueList adjustValue;
  final GeometryGuideList guide;
  final List<ConnectionPoint> connectionPoints;
  final HandlesList handle;

  @override
  CustomGeometryComponent get copy => CustomGeometryComponent(
        id: id,
        paths: paths,
        boundingBox: boundingBox,
        adjustValue: adjustValue,
        guide: guide,
        connectionPoints: connectionPoints,
        handle: handle,
        parent: parent,
      );

  @override
  CustomGeometryComponent copyWith({
    String? id,
    DocxNode<void>? parent,
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
      parent: parent ?? this.parent,
    );
  }

  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
    final List<XmlNode> children = <XmlNode>[
      ...adjustValue.buildXml(context: context),
      ...guide.buildXml(context: context),
      ...handle.buildXml(context: context),
    ];

    // Connection points (a:cxnLst)
    if (connectionPoints.isNotEmpty) {
      children.add(_buildConnectionList());
    } else {
      children.add(XmlElement.tag('a:cxnLst', isSelfClosing: true));
    }

    // Text rectangle (a:rect)
    children
      ..add(
        XmlElement.tag(
          'a:rect',
          attributes: <XmlAttribute>[
            XmlAttribute(XmlName.fromString('l'), boundingBox.left.toString()),
            XmlAttribute(XmlName.fromString('t'), boundingBox.top.toString()),
            XmlAttribute(XmlName.fromString('r'), boundingBox.right.toString()),
            XmlAttribute(XmlName.fromString('b'), boundingBox.bottom.toString()),
          ],
          isSelfClosing: true,
        ),
      )

      // Path list (a:pathLst)
      ..add(_buildPathList());

    return <XmlElement>[
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
            XmlAttribute(XmlName.fromString('id'), point.id.toString()),
            XmlAttribute(XmlName.fromString('x'), point.x.toString()),
            XmlAttribute(XmlName.fromString('y'), point.y.toString()),
          ],
          isSelfClosing: true,
        );
      }).toList(),
    );
  }

  XmlElement _buildPathList() {
    final List<XmlElement> pathElements = paths.map((ShapePath path) {
      final List<XmlNode> commandElements = <XmlNode>[];
      for (final PathCommand command in path.commands) {
        commandElements.addAll(command.toXml());
      }

      return XmlElement.tag(
        'a:path',
        attributes: <XmlAttribute>[
          XmlAttribute(XmlName.fromString('w'), path.width.toString()),
          XmlAttribute(XmlName.fromString('h'), path.height.toString()),
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
  List<XmlNode> buildXmlStyle({required BuildNodeContext context}) {
    return <XmlNode>[];
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
  const ShapePath({
    required this.commands,
    this.width = maxGeometryPathSize,
    this.height = maxGeometryPathSize,
    this.fill = PathFill.normal,
    this.stroke = false,
  })  : assert(
          width >= 0 && width <= maxGeometryPathSize,
          'width cannot be less than zero and major than $maxGeometryPathSize',
        ),
        assert(
          height >= 0 && height <= maxGeometryPathSize,
          'height cannot be less than zero and major than $maxGeometryPathSize',
        );

  final List<PathCommand> commands;
  final int width;
  final int height;
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
  final int x; // 0-1000000
  final int y; // 0-1000000
}
