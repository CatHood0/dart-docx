import 'package:xml/xml.dart';
import '../../../../../../docx.dart';
import '../../../../../core/extensions/string_ext.dart';
import '../../shared/effects.dart';

/// Reflection effect applied to a shape (a:reflection).
///
/// Creates a mirrored copy of the shape below it, fading out to simulate
/// a reflective surface. Often used for a polished, glossy look.
class ReflectionEffectComponent extends Effect<ReflectionEffect> {
  ReflectionEffectComponent({required super.child});

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:reflection',
        attributes: <XmlAttribute>[
          if (child.blurRadius != 0)
            XmlAttribute(
              'blurRad'.toName(),
              child.blurRadius.toString(),
            ),
          if (child.distance != 0)
            XmlAttribute(
              'dist'.toName(),
              child.distance.toString(),
            ),
          if (child.direction != 0)
            XmlAttribute(
              'dir'.toName(),
              child.direction.toString(),
            ),
          if (child.fadeDirection != 0)
            XmlAttribute(
              'fadeDir'.toName(),
              child.fadeDirection.toString(),
            ),
          //TODO: tenemos que revisar estos valores harcodeados
          if (child.startOpacity != 100000)
            XmlAttribute(
              'stA'.toName(),
              child.startOpacity.toString(),
            ),
          if (child.endOpacity != 0)
            XmlAttribute(
              'endA'.toName(),
              child.endOpacity.toString(),
            ),
          if (child.startPosition != 0)
            XmlAttribute(
              'stPos'.toName(),
              child.startPosition.toString(),
            ),
          if (child.endPosition != 100000)
            XmlAttribute(
              'endPos'.toName(),
              child.endPosition.toString(),
            ),
          XmlAttribute(
            'algn'.toName(),
            _toWordValidAlignName(child.alignment),
          ),
        ],
        isSelfClosing: true,
      ),
    ];
  }

  @override
  ReflectionEffectComponent get copy => ReflectionEffectComponent(child: child);

  @override
  ReflectionEffectComponent copyWith({
    ReflectionEffect? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return ReflectionEffectComponent(
      child: child ?? this.child,
    )..parent = parent ?? this.parent;
  }

  String _toWordValidAlignName(BorderAlignment alignment) {
    return switch (alignment) {
      BorderAlignment.top => 't',
      BorderAlignment.bottom => 'b',
      BorderAlignment.left => 'l',
      BorderAlignment.right => 'r',
      BorderAlignment.topLeft => 'tl',
      BorderAlignment.topRight => 'tr',
      BorderAlignment.bottomLeft => 'bl',
      BorderAlignment.bottomRight => 'br',
    };
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

/// Reflection effect configuration with developer-friendly units.
class ReflectionEffect {
  /// Creates a reflection effect with intuitive units.
  ///
  /// - [alignment]: Position of reflection relative to shape
  /// - [blurRadius]: Softness of reflection edges in points
  /// - [distance]: Distance between shape and reflection in points
  /// - [direction]: Angle of reflection perspective in degrees
  /// - [fadeDirection]: Direction of fade gradient in degrees
  /// - [startPosition]: Starting position of reflection fade (0-1)
  /// - [endPosition]: Ending position of reflection fade (0-1)
  /// - [startOpacity]: Starting opacity at reflection edge (0-1)
  /// - [endOpacity]: Ending opacity at reflection fade (0-1)
  ReflectionEffect({
    this.alignment = BorderAlignment.bottom,
    double blurRadius = 2.0,
    double distance = 10.0,
    double direction = 0.0,
    double fadeDirection = 90.0,
    double startPosition = 0.0,
    double endPosition = 1.0,
    double startOpacity = 1.0,
    double endOpacity = 0.0,
  })  : blurRadius = blurRadius.ptToEmu(),
        distance = distance.ptToEmu(),
        direction = (direction * (degressTh / 360)).round(),
        fadeDirection = (fadeDirection * (degressTh / 360)).round(),
        startPosition = startPosition.toAlphaUnit(),
        endPosition = endPosition.toAlphaUnit(),
        startOpacity = startOpacity.toAlphaUnit(),
        endOpacity = endOpacity.toAlphaUnit();

  ReflectionEffect.raw({
    required this.alignment,
    required this.blurRadius,
    required this.distance,
    required this.direction,
    required this.fadeDirection,
    required this.startPosition,
    required this.endPosition,
    required this.startOpacity,
    required this.endOpacity,
  });

  /// Creates a subtle bottom reflection (common for buttons and cards).
  factory ReflectionEffect.subtleBottom() {
    return ReflectionEffect(
      alignment: BorderAlignment.bottom,
      blurRadius: 1.5,
      distance: 6,
      startPosition: 0,
      endPosition: 0.5,
      startOpacity: 0.3,
      endOpacity: 0,
    );
  }

  /// Creates a full mirror reflection (strong, like water or glass).
  factory ReflectionEffect.mirror() {
    return ReflectionEffect(
      alignment: BorderAlignment.bottom,
      blurRadius: 0.5,
      distance: 2,
      startPosition: 0,
      endPosition: 0.8,
      startOpacity: 0.7,
      endOpacity: 0.1,
    );
  }

  /// Creates a distant reflection (like on a glossy surface).
  factory ReflectionEffect.distant() {
    return ReflectionEffect(
      alignment: BorderAlignment.bottom,
      blurRadius: 3,
      distance: 20,
      startPosition: 0,
      endPosition: 0.3,
      startOpacity: 0.2,
      endOpacity: 0,
    );
  }

  /// Creates a tight reflection (like on polished metal).
  factory ReflectionEffect.tight() {
    return ReflectionEffect(
      alignment: BorderAlignment.bottom,
      blurRadius: 0.5,
      distance: 1,
      startPosition: 0,
      endPosition: 0.9,
      startOpacity: 0.5,
      endOpacity: 0,
    );
  }

  /// Creates a side reflection (for 3D perspective effects).
  factory ReflectionEffect.sidePerspective(BorderAlignment side) {
    return ReflectionEffect(
      alignment: side,
      blurRadius: 2,
      distance: 15,
      direction: side == BorderAlignment.left ? 180.0 : 0.0,
      startPosition: 0,
      endPosition: 1.6,
      startOpacity: 1,
      endOpacity: 0.3,
    );
  }

  /// Creates a diagonal reflection (for dynamic lighting effects).
  factory ReflectionEffect.diagonal(BorderAlignment corner) {
    assert(corner.isCorner, 'Diagonal reflection should use corner alignment');

    return ReflectionEffect(
      alignment: corner,
      blurRadius: 2.5,
      distance: 12,
      direction: corner.angleInDegrees,
      startPosition: 0,
      endPosition: 0.7,
      startOpacity: 0.2,
      endOpacity: 0,
    );
  }

  /// Creates a gradient reflection with custom position range.
  factory ReflectionEffect.gradient({
    BorderAlignment alignment = BorderAlignment.bottom,
    double blurRadius = 2.0,
    double distance = 10.0,
    double startPosition = 0.0,
    double endPosition = 0.5,
    double startOpacity = 0.8,
    double endOpacity = 0.0,
  }) {
    return ReflectionEffect(
      alignment: alignment,
      blurRadius: blurRadius,
      distance: distance,
      startPosition: startPosition,
      endPosition: endPosition,
      startOpacity: startOpacity,
      endOpacity: endOpacity,
    );
  }

  // Some presets that are common

  /// Soft bottom reflection with short fade.
  static ReflectionEffect uiElement = ReflectionEffect(
    alignment: BorderAlignment.bottom,
    blurRadius: 1.5,
    distance: 6,
    startPosition: 0,
    endPosition: 0.4,
    startOpacity: 0.3,
    endOpacity: 0,
  );

  /// Strong mirror reflection with long fade.
  static ReflectionEffect glossySurface = ReflectionEffect(
    alignment: BorderAlignment.bottom,
    blurRadius: 0.5,
    distance: 2,
    startPosition: 0,
    endPosition: 0.8,
    startOpacity: 0.7,
    endOpacity: 0.1,
  );

  /// Distant reflection with very short fade.
  static ReflectionEffect floating = ReflectionEffect(
    alignment: BorderAlignment.bottom,
    blurRadius: 3,
    distance: 20,
    startPosition: 0,
    endPosition: 0.2,
    startOpacity: 0.2,
    endOpacity: 0,
  );

  /// Tight reflection with full fade.
  static ReflectionEffect metallic = ReflectionEffect(
    alignment: BorderAlignment.bottom,
    blurRadius: 0.5,
    distance: 1,
    startPosition: 0,
    endPosition: 1,
    startOpacity: 0.5,
    endOpacity: 0,
  );

  /// Left side reflection with medium fade.
  static ReflectionEffect perspectiveLeft = ReflectionEffect(
    alignment: BorderAlignment.left,
    blurRadius: 2,
    distance: 15,
    direction: 180,
    startPosition: 0,
    endPosition: 0.6,
    startOpacity: 0.25,
    endOpacity: 0,
  );

  /// Bottom-left diagonal with diagonal fade.
  static ReflectionEffect diagonalBottomLeft = ReflectionEffect(
    alignment: BorderAlignment.bottomLeft,
    blurRadius: 2.5,
    distance: 12,
    direction: 135,
    startPosition: 0,
    endPosition: 0.7,
    startOpacity: 0.2,
    endOpacity: 0,
  );

  /// Top reflection for hover effects.
  static ReflectionEffect hoverTop = ReflectionEffect(
    alignment: BorderAlignment.top,
    blurRadius: 1,
    distance: 4,
    startPosition: 0,
    endPosition: 0.5,
    startOpacity: 0.15,
    endOpacity: 0,
  );

  /// Right side reflection for side panels.
  static ReflectionEffect sidePanel = ReflectionEffect(
    alignment: BorderAlignment.right,
    blurRadius: 1.5,
    distance: 8,
    startPosition: 0,
    endPosition: 0.4,
    startOpacity: 0.2,
    endOpacity: 0,
  );

  /// Centered reflection for spotlight effects.
  static ReflectionEffect spotlight = ReflectionEffect(
    alignment: BorderAlignment.bottom,
    blurRadius: 4,
    distance: 5,
    startPosition: 0.4,
    endPosition: 0.6,
    startOpacity: 0.4,
    endOpacity: 0,
  );

  /// Gets a reflection by intensity level (0-10) with proportional position.
  static ReflectionEffect? byIntensity(int level) {
    final int clampedLevel = level.clamp(0, 10);
    if (clampedLevel == 0) return null;

    final double intensity = clampedLevel / 10.0;

    return ReflectionEffect(
      alignment: BorderAlignment.bottom,
      blurRadius: intensity * 3.0,
      distance: intensity * 15.0,
      startPosition: 0,
      endPosition: intensity * 0.5, // Stronger reflections have longer fades
      startOpacity: intensity * 0.3,
      endOpacity: 0,
    );
  }

  /// Gets a reflection by fade type.
  static ReflectionEffect byFadeType(
    FadeType type,
    BorderAlignment alignment,
  ) {
    return switch (type) {
      FadeType.short => ReflectionEffect(
          alignment: alignment,
          blurRadius: 2,
          distance: 10,
          startPosition: 0,
          endPosition: 0.3,
          startOpacity: 0.3,
          endOpacity: 0,
        ),
      FadeType.medium => ReflectionEffect(
          alignment: alignment,
          blurRadius: 2,
          distance: 10,
          startPosition: 0,
          endPosition: 0.6,
          startOpacity: 0.3,
          endOpacity: 0,
        ),
      FadeType.long => ReflectionEffect(
          alignment: alignment,
          blurRadius: 2,
          distance: 10,
          startPosition: 0,
          endPosition: 0.9,
          startOpacity: 0.3,
          endOpacity: 0,
        ),
      FadeType.centered => ReflectionEffect(
          alignment: alignment,
          blurRadius: 2,
          distance: 10,
          startPosition: 0.4,
          endPosition: 0.6,
          startOpacity: 0.4,
          endOpacity: 0,
        ),
    };
  }

  final BorderAlignment alignment;
  final int blurRadius;
  final int distance;
  final int direction;
  final int fadeDirection;
  final int startPosition;
  final int endPosition;
  final int startOpacity;
  final int endOpacity;

  /// Gets the blur radius in points.
  double get blurRadiusInPoints => blurRadius.emuToPt();

  /// Gets the distance in points.
  double get distanceInPoints => distance.emuToPt();

  /// Gets the direction in degrees.
  double get directionInDegrees => direction / (60000 / 360);

  /// Gets the fade direction in degrees.
  double get fadeDirectionInDegrees => fadeDirection / (60000 / 360);

  /// Gets the start position as a decimal (0.0 to 1.0).
  double get startPositionDecimal => startPosition / 100000.0;

  /// Gets the end position as a decimal (0.0 to 1.0).
  double get endPositionDecimal => endPosition / 100000.0;

  /// Gets the start opacity as a decimal (0.0 to 1.0).
  double get startOpacityDecimal => startOpacity / 100000.0;

  /// Gets the end opacity as a decimal (0.0 to 1.0).
  double get endOpacityDecimal => endOpacity / 100000.0;

  /// Creates a copy with overridden values.
  ReflectionEffect copyWith({
    BorderAlignment? alignment,
    double? blurRadius,
    double? distance,
    double? direction,
    double? fadeDirection,
    double? startPosition,
    double? endPosition,
    double? startOpacity,
    double? endOpacity,
  }) {
    return ReflectionEffect(
      alignment: alignment ?? this.alignment,
      blurRadius: blurRadius ?? blurRadiusInPoints,
      distance: distance ?? distanceInPoints,
      direction: direction ?? directionInDegrees,
      fadeDirection: fadeDirection ?? fadeDirectionInDegrees,
      startPosition: startPosition ?? startPositionDecimal,
      endPosition: endPosition ?? endPositionDecimal,
      startOpacity: startOpacity ?? startOpacityDecimal,
      endOpacity: endOpacity ?? endOpacityDecimal,
    );
  }

  /// Creates a stronger version of this reflection.
  ReflectionEffect stronger([double factor = 1.5]) {
    return copyWith(
      startOpacity: startOpacityDecimal * factor,
      endOpacity: endOpacityDecimal * factor,
    );
  }

  /// Creates a weaker version of this reflection.
  ReflectionEffect weaker([double factor = 0.7]) {
    return copyWith(
      startOpacity: startOpacityDecimal * factor,
      endOpacity: endOpacityDecimal * factor,
    );
  }

  /// Moves the reflection further away.
  ReflectionEffect further([double factor = 1.5]) {
    return copyWith(
      distance: distanceInPoints * factor,
    );
  }

  /// Moves the reflection closer.
  ReflectionEffect closer([double factor = 0.7]) {
    return copyWith(
      distance: distanceInPoints * factor,
    );
  }

  /// Changes the reflection alignment.
  ReflectionEffect withAlignment(BorderAlignment newAlignment) {
    return copyWith(alignment: newAlignment);
  }

  /// Shifts the reflection fade range.
  ReflectionEffect withPositionRange(double newStart, double newEnd) {
    return copyWith(
      startPosition: newStart,
      endPosition: newEnd,
    );
  }

  /// Creates a short fade reflection (quick transition).
  ReflectionEffect shortFade() {
    return copyWith(
      startPosition: 0,
      endPosition: 0.3,
    );
  }

  /// Creates a long fade reflection (gradual transition).
  ReflectionEffect longFade() {
    return copyWith(
      startPosition: 0,
      endPosition: 0.8,
    );
  }

  /// Creates a centered fade reflection (starts and ends in middle).
  ReflectionEffect centeredFade() {
    return copyWith(
      startPosition: 0.4,
      endPosition: 0.6,
    );
  }

  /// Calculates the fade length (difference between end and start positions).
  double get fadeLength => endPositionDecimal - startPositionDecimal;

  @override
  String toString() {
    return 'ReflectionEffect('
        'alignment: $alignment, '
        'blur: ${blurRadiusInPoints.toStringAsFixed(1)}pt, '
        'distance: ${distanceInPoints.toStringAsFixed(1)}pt, '
        'position: ${startPositionDecimal.toStringAsFixed(2)}→${endPositionDecimal.toStringAsFixed(2)}, '
        'opacity: ${startOpacityDecimal.toStringAsFixed(2)}→${endOpacityDecimal.toStringAsFixed(2)}'
        ')';
  }
}

enum FadeType { short, medium, long, centered }
