import 'dart:math';

import '../../../../../../docx.dart';

/// Configuration for shadow effects.
///
/// All values use intuitive units (points, degrees, percentages) and are
/// automatically converted to the internal DOCX representation (EMU, 60,000ths).
class ShadowEffectData {
  /// Creates a shadow with intuitive units.
  ///
  /// - [color]: Shadow color (defaults to black)
  /// - [blurRadius]: Softness in points (default 2pt)
  /// - [offsetX]: Horizontal offset in points (negative = left, positive = right)
  /// - [offsetY]: Vertical offset in points (negative = up, positive = down)
  /// - [angle]: Direction angle in degrees (0° = right, 90° = up)
  /// - [opacity]: Transparency (0.0 = transparent, 1.0 = opaque)
  /// - [isInner]: Whether shadow is inside the shape (inset shadow)
  ShadowEffectData({
    Color? color,
    double blurRadius = 2.0,
    double offsetX = 2.0,
    double offsetY = 2.0,
    double angle = 45.0,
    double opacity = 0.25,
    this.isInner = false,
  })  : color = color ?? Color.rgb(0x000000),
        blur = blurRadius.ptToEmu(),
        distance = _calculateDistance(offsetX, offsetY),
        direction = _calculateDirection(offsetX, offsetY, angle),
        alpha = (opacity.clamp(0.0, 1.0) * maxAlphaEmu).toInt();

  /// Creates a shadow with no convertions.
  ShadowEffectData.raw({
    required this.color,
    required this.blur,
    required this.distance,
    required this.direction,
    required this.alpha,
    this.isInner = false,
  });

  /// Creates an inner (inset) shadow.
  factory ShadowEffectData.inner({
    Color? color,
    double blurRadius = 2.0,
    double offsetX = 1.0,
    double offsetY = 1.0,
    double angle = 135.0,
    double opacity = 0.15,
  }) {
    color ??= Color.rgb(0x000000);
    return ShadowEffectData(
      color: color,
      blurRadius: blurRadius,
      offsetX: offsetX,
      offsetY: offsetY,
      angle: angle,
      opacity: opacity,
      isInner: true,
    );
  }

  /// Creates a drop shadow with common presets.
  factory ShadowEffectData.dropShadow({
    Color? color,
    double blurRadius = 4.0,
    double distance = 3.0,
    double angle = 135.0,
    double opacity = 0.3,
  }) {
    // Convert distance to X/Y components based on angle
    final double radians = angle * (pi / 180);
    final double offsetX = distance * cos(radians);
    final double offsetY = distance * sin(radians);

    return ShadowEffectData(
      color: color ?? Color.rgb(0x000000),
      blurRadius: blurRadius,
      offsetX: offsetX,
      offsetY:
          -offsetY, // Negate Y because DOCX uses different coordinate system
      angle: angle,
      opacity: opacity,
    );
  }

  /// Creates a subtle shadow for depth.
  factory ShadowEffectData.subtle() {
    return ShadowEffectData(
      color: Color.rgb(0x000000),
      blurRadius: 1.5,
      offsetX: 1,
      offsetY: 1,
      angle: 45,
      opacity: 0.15,
    );
  }

  /// Creates a long shadow for dramatic effects.
  factory ShadowEffectData.long({
    Color? color,
    double distance = 8.0,
    double angle = 45.0,
    double opacity = 0.2,
  }) {
    return ShadowEffectData.dropShadow(
      color: color,
      blurRadius: 3,
      distance: distance,
      angle: angle,
      opacity: opacity,
    );
  }

  /// Creates a glow-like shadow (large blur, no offset).
  factory ShadowEffectData.glow({
    Color? color,
    double blurRadius = 8.0,
    double opacity = 0.15,
  }) {
    color ??= Color.rgb(0x000000);
    return ShadowEffectData(
      color: color,
      blurRadius: blurRadius,
      offsetX: 0,
      offsetY: 0,
      angle: 0,
      opacity: opacity,
    );
  }

