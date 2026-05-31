import 'package:xml/xml.dart';

import '../../../../../docx.dart';

/// Base class for all path commands in custom geometry.
///
/// Similar to SVG path commands, these define the vector path
/// that makes up a custom shape.
abstract class PathCommand {
  const PathCommand();

  /// Converts the command to XML elements.
  List<XmlElement> toXml();
}

/// Move the drawing cursor to a new position without drawing.
class MoveToCommand extends PathCommand {
  const MoveToCommand(this.x, this.y);

  final UnitValue x;
  final UnitValue y;

  @override
  List<XmlElement> toXml() {
    assert(
      x.toEmu() >= 0 && x.toEmu() <= maxGeometryPathSize,
      'x offset must between 0 and $maxGeometryPathSize',
    );
    assert(
      y.toEmu() >= 0 && y.toEmu() <= maxGeometryPathSize,
      'y offset must between 0 and $maxGeometryPathSize',
    );
    return <XmlElement>[
      XmlElement.tag(
        'a:moveTo',
        children: <XmlNode>[
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(
                XmlName.fromString('x'),
                x.toEmu().toString(),
              ),
              XmlAttribute(
                XmlName.fromString('y'),
                y.toEmu().toString(),
              ),
            ],
            isSelfClosing: true,
          ),
        ],
      ),
    ];
  }
}

/// Draw a straight line from current position to new position.
class LineToCommand extends PathCommand {
  const LineToCommand(this.x, this.y);

  final UnitValue x;
  final UnitValue y;

  @override
  List<XmlElement> toXml() {
    assert(
      x.toEmu() >= 0 && x.toEmu() <= maxGeometryPathSize,
      'x offset must between 0 and $maxGeometryPathSize',
    );
    assert(
      y.toEmu() >= 0 && y.toEmu() <= maxGeometryPathSize,
      'y offset must between 0 and $maxGeometryPathSize',
    );
    return <XmlElement>[
      XmlElement.tag(
        'a:lnTo',
        children: <XmlNode>[
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(
                XmlName.fromString('x'),
                x.toEmu().toString(),
              ),
              XmlAttribute(
                XmlName.fromString('y'),
                y.toEmu().toString(),
              ),
            ],
            isSelfClosing: true,
          ),
        ],
      ),
    ];
  }
}

/// Draw a quadratic Bézier curve.
///
/// Uses one control point to define the curve shape.
class QuadBezToCommand extends PathCommand {
  const QuadBezToCommand(this.x1, this.y1, this.x2, this.y2);

  final UnitValue x1; // Control point X
  final UnitValue y1; // Control point Y
  final UnitValue x2; // End point X
  final UnitValue y2; // End point Y

  @override
  List<XmlElement> toXml() {
    return <XmlElement>[
      XmlElement.tag(
        'a:quadBezTo',
        children: <XmlNode>[
          // Control point
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(
                XmlName.fromString('x'),
                x1.toEmu().toString(),
              ),
              XmlAttribute(
                XmlName.fromString('y'),
                y1.toEmu().toString(),
              ),
            ],
            isSelfClosing: true,
          ),
          // End point
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(
                XmlName.fromString('x'),
                x2.toEmu().toString(),
              ),
              XmlAttribute(
                XmlName.fromString('y'),
                y2.toEmu().toString(),
              ),
            ],
            isSelfClosing: true,
          ),
        ],
      ),
    ];
  }
}

/// Draw a cubic Bézier curve.
///
/// Uses two control points to define the curve shape.
class CubicBezToCommand extends PathCommand {
  const CubicBezToCommand(
    this.x1,
    this.y1,
    this.x2,
    this.y2,
    this.x3,
    this.y3,
  );

  final UnitValue x1; // First control point X
  final UnitValue y1; // First control point Y
  final UnitValue x2; // Second control point X
  final UnitValue y2; // Second control point Y
  final UnitValue x3; // End point X
  final UnitValue y3; // End point Y

  @override
  List<XmlElement> toXml() {
    return <XmlElement>[
      XmlElement.tag(
        'a:cubicBezTo',
        children: <XmlNode>[
          // First control point
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(
                XmlName.fromString('x'),
                x1.toEmu().toString(),
              ),
              XmlAttribute(
                XmlName.fromString('y'),
                y1.toEmu().toString(),
              ),
            ],
            isSelfClosing: true,
          ),
          // Second control point
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(
                XmlName.fromString('x'),
                x2.toEmu().toString(),
              ),
              XmlAttribute(
                XmlName.fromString('y'),
                y2.toEmu().toString(),
              ),
            ],
            isSelfClosing: true,
          ),
          // End point
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(
                XmlName.fromString('x'),
                x3.toEmu().toString(),
              ),
              XmlAttribute(
                XmlName.fromString('y'),
                y3.toEmu().toString(),
              ),
            ],
            isSelfClosing: true,
          ),
        ],
      ),
    ];
  }
}

