import 'package:xml/xml.dart';
import '../../../../../../docx.dart';
import '../../../../../core/extensions/string_ext.dart';
import '../../shared/effects.dart';

/// 3D effect applied to a shape (a:sp3d).
///
/// Adds three-dimensional effects like extrusion (depth), contour, and bevels
/// to create the illusion of a 3D object. Can simulate materials like plastic,
/// metal, or matte surfaces.
class Dimensional3DEffect extends Effect<Dimensional3DData> {
  Dimensional3DEffect({required super.child});

  @override
  List<XmlNode> buildXml() {
    final List<XmlNode> children = <XmlNode>[];

    if (child.extrusionHeight != 0) {
      children.add(
        XmlElement.tag(
          'a:extrusionH',
          attributes: <XmlAttribute>[
            if (child.extrusionColor != null)
              XmlAttribute(
                'clr'.toName(),
                (child.extrusionColor!.rgbValue ?? child.extrusionColor!.themeColor)!.toString().replaceFirst('0x', ''),
              ),
            XmlAttribute(
              'h'.toName(),
              child.extrusionHeight.toString(),
            ),
          ],
          isSelfClosing: true,
        ),
      );
    }

    // Contour
    if (child.contourWidth != 0) {
      children.add(
        XmlElement.tag(
          'a:contourW',
          attributes: <XmlAttribute>[
            if (child.contourColor != null)
              XmlAttribute(
                'clr'.toName(),
                (child.contourColor!.rgbValue ?? child.contourColor!.themeColor)!.toString().replaceFirst('0x', ''),
              ),
            XmlAttribute(
              'w'.toName(),
              child.contourWidth.toString(),
            ),
          ],
          isSelfClosing: true,
        ),
      );
    }

    // Material
    children.add(
      XmlElement.tag(
        'a:prstMaterial',
        attributes: <XmlAttribute>[
          XmlAttribute(
            'val'.toName(),
            _materialToXml(child.material),
          ),
        ],
        isSelfClosing: true,
      ),
    );

    // Top bevel
    if (child.topBevel != null) {
      children.add(
        XmlElement.tag(
          'a:bevelT',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w'.toName(),
              child.topBevel!.width.toString(),
            ),
            XmlAttribute(
              'h'.toName(),
              child.topBevel!.height.toString(),
            ),
            if (child.topBevel!.preset != BevelPreset.circle)
              XmlAttribute(
                'prst'.toName(),
                _bevelPresetToXml(child.topBevel!.preset),
              ),
          ],
          isSelfClosing: true,
        ),
      );
    }

    // Bottom bevel
    if (child.bottomBevel != null) {
      children.add(
        XmlElement.tag(
          'a:bevelB',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w'.toName(),
              child.bottomBevel!.width.toString(),
            ),
            XmlAttribute(
              'h'.toName(),
              child.bottomBevel!.height.toString(),
            ),
            if (child.bottomBevel!.preset != BevelPreset.circle)
              XmlAttribute(
                'prst'.toName(),
                _bevelPresetToXml(child.bottomBevel!.preset),
              ),
          ],
          isSelfClosing: true,
        ),
      );
    }

    return <XmlNode>[
      XmlElement.tag(
        'a:sp3d',
        children: children,
      ),
    ];
  }

  String _materialToXml(PresetMaterial material) {
    return switch (material) {
      PresetMaterial.plastic => 'plastic',
      PresetMaterial.metal => 'metal',
      PresetMaterial.matte => 'matte',
      PresetMaterial.warmMatte => 'warmMatte',
      PresetMaterial.translucentPowder => 'translucentPowder',
      PresetMaterial.powder => 'powder',
      PresetMaterial.darkEdge => 'darkEdge',
      PresetMaterial.softEdge => 'softEdge',
      PresetMaterial.clear => 'clear',
      PresetMaterial.flat => 'flat',
      PresetMaterial.softmetal => 'softmetal',
    };
  }

  String _bevelPresetToXml(BevelPreset preset) {
    return switch (preset) {
      BevelPreset.circle => 'circle',
      BevelPreset.relief => 'relief',
      BevelPreset.slope => 'slope',
      BevelPreset.softRound => 'softRound',
      BevelPreset.convex => 'convex',
      BevelPreset.coolSlant => 'coolSlant',
      BevelPreset.angle => 'angle',
      BevelPreset.cross => 'cross',
      BevelPreset.artDeco => 'artDeco',
    };
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

  @override
  Dimensional3DEffect get copy => Dimensional3DEffect(child: child);

  @override
  Dimensional3DEffect copyWith({
    Dimensional3DData? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return Dimensional3DEffect(
      child: child ?? this.child,
    )..parent = parent ?? this.parent;
  }
}

/// 3D effect configuration for shapes with developer-friendly units.
class Dimensional3DData {
  /// Creates a 3D effect with intuitive units.
  ///
  /// - [extrusionHeight]: Depth of 3D extrusion in points
  /// - [extrusionColor]: Color of the extruded sides
  /// - [contourWidth]: Width of the contour line in points
  /// - [contourColor]: Color of the contour line
  /// - [material]: Surface material type
  /// - [topBevel]: Bevel effect for the top edge
  /// - [bottomBevel]: Bevel effect for the bottom edge
  /// - [lightingAngle]: Direction of light source in degrees
  /// - [lightingIntensity]: Brightness of lighting (0-1)
  Dimensional3DData({
    double extrusionHeight = 10.0,
    this.extrusionColor,
    double contourWidth = 1.0,
    this.contourColor,
    this.material = PresetMaterial.plastic,
    this.topBevel,
    this.bottomBevel,
    double lightingAngle = 45.0,
    double lightingIntensity = 0.8,
  })  : extrusionHeight = extrusionHeight.ptToEmu(),
        contourWidth = contourWidth.ptToEmu(),
        lightingAngle = (lightingAngle * (60000 / 360)).round(),
        lightingIntensity = (lightingIntensity * 100000).clamp(0, 100000).toInt();

  /// Creates a simple 3D effect with default bevels.
  factory Dimensional3DData.simple({
    double extrusionHeight = 10.0,
    Color? extrusionColor,
    PresetMaterial material = PresetMaterial.plastic,
  }) {
    return Dimensional3DData(
      extrusionHeight: extrusionHeight,
      extrusionColor: extrusionColor,
      material: material,
      topBevel: const Bevel(
        width: 38100, // 3 points
        height: 38100,
        preset: BevelPreset.circle,
      ),
      bottomBevel: const Bevel(
        width: 38100,
        height: 38100,
        preset: BevelPreset.circle,
      ),
    );
  }

  /// Creates a metallic 3D effect.
  factory Dimensional3DData.metallic({
    double extrusionHeight = 15.0,
    Color? extrusionColor,
  }) {
    return Dimensional3DData(
      extrusionHeight: extrusionHeight,
      extrusionColor: extrusionColor ?? Color(0x888888),
      material: PresetMaterial.metal,
      contourWidth: 2,
      contourColor: Color(0x444444),
      topBevel: const Bevel(
        width: 63500, // 5 points
        height: 31750,
        preset: BevelPreset.angle,
      ),
      bottomBevel: const Bevel(
        width: 63500,
        height: 31750,
        preset: BevelPreset.angle,
      ),
      lightingAngle: 135,
      lightingIntensity: 0.9,
    );
  }

  /// Creates a plastic/rounded 3D effect.
  factory Dimensional3DData.plasticRounded({
    double extrusionHeight = 8.0,
    double width = 0.5,
    Color? extrusionColor,
  }) {
    return Dimensional3DData(
      extrusionHeight: extrusionHeight,
      extrusionColor: extrusionColor,
      material: PresetMaterial.plastic,
      contourWidth: width,
      topBevel: Bevel(
        width: 2.ptToEmu(),
        height: 2.ptToEmu(),
        preset: BevelPreset.softRound,
      ),
      bottomBevel: Bevel(
        width: 2.ptToEmu(),
        height: 2.ptToEmu(),
        preset: BevelPreset.softRound,
      ),
      lightingAngle: 45,
      lightingIntensity: 0.7,
    );
  }

  /// Creates a subtle 3D effect for buttons.
  factory Dimensional3DData.button({
    double extrusionHeight = 5.0,
    Color? baseColor,
  }) {
    return Dimensional3DData(
      extrusionHeight: extrusionHeight,
      extrusionColor: baseColor != null ? Color(_darkenColor(baseColor.rgbValue!, 30)) : Color(0x666666),
      material: PresetMaterial.plastic,
      contourWidth: 0.5,
      contourColor: baseColor != null ? Color(_darkenColor(baseColor.rgbValue!, 50)) : Color(0x333333),
      topBevel: const Bevel(
        width: 19050, // 1.5 points
        height: 19050,
        preset: BevelPreset.circle,
      ),
      lightingAngle: 315,
      lightingIntensity: 0.6,
    );
  }

  /// Creates a dramatic 3D effect for emphasis.
  factory Dimensional3DData.dramatic({
    double extrusionHeight = 20.0,
    Color? extrusionColor,
  }) {
    return Dimensional3DData(
      extrusionHeight: extrusionHeight,
      extrusionColor: extrusionColor ?? Color(0x555555),
      material: PresetMaterial.metal,
      contourWidth: 3,
      contourColor: Color(0x222222),
      topBevel: const Bevel(
        width: 76200, // 6 points
        height: 38100,
        preset: BevelPreset.coolSlant,
      ),
      bottomBevel: const Bevel(
        width: 76200,
        height: 38100,
        preset: BevelPreset.coolSlant,
      ),
      lightingAngle: 225,
      lightingIntensity: 1,
    );
  }

  final int extrusionHeight;
  final Color? extrusionColor;
  final int contourWidth;
  final Color? contourColor;
  final PresetMaterial material;
  final Bevel? topBevel;
  final Bevel? bottomBevel;
  final int lightingAngle;
  final int lightingIntensity;

  /// Gets the extrusion height in points.
  double get extrusionHeightInPoints => extrusionHeight.emuToPt();

  /// Gets the contour width in points.
  double get contourWidthInPoints => contourWidth.emuToPt();

  /// Gets the lighting angle in degrees.
  double get lightingAngleInDegrees => lightingAngle / (60000 / 360);

  /// Gets the lighting intensity as a decimal (0.0 to 1.0).
  double get lightingIntensityDecimal => lightingIntensity / 100000.0;

  /// Creates a copy with overridden values.
  Dimensional3DData copyWith({
    double? extrusionHeight,
    Color? extrusionColor,
    double? contourWidth,
    Color? contourColor,
    PresetMaterial? material,
    Bevel? topBevel,
    Bevel? bottomBevel,
    double? lightingAngle,
    double? lightingIntensity,
  }) {
    return Dimensional3DData(
      extrusionHeight: extrusionHeight ?? extrusionHeightInPoints,
      extrusionColor: extrusionColor ?? this.extrusionColor,
      contourWidth: contourWidth ?? contourWidthInPoints,
      contourColor: contourColor ?? this.contourColor,
      material: material ?? this.material,
      topBevel: topBevel ?? this.topBevel,
      bottomBevel: bottomBevel ?? this.bottomBevel,
      lightingAngle: lightingAngle ?? lightingAngleInDegrees,
      lightingIntensity: lightingIntensity ?? lightingIntensityDecimal,
    );
  }

  /// Creates a deeper 3D effect.
  Dimensional3DData deeper([double factor = 1.5]) {
    return copyWith(
      extrusionHeight: extrusionHeightInPoints * factor,
    );
  }

  /// Creates a shallower 3D effect.
  Dimensional3DData shallower([double factor = 0.7]) {
    return copyWith(
      extrusionHeight: extrusionHeightInPoints * factor,
    );
  }

  /// Changes the material type.
  Dimensional3DData withMaterial(PresetMaterial newMaterial) {
    return copyWith(material: newMaterial);
  }

  /// Adds or replaces the top bevel.
  Dimensional3DData withTopBevel(Bevel bevel) {
    return copyWith(topBevel: bevel);
  }

  /// Removes the top bevel.
  Dimensional3DData withoutTopBevel() {
    return copyWith(topBevel: null);
  }

  /// Changes the lighting direction.
  Dimensional3DData withLightingAngle(double angle) {
    return copyWith(lightingAngle: angle);
  }

  static int _darkenColor(int rgb, int percent) {
    final int r = ((rgb >> 16) & 0xFF) * (100 - percent) ~/ 100;
    final int g = ((rgb >> 8) & 0xFF) * (100 - percent) ~/ 100;
    final int b = (rgb & 0xFF) * (100 - percent) ~/ 100;

    return (r.clamp(0, 255) << 16) | (g.clamp(0, 255) << 8) | b.clamp(0, 255);
  }

  @override
  String toString() {
    return 'ThreeDEffect('
        'height: ${extrusionHeightInPoints.toStringAsFixed(1)}pt, '
        'material: $material, '
        'contour: ${contourWidthInPoints.toStringAsFixed(1)}pt'
        ')';
  }
}

/// Bevel configuration for 3D edges.
class Bevel {
  const Bevel({
    required this.width,
    required this.height,
    this.preset = BevelPreset.circle,
  });

  Bevel.points({
    required double width,
    required double height,
    this.preset = BevelPreset.circle,
  })  : width = width.ptToEmu(),
        height = height.ptToEmu();

  Bevel.inches({
    required double width,
    required double height,
    this.preset = BevelPreset.circle,
  })  : width = width.inchesToEmu(),
        height = height.inchesToEmu();

  final int width;
  final int height;
  final BevelPreset preset;

  /// Gets the width in points.
  double get widthInPoints => width.emuToPt();

  /// Gets the height in points.
  double get heightInPoints => height.emuToPt();

  Bevel copyWith({
    int? width,
    int? height,
    BevelPreset? preset,
  }) {
    return Bevel(
      width: width ?? this.width,
      height: height ?? this.height,
      preset: preset ?? this.preset,
    );
  }
}
