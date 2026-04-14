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

/// Predefined shapes (for prstGeom prst="...")
enum PresetShapeType {
  rectangle('rect'),
  roundRectangle('roundRect'),
  ellipse('ellipse'),
  triangle('triangle'),
  rightTriangle('rtTriangle'),
  parallelogram('parallelogram'),
  trapezoid('trapezoid'),
  diamond('diamond'),
  pentagon('pentagon'),
  hexagon('hexagon'),
  heptagon('heptagon'),
  octagon('octagon'),
  decagon('decagon'),
  dodecagon('dodecagon'),
  star4('star4'),
  star5('star5'),
  star6('star6'),
  star7('star7'),
  star8('star8'),
  star10('star10'),
  star12('star12'),
  star16('star16'),
  star24('star24'),
  star32('star32'),
  round1Rect('round1Rect'),
  round2SameRect('round2SameRect'),
  round2DiagRect('round2DiagRect'),
  snip1Rect('snip1Rect'),
  snip2SameRect('snip2SameRect'),
  snip2DiagRect('snip2DiagRect'),
  snipRoundRect('snipRoundRect'),
  plaque('plaque'),
  cylinder('cylinder'),
  can('can'),
  cube('cube'),
  bevel('bevel'),
  donut('donut'),
  noSmoking('noSmoking'),
  blockArc('blockArc'),
  heart('heart'),
  lightningBolt('lightningBolt'),
  sun('sun'),
  moon('moon'),
  cloud('cloud'),
  arc('arc'),
  bracketPair('bracketPair'),
  bracePair('bracePair'),
  leftBracket('leftBracket'),
  rightBracket('rightBracket'),
  leftBrace('leftBrace'),
  rightBrace('rightBrace'),
  arrow('arrow'),
  leftArrow('leftArrow'),
  downArrow('downArrow'),
  upArrow('upArrow'),
  leftRightArrow('leftRightArrow'),
  upDownArrow('upDownArrow'),
  quadArrow('quadArrow'),
  leftArrowCallout('leftArrowCallout'),
  rightArrowCallout('rightArrowCallout'),
  upArrowCallout('upArrowCallout'),
  downArrowCallout('downArrowCallout'),
  leftRightArrowCallout('leftRightArrowCallout'),
  upDownArrowCallout('upDownArrowCallout'),
  quadArrowCallout('quadArrowCallout'),
  bentArrow('bentArrow'),
  uturnArrow('uturnArrow'),
  circularArrow('circularArrow'),
  leftCircularArrow('leftCircularArrow'),
  leftRightCircularArrow('leftRightCircularArrow'),
  curvedRightArrow('curvedRightArrow'),
  curvedLeftArrow('curvedLeftArrow'),
  curvedUpArrow('curvedUpArrow'),
  curvedDownArrow('curvedDownArrow'),
  swooshArrow('swooshArrow'),
  homePlate('homePlate'),
  chevron('chevron'),
  rightArrow('rightArrow'),
  leftUpArrow('leftUpArrow'),
  bentUpArrow('bentUpArrow'),
  curvedLeftRightArrow('curvedLeftRightArrow'),
  curvedUpDownArrow('curvedUpDownArrow'),
  callout1('callout1'),
  callout2('callout2'),
  callout3('callout3'),
  accentCallout1('accentCallout1'),
  accentCallout2('accentCallout2'),
  accentCallout3('accentCallout3'),
  borderCallout1('borderCallout1'),
  borderCallout2('borderCallout2'),
  borderCallout3('borderCallout3'),
  accentBorderCallout1('accentBorderCallout1'),
  accentBorderCallout2('accentBorderCallout2'),
  accentBorderCallout3('accentBorderCallout3'),
  wedgeRectCallout('wedgeRectCallout'),
  wedgeRoundRectCallout('wedgeRoundRectCallout'),
  wedgeEllipseCallout('wedgeEllipseCallout'),
  cloudCallout('cloudCallout'),
  ribbon('ribbon'),
  ribbon2('ribbon2'),
  ellipseRibbon('ellipseRibbon'),
  ellipseRibbon2('ellipseRibbon2'),
  chord('chord'),
  mathPlus('plus'),
  mathMinus('minus'),
  mathMultiply('mathMultiply'),
  mathDivide('mathDivide'),
  mathEqual('mathEqual'),
  mathNotEqual('mathNotEqual'),
  corner('corner'),
  cornerTabs('cornerTabs'),
  squareTabs('squareTabs'),
  plaqueTabs('plaqueTabs'),
  frame('frame'),
  funnel('funnel'),
  gear6('gear6'),
  gear9('gear9'),
  halfFrame('halfFrame'),
  teardrop('teardrop');

  const PresetShapeType(this.xmlValue);

  final String xmlValue;
}
