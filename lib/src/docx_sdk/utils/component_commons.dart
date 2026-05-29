import 'package:xml/xml.dart';

import '../sdk.dart';

enum MainAxisAlignment {
  start('start'),
  center('center'),
  spaceBetween('spaceBetween'),
  end('end');

  const MainAxisAlignment(this.value);

  //TODO: we need to manage RTL
  Alignment align() {
    return switch (this) {
      start => Alignment.left,
      center => Alignment.center,
      end => Alignment.right,
      _ => Alignment.left,
    };
  }

  Alignment reversed() {
    return switch (this) {
      start => Alignment.right,
      center => Alignment.center,
      end => Alignment.left,
      _ => Alignment.right,
    };
  }

  final String value;
}

enum CrossAxisAlignment {
  start('start'),
  center('center'),
  end('end');

  const CrossAxisAlignment(this.value);

  VerticalAlignment vertical() {
    return switch (this) {
      start => VerticalAlignment.top,
      center => VerticalAlignment.center,
      end => VerticalAlignment.bottom,
    };
  }

  final String value;
}

enum BorderAlignment {
  /// Appears directly above the shape
  top('top'),

  /// Appears directly below the shape (most common)
  bottom('bottom'),

  /// Appears to the left of the shape
  left('left'),

  /// Appears to the right of the shape
  right('right'),

  /// Appears above and to the left of the shape
  topLeft('topLeft'),

  /// Appears above and to the right of the shape
  topRight('topRight'),

  /// Appears below and to the left of the shape
  bottomLeft('bottomLeft'),

  /// Appears below and to the right of the shape
  bottomRight('bottomRight');

  const BorderAlignment(this.xmlValue);

  /// The value used in DOCX XML `algn` attribute.
  final String xmlValue;

  /// Whether this alignment is a corner position (diagonal).
  bool get isCorner => const {
        BorderAlignment.topLeft,
        BorderAlignment.topRight,
        BorderAlignment.bottomLeft,
        BorderAlignment.bottomRight,
      }.contains(this);

  /// Whether this alignment is an edge position (straight).
  bool get isEdge => const {
        BorderAlignment.top,
        BorderAlignment.bottom,
        BorderAlignment.left,
        BorderAlignment.right,
      }.contains(this);

  /// Calculates the reflection offset in geometry units (0-1000000).
  /// Returns (offsetX, offsetY) where 0,0 is shape center.
  (int offsetX, int offsetY) get geometryOffset {
    return switch (this) {
      BorderAlignment.top => (0, -1000000),
      BorderAlignment.bottom => (0, 1000000),
      BorderAlignment.left => (-1000000, 0),
      BorderAlignment.right => (1000000, 0),
      BorderAlignment.topLeft => (-1000000, -1000000),
      BorderAlignment.topRight => (1000000, -1000000),
      BorderAlignment.bottomLeft => (-1000000, 1000000),
      BorderAlignment.bottomRight => (1000000, 1000000),
    };
  }

  /// Gets the angle in degrees for reflection direction.
  double get angleInDegrees {
    return switch (this) {
      BorderAlignment.top => 270.0,
      BorderAlignment.bottom => 90.0,
      BorderAlignment.left => 180.0,
      BorderAlignment.right => 0.0,
      BorderAlignment.topLeft => 225.0,
      BorderAlignment.topRight => 315.0,
      BorderAlignment.bottomLeft => 135.0,
      BorderAlignment.bottomRight => 45.0,
    };
  }

  /// Gets the angle in 60,000ths of a degree for DOCX XML.
  int get angleInSixtyThousandths {
    return (angleInDegrees * (60000 / 360)).round();
  }
}

enum UniversalAlignment {
  left,
  center,
  right,
  top,
  middle,
  bottom,
}

enum TextAlign {
  /// left align text
  left('left'),

  /// center align text
  center('center'),

  /// Right align text
  right('right'),

  /// Justify align text
  justify('both');

  const TextAlign(this.value);

  bool isCenterLeftOrRight() => this == left || this == right || this == center;

  Alignment get toAlign => switch (this) {
        left => Alignment.left,
        right => Alignment.right,
        center => Alignment.center,
        justify => Alignment.both,
      };

  final String value;
}

/// Represents the horizontal alignment options
enum Alignment {
  /// left align text
  left('left'),

  /// center align text
  center('center'),

  /// Right align text
  right('right'),

  /// Justify align text
  both('both'),

  /// Like both but also distributes the last line
  /// Useful for vertical text in East Asian languages
  distribute('distribute'),

  /// Arabic justification using medium kashida elongations
  mediumKashida('mediumKashida'),

  /// Arabic justification using big kashida elongations
  highKashida('highKashida'),

  /// Arabic justification using short kashida elongations
  lowKashida('lowKashida'),

  /// Distribution special for Thai script
  thaiDistribute('thaiDistribute');

  const Alignment(this.value);

  bool isCenterLeftOrRight() => this == left || this == right || this == center;

  final String value;
}

/// Represents the common vertical alignment options
enum VerticalAlignment {
  top('top'),
  center('center'),
  middle('middle'),
  bottom('bottom');

  const VerticalAlignment(this.xmlValue);
  final String xmlValue;
}