  /// Creates a contact shadow (tight, dark shadow at bottom).
  factory ShadowEffectData.contact({
    Color? color,
    double blurRadius = 2.0,
    double distance = 1.5,
    double opacity = 0.4,
  }) {
    return ShadowEffectData(
      color: color ?? Color.rgb(0x000000),
      blurRadius: blurRadius,
      offsetX: 0,
      offsetY: distance,
      angle: 90,
      opacity: opacity,
    );
  }

  /// Creates a layered shadow (multiple shadow presets).
  static List<ShadowEffectData> layered({
    Color? baseColor,
    int layers = 2,
    double baseDistance = 1.0,
    double distanceIncrement = 1.0,
    double baseBlur = 1.0,
    double blurIncrement = 1.0,
    double baseOpacity = 0.1,
    double opacityDecrement = 0.05,
  }) {
    final List<ShadowEffectData> shadows = <ShadowEffectData>[];
    for (int i = 0; i < layers; i++) {
      shadows.add(
        ShadowEffectData(
          color: baseColor ?? Color.rgb(0x000000),
          blurRadius: baseBlur + (blurIncrement * i),
          offsetX: baseDistance + (distanceIncrement * i),
          offsetY: baseDistance + (distanceIncrement * i),
          angle: 45,
          opacity: baseOpacity - (opacityDecrement * i),
        ),
      );
    }
    return shadows;
  }

  final Color color;
  final int blur; // in EMU
  final int distance; // in EMU
  final int direction; // in 60,000ths of a degree

  /// Alpha range but in EMU units
  ///
  /// Can be stored 0 to 100000
  final int alpha;
  final bool isInner;

  /// Gets the blur radius in points for external use.
  double get blurRadius => blur.emuToPt();

  /// Gets the shadow opacity (0.0 to 1.0).
  double get opacity => alpha / maxAlphaEmu;

  /// Gets the angle in degrees (0° = right, 90° = up).
  double get angle {
    // Convert from 60,000ths of degree to degrees
    final double degrees = direction / (degressTh / 360);
    // Normalize to 0-360
    return degrees % 360;
  }

  /// Gets the offset components in points.
  (double x, double y) get offset {
    final double radians = angle * (pi / 180);
    final double distPoints = distance.emuToPt();
    return (
      distPoints * cos(radians),
      -distPoints * sin(radians), // Negate for DOCX coordinate system
    );
  }

  /// Creates a copy with overridden values.
  ShadowEffectData copyWith({
    Color? color,
    double? blurRadius,
    double? offsetX,
    double? offsetY,
    double? angle,
    double? opacity,
    bool? isInner,
  }) {
    final (double currentX, double currentY) = offset;

    return ShadowEffectData(
      color: color ?? this.color,
      blurRadius: blurRadius ?? this.blurRadius,
      offsetX: offsetX ?? currentX,
      offsetY: offsetY ?? currentY,
      angle: angle ?? this.angle,
      opacity: opacity ?? this.opacity,
      isInner: isInner ?? this.isInner,
    );
  }

  /// Creates a darker version of this shadow.
  ShadowEffectData darker([double factor = 0.3]) {
    // Create darker color (simplified - in reality you'd need proper color manipulation)
    Color darkerColor;
    if (color.type == ColorType.rgb) {
      final int rgb = color.rgbValue!;
      final double r = ((rgb >> 16) & 0xFF) * (1 - factor);
      final double g = ((rgb >> 8) & 0xFF) * (1 - factor);
      final double b = (rgb & 0xFF) * (1 - factor);
      final int newRgb = ((r.toInt() & 0xFF) << 16) |
          ((g.toInt() & 0xFF) << 8) |
          (b.toInt() & 0xFF);
      darkerColor = Color.rgb(newRgb);
    } else {
      darkerColor = color;
    }

    return copyWith(
      color: darkerColor,
      opacity: opacity * 1.2,
    );
  }

  /// Creates a lighter version of this shadow.
  ShadowEffectData lighter([double factor = 0.3]) {
    return copyWith(
      opacity: opacity * 0.7,
    );
  }