/// Draw an elliptical arc.
class ArcToCommand extends PathCommand {
  const ArcToCommand({
    required this.widthRadius,
    required this.heightRadius,
    required this.startAngle,
    required this.sweepAngle,
  });
  // Horizontal radius in geometry units
  final UnitValue widthRadius;
  // Vertical radius in geometry units
  final UnitValue heightRadius;
  // Starting angle in 60,000ths of a degree
  final Rotation startAngle;
  // Sweep angle in 60,000ths of a degree
  final Rotation sweepAngle;

  @override
  List<XmlElement> toXml() {
    return <XmlElement>[
      XmlElement.tag(
        'a:arcTo',
        attributes: <XmlAttribute>[
          XmlAttribute(
            XmlName.fromString('wR'),
            widthRadius.toEmu().toString(),
          ),
          XmlAttribute(
            XmlName.fromString('hR'),
            heightRadius.toEmu().toString(),
          ),
          XmlAttribute(
            XmlName.fromString('stAng'),
            startAngle.wordAngle.toString(),
          ),
          XmlAttribute(
            XmlName.fromString('swAng'),
            sweepAngle.wordAngle.toString(),
          ),
        ],
        isSelfClosing: true,
      ),
    ];
  }
}

/// Close the current path by drawing a line to the start point.
class ClosePathCommand extends PathCommand {
  const ClosePathCommand();

  @override
  List<XmlElement> toXml() {
    return <XmlElement>[
      XmlElement.tag(
        'a:close',
        isSelfClosing: true,
      ),
    ];
  }
}

/// Extension methods for creating common path commands.
extension PathCommandExtensions on PathCommand {
  /// Creates a horizontal line command.
  static LineToCommand horizontalLineTo(UnitValue x, UnitValue currentY) {
    return LineToCommand(x, currentY);
  }

  /// Creates a vertical line command.
  static LineToCommand verticalLineTo(UnitValue currentX, UnitValue y) {
    return LineToCommand(currentX, y);
  }

  /// Creates a relative move command from current position.
  static MoveToCommand relativeMoveTo(
    UnitValue currentX,
    UnitValue currentY,
    UnitValue dx,
    UnitValue dy,
  ) {
    return MoveToCommand(
      Emu(currentX.toEmu() + dx.toEmu()),
      Emu(currentY.toEmu() + dy.toEmu()),
    );
  }

  /// Creates a relative line command from current position.
  static LineToCommand relativeLineTo(
    UnitValue currentX,
    UnitValue currentY,
    UnitValue dx,
    UnitValue dy,
  ) {
    return LineToCommand(
      Emu(currentX.toEmu() + dx.toEmu()),
      Emu(currentY.toEmu() + dy.toEmu()),
    );
  }

  /// Creates a smooth quadratic Bézier curve (control point mirrored).
  static QuadBezToCommand smoothQuadBezTo(
    UnitValue lastControlX,
    UnitValue lastControlY,
    UnitValue x,
    UnitValue y,
  ) {
    // Mirror the previous control point
    final num currentX = x.toEmu();
    final num currentY = y.toEmu();
    final num controlX = (2 * currentX) - lastControlX.toEmu();
    final num controlY = 2 * currentY - lastControlY.toEmu();

    return QuadBezToCommand(
      Emu(controlX),
      Emu(controlY),
      Emu(currentX),
      Emu(currentY),
    );
  }

  /// Creates a smooth cubic Bézier curve (control point mirrored).
  static CubicBezToCommand smoothCubicBezTo(
    UnitValue lastControlX,
    UnitValue lastControlY,
    UnitValue x2,
    UnitValue y2,
    UnitValue x3,
    UnitValue y3,
  ) {
    final num x1 = (2 * x3.toEmu()) - lastControlX.toEmu();
    final num y1 = (2 * y3.toEmu()) - lastControlY.toEmu();

    return CubicBezToCommand(
      x1.toEmu(),
      y1.toEmu(),
      x2,
      y2,
      x3,
      y3,
    );
  }
}