/// Represents the vertical alignment options for text (subscript or superscript).
enum Script {
  subscript('subscript'),
  superscript('superscript');

  const Script(this.name);
  final String name;
}

enum LineRule {
  atLeast('atLeast'),
  exact('exact'),
  auto('auto');

  /// Creates a [LineRule] with its corresponding WordML value.
  const LineRule(this.value);

  /// The WordML string value for the spacing style.
  final String value;
}

/// Represents the possible shading patterns for a paragraph.
enum ShadingPattern {
  clear('clear'),
  solid('solid'),
  horzStripe('horzStripe'),
  vertStripe('vertStripe'),
  fwdDiagStripe('fwdDiagStripe'),
  bkwdDiagStripe('bkwdDiagStripe'),
  horzCross('horzCross'),
  diagCross('diagCross'),
  pct10('pct10'),
  pct20('pct20'),
  pct30('pct30'),
  pct40('pct40'),
  pct50('pct50'),
  pct60('pct60'),
  pct70('pct70'),
  pct80('pct80'),
  pct90('pct90');

  const ShadingPattern(this.value);
  final String value;
}

/// Represents the possible border styles for a paragraph.
enum BorderStyle {
  single('single'),
  dashDot('dashDot'),
  dashDotStroked('dashDotStroked'),
  dashed('dashed'),
  dotDash('dotDash'),
  dotDotDash('dotDotDash'),
  dotted('dotted'),
  double('double'),
  doubleWave('doubleWave'),
  inset('inset'),
  nil('nil'), // No border
  none('none'), // No border
  outset('outset'),
  thick('thick'),
  thickThinLargeGap('thickThinLargeGap'),
  thickThinMediumGap('thickThinMediumGap'),
  thickThinSmallGap('thickThinSmallGap'),
  thinThickLargeGap('thinThickLargeGap'),
  thinThickMediumGap('thinThickMediumGap'),
  thinThickSmallGap('thinThickSmallGap'),
  thinThickThinLargeGap('thinThickThinLargeGap'),
  thinThickThinMediumGap('thinThickThinMediumGap'),
  thinThickThinSmallGap('thinThickThinSmallGap'),
  threeDColumn('threeDColumn'),
  threeDEmboss('threeDEmboss'),
  threeDEngrave('threeDEngrave'),
  triple('triple'),
  wave('wave');

  /// Creates a [BorderStyle] with its corresponding WordML value.
  const BorderStyle(this.value);

  /// The WordML string value for the border style.
  final String value;
}

/// Pattern types for shape fill (a:pattFill).
///
/// Defines the visual pattern used to fill a shape, similar to
/// hatch patterns in CAD or background patterns in design tools.
enum PatternType {
  /// 5% density pattern
  percent5('pct5'),

  /// 10% density pattern
  percent10('pct10'),

  /// 20% density pattern
  percent20('pct20'),

  /// 25% density pattern
  percent25('pct25'),

  /// 30% density pattern
  percent30('pct30'),

  /// 40% density pattern
  percent40('pct40'),

  /// 50% density pattern (half-tone)
  percent50('pct50'),

  /// 60% density pattern
  percent60('pct60'),

  /// 70% density pattern
  percent70('pct70'),

  /// 75% density pattern
  percent75('pct75'),

  /// 80% density pattern
  percent80('pct80'),

  /// 90% density pattern
  percent90('pct90'),

  /// Dark horizontal lines
  darkHorizontal('dkHorz'),

  /// Dark vertical lines
  darkVertical('dkVert'),

  /// Dark downward diagonal lines (from top-left to bottom-right)
  darkDownwardDiagonal('dkDnDiag'),

  /// Dark upward diagonal lines (from bottom-left to top-right)
  darkUpwardDiagonal('dkUpDiag'),

  /// Dark grid pattern (horizontal and vertical lines)
  darkGrid('dkGrid'),

  /// Dark trellis pattern (diagonal grid)
  darkTrellis('dkTrellis'),

  /// Light horizontal lines
  lightHorizontal('ltHorz'),

  /// Light vertical lines
  lightVertical('ltVert'),

  /// Light downward diagonal lines
  lightDownwardDiagonal('ltDnDiag'),

  /// Light upward diagonal lines
  lightUpwardDiagonal('ltUpDiag'),

  /// Light grid pattern
  lightGrid('ltGrid'),

  /// Light trellis pattern
  lightTrellis('ltTrellis'),

  /// Narrow horizontal lines
  narrowHorizontal('narHorz'),

  /// Narrow vertical lines
  narrowVertical('narVert'),

  /// Narrow downward diagonal lines
  narrowDownwardDiagonal('narDnDiag'),

  /// Narrow upward diagonal lines
  narrowUpwardDiagonal('narUpDiag'),

  /// Dashed downward diagonal lines
  dashedDownwardDiagonal('dashDnDiag'),

  /// Dashed upward diagonal lines
  dashedUpwardDiagonal('dashUpDiag'),

  /// Dashed horizontal lines
  dashedHorizontal('dashHorz'),

  /// Dashed vertical lines
  dashedVertical('dashVert'),

  /// Small confetti pattern
  smallConfetti('smConfetti'),