  /// Creates a blurred version (more diffuse).
  ShadowEffectData blurred([double factor = 1.5]) {
    return copyWith(
      blurRadius: blurRadius * factor,
      opacity: opacity * 0.8,
    );
  }

  /// Creates a sharper version (less diffuse).
  ShadowEffectData sharpened([double factor = 0.7]) {
    return copyWith(
      blurRadius: blurRadius * factor,
      opacity: opacity * 1.2,
    );
  }

  /// Moves the shadow in the specified direction (in points).
  ShadowEffectData moved({double dx = 0.0, double dy = 0.0}) {
    final (double currentX, double currentY) = offset;
    return copyWith(
      offsetX: currentX + dx,
      offsetY: currentY + dy,
    );
  }

  /// Rotates the shadow direction by the specified angle (in degrees).
  ShadowEffectData rotated(double degrees) {
    return copyWith(
      angle: (angle + degrees) % 360,
    );
  }

  /// Material Design elevation shadows (based on Material Design guidelines)
  static ShadowEffectData materialElevation1 = ShadowEffectData(
    color: Color.rgb(0x000000),
    blurRadius: 1,
    offsetX: 0,
    offsetY: 1,
    angle: 90,
    opacity: 0.2,
  );

  static ShadowEffectData materialElevation2 = ShadowEffectData(
    color: Color.rgb(0x000000),
    blurRadius: 1.5,
    offsetX: 0,
    offsetY: 2,
    angle: 90,
    opacity: 0.14,
  );

  static ShadowEffectData materialElevation3 = ShadowEffectData(
    color: Color.rgb(0x000000),
    blurRadius: 2,
    offsetX: 0,
    offsetY: 3,
    angle: 90,
    opacity: 0.12,
  );

  static ShadowEffectData materialElevation4 = ShadowEffectData(
    color: Color.rgb(0x000000),
    blurRadius: 3,
    offsetX: 0,
    offsetY: 4,
    angle: 90,
    opacity: 0.1,
  );

  static ShadowEffectData materialElevation6 = ShadowEffectData(
    color: Color.rgb(0x000000),
    blurRadius: 4,
    offsetX: 0,
    offsetY: 6,
    angle: 90,
    opacity: 0.08,
  );

  /// iOS-style shadows
  static ShadowEffectData iosLight = ShadowEffectData(
    color: Color.rgb(0x000000),
    blurRadius: 3,
    offsetX: 0,
    offsetY: 1,
    angle: 90,
    opacity: 0.1,
  );

  static ShadowEffectData iosMedium = ShadowEffectData(
    color: Color.rgb(0x000000),
    blurRadius: 6,
    offsetX: 0,
    offsetY: 3,
    angle: 90,
    opacity: 0.15,
  );

  static ShadowEffectData iosHeavy = ShadowEffectData(
    color: Color.rgb(0x000000),
    blurRadius: 10,
    offsetX: 0,
    offsetY: 5,
    angle: 90,
    opacity: 0.2,
  );

  /// Colored shadows for accent effects
  static ShadowEffectData blueAccent = ShadowEffectData(
    color: Color.rgb(0x2196F3),
    blurRadius: 8,
    offsetX: 2,
    offsetY: 2,
    angle: 45,
    opacity: 0.3,
  );

  static ShadowEffectData redAccent = ShadowEffectData(
    color: Color.rgb(0xF44336),
    blurRadius: 6,
    offsetX: 2,
    offsetY: 2,
    angle: 45,
    opacity: 0.25,
  );

  static ShadowEffectData greenAccent = ShadowEffectData(
    color: Color.rgb(0x4CAF50),
    blurRadius: 6,
    offsetX: 2,
    offsetY: 2,
    angle: 45,
    opacity: 0.25,
  );

  static ShadowEffectData purpleGlow = ShadowEffectData.glow(
    color: Color.rgb(0x9C27B0),
    blurRadius: 12,
    opacity: 0.2,
  );