  /// Large confetti pattern
  largeConfetti('lgConfetti'),

  /// Zigzag pattern
  zigZag('zigZag'),

  /// Wave pattern
  wave('wave'),

  /// Diagonal brick pattern
  diagonalBrick('diagBrick'),

  /// Horizontal brick pattern
  horizontalBrick('horzBrick'),

  /// Weave pattern
  weave('weave'),

  /// Plaid pattern
  plaid('plaid'),

  /// Divot pattern (small dots in grid)
  divot('divot'),

  /// Dotted grid pattern
  dottedGrid('dotGrid'),

  /// Dotted diamond pattern
  dottedDiamond('dotDmnd'),

  /// Shingle pattern (overlapping arcs)
  shingle('shingle'),

  /// Sphere pattern (circles)
  sphere('sphere'),

  /// Small grid pattern
  smallGrid('smGrid'),

  /// Large grid pattern
  largeGrid('lgGrid'),

  /// Small checkerboard pattern
  smallCheckerBoard('smCheck'),

  /// Large checkerboard pattern
  largeCheckerBoard('lgCheck'),

  /// Outlined diamond pattern
  outlinedDiamond('openDmnd'),

  /// Solid diamond pattern
  solidDiamond('solidDmnd');

  const PatternType(this.xmlValue);

  /// The value used in DOCX XML `prst` attribute.
  final String xmlValue;
}

/// How a path in custom geometry should be filled.
///
/// Controls whether the interior of a path is filled and how it interacts
/// with other paths in the same geometry.
enum PathFill {
  /// Normal fill - path interior is filled with the shape's fill color
  normal('norm'),

  /// No fill - path is only an outline, interior is transparent
  none('none'),

  /// Outline only - similar to none but affects stroke rendering
  outline('outline'),

  /// Background fill - path fills areas not covered by other paths
  background('background');

  const PathFill(this.xmlValue);

  /// The value used in DOCX XML `fill` attribute.
  final String xmlValue;
}

/// Material types for 3D effects.
///
/// Defines the surface material properties for 3D shapes,
/// affecting how light interacts with the surface.
enum PresetMaterial {
  /// Plastic material (matte finish)
  plastic('plastic'),

  /// Metallic material (shiny reflective surface)
  metal('metal'),

  /// Matte material (non-reflective)
  matte('matte'),

  /// Warm matte (slightly warmer tone)
  warmMatte('warmMatte'),

  /// Translucent powder (frosted glass effect)
  translucentPowder('translucentPowder'),

  /// Powder coating (soft matte finish)
  powder('powder'),

  /// Dark edge material (edges are darker)
  darkEdge('dkEdge'),

  /// Soft edge material (edges are softened)
  softEdge('softEdge'),

  /// Clear material (transparent/glass-like)
  clear('clear'),

  /// Flat material (no shading)
  flat('flat'),

  /// Soft metal (slightly reflective metal)
  softmetal('softmetal');

  const PresetMaterial(this.xmlValue);

  /// The value used in DOCX XML `prstMaterial` attribute.
  final String xmlValue;
}

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
  const MoveToCommand(this.x, this.y)
      : assert(
          x >= 0 && x <= maxGeometryPathSize,
          'x offset must between 0 and $maxGeometryPathSize',
        ),
        assert(
          y >= 0 && y <= maxGeometryPathSize,
          'y offset must between 0 and $maxGeometryPathSize',
        );

  final int x;
  final int y;

  @override
  List<XmlElement> toXml() {
    return <XmlElement>[
      XmlElement.tag(
        'a:moveTo',
        children: <XmlNode>[
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(XmlName.fromString('x'), x.toString()),
              XmlAttribute(XmlName.fromString('y'), y.toString()),
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

  final int x; // 0-1000000
  final int y; // 0-1000000

  @override
  List<XmlElement> toXml() {
    return <XmlElement>[
      XmlElement.tag(
        'a:lnTo',
        children: <XmlNode>[
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(XmlName.fromString('x'), x.toString()),
              XmlAttribute(XmlName.fromString('y'), y.toString()),
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

  final int x1; // Control point X
  final int y1; // Control point Y
  final int x2; // End point X
  final int y2; // End point Y

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
              XmlAttribute(XmlName.fromString('x'), x1.toString()),
              XmlAttribute(XmlName.fromString('y'), y1.toString()),
            ],
            isSelfClosing: true,
          ),
          // End point
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(XmlName.fromString('x'), x2.toString()),
              XmlAttribute(XmlName.fromString('y'), y2.toString()),
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

  final int x1; // First control point X
  final int y1; // First control point Y
  final int x2; // Second control point X
  final int y2; // Second control point Y
  final int x3; // End point X
  final int y3; // End point Y

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
              XmlAttribute(XmlName.fromString('x'), x1.toString()),
              XmlAttribute(XmlName.fromString('y'), y1.toString()),
            ],
            isSelfClosing: true,
          ),
          // Second control point
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(XmlName.fromString('x'), x2.toString()),
              XmlAttribute(XmlName.fromString('y'), y2.toString()),
            ],
            isSelfClosing: true,
          ),
          // End point
          XmlElement.tag(
            'a:pt',
            attributes: <XmlAttribute>[
              XmlAttribute(XmlName.fromString('x'), x3.toString()),
              XmlAttribute(XmlName.fromString('y'), y3.toString()),
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

  final int widthRadius; // Horizontal radius in geometry units
  final int heightRadius; // Vertical radius in geometry units
  final int startAngle; // Starting angle in 60,000ths of a degree
  final int sweepAngle; // Sweep angle in 60,000ths of a degree

  @override
  List<XmlElement> toXml() {
    return <XmlElement>[
      XmlElement.tag(
        'a:arcTo',
        attributes: <XmlAttribute>[
          XmlAttribute(XmlName.fromString('wR'), widthRadius.toString()),
          XmlAttribute(XmlName.fromString('hR'), heightRadius.toString()),
          XmlAttribute(XmlName.fromString('stAng'), startAngle.toString()),
          XmlAttribute(XmlName.fromString('swAng'), sweepAngle.toString()),
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

/// Predefined bevel types for 3D effects.
///
/// Controls the shape of the bevel (chamfer) applied to 3D shape edges.
enum BevelPreset {
  /// Circular bevel (rounded edge)
  circle('circle'),

  /// Relief bevel (embossed effect)
  relief('relief'),

  /// Slope bevel (angled edge)
  slope('slope'),

  /// Soft rounded bevel
  softRound('softRound'),

  /// Convex bevel (outward curve)
  convex('convex'),

  /// Cool slant (modern angled bevel)
  coolSlant('coolSlant'),

  /// Angle bevel (sharp edge)
  angle('angle'),

  /// Cross bevel (cruciform shape)
  cross('cross'),

  /// Art Deco style bevel
  artDeco('artDeco');

  const BevelPreset(this.xmlValue);

  /// The value used in DOCX XML `prst` attribute.
  final String xmlValue;
}

/// Rectangle defined by left, top, right, bottom coordinates.
///
/// Used for bounding boxes and inset definitions in geometry.
class Rect {
  const Rect(
    this.left,
    this.top,
    this.right,
    this.bottom,
  );

  const Rect.all(int value)
      : left = value,
        top = value,
        right = value,
        bottom = value;

  int get width => left + right;
  int get height => top + bottom;

  final int left;
  final int top;
  final int right;
  final int bottom;

  @override
  String toString() {
    return '$runtimeType(left: $left, top: $top, right: $right, bottom: $bottom)';
  }
}

/// Extension methods for creating common path commands.
extension PathCommandExtensions on PathCommand {
  /// Creates a horizontal line command.
  static LineToCommand horizontalLineTo(int x, int currentY) {
    return LineToCommand(x, currentY);
  }

  /// Creates a vertical line command.
  static LineToCommand verticalLineTo(int currentX, int y) {
    return LineToCommand(currentX, y);
  }

  /// Creates a relative move command from current position.
  static MoveToCommand relativeMoveTo(
      int currentX, int currentY, int dx, int dy) {
    return MoveToCommand(currentX + dx, currentY + dy);
  }

  /// Creates a relative line command from current position.
  static LineToCommand relativeLineTo(
      int currentX, int currentY, int dx, int dy) {
    return LineToCommand(currentX + dx, currentY + dy);
  }

  /// Creates a smooth quadratic Bézier curve (control point mirrored).
  static QuadBezToCommand smoothQuadBezTo(
    int lastControlX,
    int lastControlY,
    int x,
    int y,
  ) {
    // Mirror the previous control point
    final int currentX = x;
    final int currentY = y;
    final int controlX = 2 * currentX - lastControlX;
    final int controlY = 2 * currentY - lastControlY;

    return QuadBezToCommand(controlX, controlY, x, y);
  }

  /// Creates a smooth cubic Bézier curve (control point mirrored).
  static CubicBezToCommand smoothCubicBezTo(
    int lastControlX,
    int lastControlY,
    int x2,
    int y2,
    int x3,
    int y3,
  ) {
    // Mirror the previous control point
    final int x1 = 2 * x3 - lastControlX;
    final int y1 = 2 * y3 - lastControlY;

    return CubicBezToCommand(x1, y1, x2, y2, x3, y3);
  }
}

/// Predefined shapes for DrawingML (`<a:prstGeom prst="...">`) in Word documents.
///
/// These shapes can be used for autoshapes, text boxes, and drawing objects.
/// When rendered, each shape appears as a specific geometric form that can be
/// resized, rotated, and styled with fills, gradients, and borders.
///
/// Example usage in Word:
/// ```xml
/// <a:prstGeom prst="heart">
///   <a:avLst/>
/// </a:prstGeom>
/// ```
enum PresetShapeType {
  /// A standard rectangle with four 90-degree corners.
  ///
  /// **Visual:** □
  ///
  /// Most common shape. All corners are sharp right angles.
  rectangle('rect'),

  /// A rectangle with rounded corners.
  ///
  /// **Visual:** □ (with curved corners)
  ///
  /// All four corners are replaced with quarter-circles of equal radius.
  roundRectangle('roundRect'),

  /// An oval or circle shape.
  ///
  /// **Visual:** ○
  ///
  /// When width equals height, appears as a perfect circle.
  ellipse('ellipse'),

  /// A triangle with a horizontal base and apex pointing up.
  ///
  /// **Visual:** ▲
  ///
  /// Base is at the bottom, apex at the top center.
  triangle('triangle'),

  /// A right triangle.
  ///
  /// **Visual:** ◤ (shape varies)
  ///
  /// Triangle with one 90-degree corner.
  rightTriangle('rtTriangle'),

  /// A slanted rectangle (parallelogram).
  ///
  /// **Visual:** ▱
  ///
  /// Opposite sides are parallel and equal, but corners are not 90 degrees.
  parallelogram('parallelogram'),

  /// A trapezoid.
  ///
  /// **Visual:** ⏢
  ///
  /// Quadrilateral with one pair of parallel sides. Typically looks like a
  /// truncated pyramid or a house roof when viewed from the side.
  trapezoid('trapezoid'),

  /// A diamond (rotated square).
  ///
  /// **Visual:** ♦
  ///
  /// A square rotated 45 degrees. All sides equal length, corners at top,
  /// bottom, left, and right.
  diamond('diamond'),

  /// A five-sided pentagon.
  ///
  /// **Visual:** ⬟ (five-sided shape)
  ///
  /// Regular pentagon with all sides and angles equal.
  pentagon('pentagon'),

  /// A six-sided hexagon.
  ///
  /// **Visual:** ⬡
  ///
  /// Regular hexagon with all sides equal. Often used for honeycomb patterns.
  hexagon('hexagon'),

  /// A seven-sided heptagon.
  ///
  /// **Visual:** 7-sided polygon, less common than hexagon or octagon.
  heptagon('heptagon'),

  /// An eight-sided octagon.
  ///
  /// **Visual:** ⬠
  ///
  /// Regular octagon. Commonly used for stop signs in diagrams.
  octagon('octagon'),

  /// A ten-sided decagon.
  ///
  /// **Visual:** 10-sided polygon.
  decagon('decagon'),

  /// A twelve-sided dodecagon.
  ///
  /// **Visual:** 12-sided polygon. Very close to a circle visually.
  dodecagon('dodecagon'),

  /// A 4-pointed star.
  ///
  /// **Visual:** ★ with 4 points (like a sparkle)
  ///
  /// Often used for sparkles or glitter effects.
  star4('star4'),

  /// A 5-pointed star.
  ///
  /// **Visual:** ★ (standard five-point star)
  ///
  /// The classic star shape, similar to the US flag star or sheriff badge.
  star5('star5'),

  /// A 6-pointed star.
  ///
  /// **Visual:** ✶ (Star of David style)
  ///
  /// Two overlapping triangles forming a six-pointed star.
  star6('star6'),

  /// A 7-pointed star.
  ///
  /// **Visual:** 7-point star, less common, used for unique decorative effects.
  star7('star7'),

  /// An 8-pointed star.
  ///
  /// **Visual:** ✸
  ///
  /// Often used as a compass rose or decorative element.
  star8('star8'),

  /// A 10-pointed star.
  ///
  /// **Visual:** 10-point star, highly decorative.
  star10('star10'),

  /// A 12-pointed star.
  ///
  /// **Visual:** 12-point star, can appear nearly circular.
  star12('star12'),

  /// A 16-pointed star.
  ///
  /// **Visual:** 16-point star, very detailed.
  star16('star16'),

  /// A 24-pointed star.
  ///
  /// **Visual:** 24-point star, appears almost like a sunburst.
  star24('star24'),

  /// A 32-pointed star.
  ///
  /// **Visual:** 32-point star, very fine detail, appears as a spoked wheel.
  star32('star32'),

  /// Rectangle with one corner rounded, others square.
  ///
  /// **Visual:** □ with one rounded corner (typically top-right)
  ///
  /// Useful for callout boxes or speech bubbles.
  round1Rect('round1Rect'),

  /// Rectangle with two adjacent corners rounded.
  ///
  /// **Visual:** □ with two rounded corners on same side.
  round2SameRect('round2SameRect'),

  /// Rectangle with two diagonal corners rounded.
  ///
  /// **Visual:** □ with opposite corners rounded.
  round2DiagRect('round2DiagRect'),

  /// Rectangle with one corner "snip" (chamfered, not rounded).
  ///
  /// **Visual:** □ with one clipped corner (like a corner cut off).
  snip1Rect('snip1Rect'),

  /// Rectangle with two adjacent snipped corners.
  ///
  /// **Visual:** □ with two clipped corners on same side.
  snip2SameRect('snip2SameRect'),

  /// Rectangle with two diagonal snipped corners.
  ///
  /// **Visual:** □ with opposite corners clipped.
  snip2DiagRect('snip2DiagRect'),

  /// Rectangle with snipped corners that also have rounding.
  ///
  /// **Visual:** □ with clipped-then-rounded corners, a complex effect.
  snipRoundRect('snipRoundRect'),

  /// Plaque shape (a rounded rectangle with vertical sides).
  ///
  /// **Visual:** ▭ (similar to a rounded rectangle but with straighter sides)
  ///
  /// Often used for plaques or labels.
  plaque('plaque'),

  /// A cylinder (can shape).
  ///
  /// **Visual:** ⏁ (shape like a soda can, rounded top and bottom).
  ///
  /// Gives a 3D cylindrical appearance.
  cylinder('cylinder'),

  /// A can (similar to cylinder but with different proportions).
  ///
  /// **Visual:** Can/cylinder shape, often shown with perspective.
  ///
  /// Used for drawing cans, containers, or drums.
  can('can'),

  /// A 3D cube.
  ///
  /// **Visual:** 3D cube with visible top and two sides.
  ///
  /// Creates an isometric cube appearance.
  cube('cube'),

  /// A beveled shape.
  ///
  /// **Visual:** A rectangle with beveled (angled) edges.
  ///
  /// Often used for buttons or frames with 3D effect.
  bevel('bevel'),

  /// A donut (ring) shape.
  ///
  /// **Visual:** ○ with a hole in the middle (like a donut).
  ///
  /// Two concentric circles, outer circle with inner hole.
  donut('donut'),

  /// No Smoking symbol.
  ///
  /// **Visual:** 🚫 (circle with diagonal line through it).
  ///
  /// Standard prohibition or "no" symbol.
  noSmoking('noSmoking'),

  /// Block arc (partial circle/pie shape).
  ///
  /// **Visual:** Arc or pie slice of a circle.
  ///
  /// Useful for progress indicators or pie charts.
  blockArc('blockArc'),

  /// Heart shape.
  ///
  /// **Visual:** ❤ (standard heart symbol).
  ///
  /// Classic valentine heart shape.
  heart('heart'),

  /// Lightning bolt shape.
  ///
  /// **Visual:** ⚡ (zigzag lightning bolt).
  ///
  /// Often used for electricity or power symbols.
  lightningBolt('lightningBolt'),

  /// Sun shape.
  ///
  /// **Visual:** ☀ (circle with rays emanating outward).
  ///
  /// Used for weather, brightness, or summer themes.
  sun('sun'),

  /// Moon shape.
  ///
  /// **Visual:** ☾ (crescent moon).
  ///
  /// Often used for night, dark mode, or lunar themes.
  moon('moon'),

  /// Cloud shape.
  ///
  /// **Visual:** ☁ (fluffy cloud silhouette).
  ///
  /// Used for weather, cloud computing, or soft effects.
  cloud('cloud'),

  /// Arc (curved line shape).
  ///
  /// **Visual:** ⌒ (open curve, like a parenthesis but wider).
  ///
  /// A simple curved line, no fill.
  arc('arc'),

  /// Paired brackets: [ ]
  ///
  /// **Visual:** [  ] (left and right brackets together).
  ///
  /// Creates a shape that looks like a pair of square brackets.
  bracketPair('bracketPair'),

  /// Paired braces: { }
  ///
  /// **Visual:** {  } (left and right curly braces together).
  ///
  /// Creates a shape that looks like a pair of curly braces.
  bracePair('bracePair'),

  /// Left bracket only: [
  ///
  /// **Visual:** [ (single left square bracket as a shape).
  ///
  /// Useful for making diagrams or structural elements.
  leftBracket('leftBracket'),

  /// Right bracket only: ]
  ///
  /// **Visual:** ] (single right square bracket as a shape).
  rightBracket('rightBracket'),

  /// Left brace only: {
  ///
  /// **Visual:** { (single left curly brace as a shape).
  ///
  /// Useful for making diagrams or structural elements in math/flowcharts.
  leftBrace('leftBrace'),

  /// Right brace only: }
  ///
  /// **Visual:** } (single right curly brace as a shape).
  ///
  /// Paired with left brace for grouping or spanning multiple lines.
  rightBrace('rightBrace'),

  /// A single arrow pointing right.
  ///
  /// **Visual:** → (right-pointing arrow).
  ///
  /// Standard arrow indicating direction or progression.
  arrow('arrow'),

  /// Left-pointing arrow.
  ///
  /// **Visual:** ← (arrow pointing left).
  leftArrow('leftArrow'),

  /// Down-pointing arrow.
  ///
  /// **Visual:** ↓ (arrow pointing down).
  downArrow('downArrow'),

  /// Up-pointing arrow.
  ///
  /// **Visual:** ↑ (arrow pointing up).
  upArrow('upArrow'),

  /// Left-right double arrow.
  ///
  /// **Visual:** ↔ (arrow pointing both left and right).
  ///
  /// Indicates bidirectional flow or width expansion.
  leftRightArrow('leftRightArrow'),

  /// Up-down double arrow.
  ///
  /// **Visual:** ↕ (arrow pointing both up and down).
  ///
  /// Indicates bidirectional vertical flow or height expansion.
  upDownArrow('upDownArrow'),

  /// Four-way (quad) arrow.
  ///
  /// **Visual:** ➕ shape with arrows on all four ends.
  ///
  /// Indicates movement or resizing in all directions.
  quadArrow('quadArrow'),

  /// Right arrow (duplicate of arrow? but preserved for compatibility).
  ///
  /// **Visual:** → (right-pointing arrow).
  ///
  /// Identical to `arrow` in appearance. Exists for API completeness.
  rightArrow('rightArrow'),

  /// Left-up pointing arrow (diagonal).
  ///
  /// **Visual:** ↖ (arrow pointing diagonally up and left).
  ///
  /// Indicates movement or direction toward top-left.
  leftUpArrow('leftUpArrow'),

  /// Bent arrow pointing up.
  ///
  /// **Visual:** Arrow that goes right then bends upward.
  ///
  /// Used for flowcharts showing a rightward then upward flow.
  bentUpArrow('bentUpArrow'),

  /// Curved left-right arrow.
  ///
  /// **Visual:** Curved arrow that goes left then right (or vice versa).
  ///
  /// Indicates a looping or reciprocating motion horizontally.
  curvedLeftRightArrow('curvedLeftRightArrow'),

  /// Curved up-down arrow.
  ///
  /// **Visual:** Curved arrow that goes up then down (or vice versa).
  ///
  /// Indicates a looping or reciprocating motion vertically.
  curvedUpDownArrow('curvedUpDownArrow'),

  /// Left arrow with callout bubble.
  ///
  /// **Visual:** ← (arrow combined with speech bubble shape).
  ///
  /// Used for annotations or labels pointing from the left.
  leftArrowCallout('leftArrowCallout'),

  /// Right arrow with callout bubble.
  ///
  /// **Visual:** → (arrow combined with speech bubble).
  ///
  /// Used for annotations or labels pointing from the right.
  rightArrowCallout('rightArrowCallout'),

  /// Up arrow with callout bubble.
  ///
  /// **Visual:** ↑ (arrow combined with speech bubble).
  ///
  /// Used for annotations or labels pointing from above.
  upArrowCallout('upArrowCallout'),

  /// Down arrow with callout bubble.
  ///
  /// **Visual:** ↓ (arrow combined with speech bubble).
  ///
  /// Used for annotations or labels pointing from below.
  downArrowCallout('downArrowCallout'),

  /// Left-right arrow with callout bubble.
  ///
  /// **Visual:** ↔ (double arrow combined with speech bubble).
  leftRightArrowCallout('leftRightArrowCallout'),

  /// Up-down arrow with callout bubble.
  ///
  /// **Visual:** ↕ (double arrow combined with speech bubble).
  upDownArrowCallout('upDownArrowCallout'),

  /// Four-way arrow with callout bubble.
  ///
  /// **Visual:** Quad arrow combined with speech bubble.
  quadArrowCallout('quadArrowCallout'),

  /// Bent arrow (right then down or similar).
  ///
  /// **Visual:** ⤵ (arrow that turns a corner).
  ///
  /// Indicates change of direction or wrapping.
  bentArrow('bentArrow'),

  /// U-turn arrow.
  ///
  /// **Visual:** ↶ or ↷ (arrow that makes a 180-degree turn).
  ///
  /// Indicates reversal or turning around.
  uturnArrow('uturnArrow'),

  /// Circular arrow (clockwise).
  ///
  /// **Visual:** ⟳ (arrow forming a full circle).
  ///
  /// Indicates rotation, refresh, or cycle.
  circularArrow('circularArrow'),

  /// Leftward circular arrow.
  ///
  /// **Visual:** ⟲ (counter-clockwise circular arrow).
  leftCircularArrow('leftCircularArrow'),

  /// Left-right circular arrow.
  ///
  /// **Visual:** Circular arrow with both directions.
  leftRightCircularArrow('leftRightCircularArrow'),

  /// Curved arrow pointing right.
  ///
  /// **Visual:** ⤻ (arrow curving to the right).
  curvedRightArrow('curvedRightArrow'),

  /// Curved arrow pointing left.
  ///
  /// **Visual:** ⤺ (arrow curving to the left).
  curvedLeftArrow('curvedLeftArrow'),

  /// Curved arrow pointing up.
  ///
  /// **Visual:** Arrow curving upward.
  curvedUpArrow('curvedUpArrow'),

  /// Curved arrow pointing down.
  ///
  /// **Visual:** Arrow curving downward.
  curvedDownArrow('curvedDownArrow'),

  /// Swoosh arrow (sweeping curved arrow).
  ///
  /// **Visual:** Elegant sweeping arrow, often used for logos.
  swooshArrow('swooshArrow'),

  /// Home plate shape (pentagon with a flat top).
  ///
  /// **Visual:** ⬟ (pentagon used in baseball home plate).
  ///
  /// Actually a pentagon shape, named for baseball home plate.
  homePlate('homePlate'),

  /// Chevron shape (> or <).
  ///
  /// **Visual:** » (double-angle bracket shape, like V but thicker).
  ///
  /// Often used for navigation or directional indicators.
  chevron('chevron'),

  /// Simple rectangular callout.
  ///
  /// **Visual:** ▭ with a pointer (speech bubble shape).
  ///
  /// Basic speech or thought bubble with rectangular body.
  callout1('callout1'),

  /// Callout with rounded corners.
  ///
  /// **Visual:** Speech bubble with rounded rectangle body.
  callout2('callout2'),

  /// Callout with oval shape.
  ///
  /// **Visual:** Speech bubble with oval/elliptical body.
  callout3('callout3'),

  /// Accent callout style 1.
  ///
  /// **Visual:** callout1 with additional accent line or styling.
  accentCallout1('accentCallout1'),

  /// Accent callout style 2.
  ///
  /// **Visual:** callout2 with additional accent line or styling.
  accentCallout2('accentCallout2'),

  /// Accent callout style 3.
  ///
  /// **Visual:** callout3 with additional accent line or styling.
  accentCallout3('accentCallout3'),

  /// Bordered callout style 1.
  ///
  /// **Visual:** callout1 with thick border.
  borderCallout1('borderCallout1'),

  /// Bordered callout style 2.
  ///
  /// **Visual:** callout2 with thick border.
  borderCallout2('borderCallout2'),

  /// Bordered callout style 3.
  ///
  /// **Visual:** callout3 with thick border.
  borderCallout3('borderCallout3'),

  /// Accent bordered callout style 1.
  ///
  /// **Visual:** callout1 with accent and border.
  accentBorderCallout1('accentBorderCallout1'),

  /// Accent bordered callout style 2.
  ///
  /// **Visual:** callout2 with accent and border.
  accentBorderCallout2('accentBorderCallout2'),

  /// Accent bordered callout style 3.
  ///
  /// **Visual:** callout3 with accent and border.
  accentBorderCallout3('accentBorderCallout3'),

  /// Wedge-shaped rectangle callout.
  ///
  /// **Visual:** Rectangle with wedge pointer.
  wedgeRectCallout('wedgeRectCallout'),

  /// Wedge-shaped rounded rectangle callout.
  ///
  /// **Visual:** Rounded rectangle with wedge pointer.
  wedgeRoundRectCallout('wedgeRoundRectCallout'),

  /// Wedge-shaped ellipse callout.
  ///
  /// **Visual:** Ellipse with wedge pointer.
  wedgeEllipseCallout('wedgeEllipseCallout'),

  /// Cloud-shaped callout.
  ///
  /// **Visual:** Speech bubble shaped like a cloud ☁.
  ///
  /// Often used for thoughts or dream sequences.
  cloudCallout('cloudCallout'),

  /// Ribbon shape (award style).
  ///
  /// **Visual:** 🎀 (ribbon with folded ends).
  ///
  /// Often used for awards, achievements, or badges.
  ribbon('ribbon'),

  /// Ribbon shape style 2.
  ///
  /// **Visual:** Alternative ribbon with different proportions.
  ribbon2('ribbon2'),

  /// Ellipse-based ribbon.
  ///
  /// **Visual:** Ribbon with elliptical center.
  ellipseRibbon('ellipseRibbon'),

  /// Ellipse-based ribbon style 2.
  ///
  /// **Visual:** Alternative elliptical ribbon.
  ellipseRibbon2('ellipseRibbon2'),

  /// Plus sign: +
  ///
  /// **Visual:** ➕ (addition symbol).
  mathPlus('plus'),

  /// Not equals sign: ≠
  ///
  /// **Visual:** ≠ (inequality symbol, equal sign with slash).
  ///
  /// Mathematical symbol for "not equal to".
  mathNotEqual('mathNotEqual'),

  /// Minus sign: −
  ///
  /// **Visual:** ➖ (subtraction symbol).
  mathMinus('minus'),

  /// Multiplication sign: ×
  ///
  /// **Visual:** ✕ (multiplication symbol).
  mathMultiply('mathMultiply'),

  /// Division sign: ÷
  ///
  /// **Visual:** ➗ (division symbol).
  mathDivide('mathDivide'),

  /// Equals sign: =
  ///
  /// **Visual:** ＝ (equality symbol).
  mathEqual('mathEqual'),

  /// Corner shape (L-shape).
  ///
  /// **Visual:** ⌜ or ⌞ (right-angle corner piece).
  ///
  /// Useful for decorative borders or frame corners.
  corner('corner'),

  /// Corner tabs shape.
  ///
  /// **Visual:** Tabs at corners of a shape.
  cornerTabs('cornerTabs'),

  /// Square tabs shape.
  ///
  /// **Visual:** Square tabs extending from edges.
  squareTabs('squareTabs'),

  /// Plaque with tabs.
  ///
  /// **Visual:** Plaque shape with tabs on edges.
  plaqueTabs('plaqueTabs'),

  /// Frame shape.
  ///
  /// **Visual:** □ (rectangular frame, hollow center).
  ///
  /// Like a picture frame or border-only rectangle.
  frame('frame'),

  /// Funnel shape.
  ///
  /// **Visual:** ⏤ (triangle with top cut off, like a filter funnel).
  funnel('funnel'),

  /// 6-tooth gear.
  ///
  /// **Visual:** ⚙ (gear with 6 teeth).
  ///
  /// Used for mechanical or settings icons.
  gear6('gear6'),

  /// 9-tooth gear.
  ///
  /// **Visual:** Gear shape with 9 teeth.
  gear9('gear9'),

  /// Half-frame shape.
  ///
  /// **Visual:** Half of a picture frame.
  halfFrame('halfFrame'),

  /// Teardrop shape.
  ///
  /// **Visual:** 💧 (water droplet shape).
  ///
  /// Resembles a falling drop of liquid.
  teardrop('teardrop');

  const PresetShapeType(this.xmlValue);

  /// The XML string value used in `prst` attribute of `<a:prstGeom>`.
  final String xmlValue;
}