  /// Text shadows for readable text on backgrounds
  static ShadowEffectData textShadowLight = ShadowEffectData(
    color: Color.rgb(0x000000),
    blurRadius: 0.5,
    offsetX: 0.5,
    offsetY: 0.5,
    angle: 45,
    opacity: 0.4,
  );

  static ShadowEffectData textShadowHeavy = ShadowEffectData(
    color: Color.rgb(0x000000),
    blurRadius: 1,
    offsetX: 1,
    offsetY: 1,
    angle: 45,
    opacity: 0.6,
  );

  static ShadowEffectData textShadowWhite = ShadowEffectData(
    color: Color.rgb(0xFFFFFF),
    blurRadius: 1,
    offsetX: 1,
    offsetY: 1,
    angle: 45,
    opacity: 0.8,
  );

  /// Inner shadows for inset/pressed effects
  static ShadowEffectData innerPressed = ShadowEffectData.inner(
    color: Color.rgb(0x000000),
    blurRadius: 2,
    offsetX: 1,
    offsetY: 1,
    angle: 45,
    opacity: 0.2,
  );

  static ShadowEffectData innerSunken = ShadowEffectData.inner(
    color: Color.rgb(0x000000),
    blurRadius: 4,
    offsetX: 2,
    offsetY: 2,
    angle: 225,
    opacity: 0.15,
  );

  /// Get a shadow by elevation level (1-24, Material Design style)
  static ShadowEffectData getByElevation(int level) {
    final int clampedLevel = level.clamp(1, 24);

    // Material Design elevation formula approximation
    final double blur = 0.5 + (clampedLevel * 0.125);
    final double offsetY = 0.25 + (clampedLevel * 0.25);
    final double opacity = 0.3 - (clampedLevel * 0.01);

    return ShadowEffectData(
      color: Color.rgb(0x000000),
      blurRadius: blur.clamp(0.5, 6.0).toDouble(),
      offsetX: 0,
      offsetY: offsetY.clamp(0.25, 6.0).toDouble(),
      angle: 90,
      opacity: opacity.clamp(0.08, 0.3).toDouble(),
    );
  }

  @override
  String toString() {
    final (double x, double y) = offset;
    return 'ShadowEffect('
        'color: ${_colorToString(color)}, '
        'blur: ${blurRadius.toStringAsFixed(1)}pt, '
        'offset: (${x.toStringAsFixed(1)}, ${y.toStringAsFixed(1)})pt, '
        'angle: ${angle.toStringAsFixed(0)}°, '
        'opacity: ${opacity.toStringAsFixed(2)}, '
        'type: ${isInner ? 'inner' : 'outer'}'
        ')';
  }

  static int _calculateDistance(double offsetX, double offsetY) {
    // Calculate Euclidean distance in points, then convert to EMU
    final double distancePoints = sqrt(offsetX * offsetX + offsetY * offsetY);
    return distancePoints.ptToEmu();
  }

  static int _calculateDirection(double offsetX, double offsetY, double angle) {
    // If offsets are zero, use the provided angle
    if (offsetX == 0 && offsetY == 0) {
      // Convert degrees to 60,000ths of a degree
      return (angle * (60000 / 360)).round();
    }

    // Calculate angle from offsets (DOCX uses different coordinate system)
    // In DOCX: 0° = right, 90° = up, 180° = left, 270° = down
    final double calculatedAngle = atan2(-offsetY, offsetX) * (180 / pi);
    // Normalize to 0-360
    final double normalizedAngle =
        calculatedAngle < 0 ? calculatedAngle + 360 : calculatedAngle;
    // Convert to 60,000ths of a degree
    return (normalizedAngle * (60000 / 360)).round();
  }

  static String _colorToString(Color color) {
    return switch (color.type) {
      ColorType.rgb =>
        '#${color.rgbValue!.toRadixString(16).padLeft(6, '0').toUpperCase()}',
      ColorType.theme => 'Theme(${color.themeColor})',
      ColorType.system => 'System(${color.systemColor})',
    };
  }
}
