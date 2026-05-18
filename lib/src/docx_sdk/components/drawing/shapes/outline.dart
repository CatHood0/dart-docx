import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../../../../core/extensions/string_ext.dart';

/// ShapeOutline/border styling for shapes (a:ln).
///
/// Defines the line properties around the shape perimeter, including
/// color, width, dash pattern, and cap/join styles.
class ShapeBorder extends DocxNode<void> {
  ShapeBorder({
    required this.color,
    this.width = emu,
    this.style = LineStyle.solid,
    this.cap = LineCap.flat,
    this.join = LineJoin.round,
    this.dashPattern,
    super.id,
    super.parent,
  }) : super(child: null);

  /// Constructor designed to transform your width in pixel units
  /// to EMU
  ShapeBorder.pixels({
    required this.color,
    int width = 10,
    this.style = LineStyle.solid,
    this.cap = LineCap.flat,
    this.join = LineJoin.round,
    this.dashPattern,
    super.id,
    super.parent,
  })  : width = width.pixelsToEmu(dpi: 96).toInt(),
        super(child: null);

  /// Constructor designed to transform your width in point units
  /// to EMU
  ShapeBorder.pt({
    required this.color,
    int width = 20,
    this.style = LineStyle.solid,
    this.cap = LineCap.flat,
    this.join = LineJoin.round,
    this.dashPattern,
    super.id,
    super.parent,
  })  : width = width.ptToEmu().toInt(),
        super(child: null);

  /// Constructor designed to transform your width in centimeters units
  /// to EMU
  ShapeBorder.cm({
    required this.color,
    int width = 10,
    this.style = LineStyle.solid,
    this.cap = LineCap.flat,
    this.join = LineJoin.round,
    this.dashPattern,
    super.id,
    super.parent,
  })  : width = width.centimetersToEmu().toInt(),
        super(child: null);

  /// Constructor designed to transform your width in centimeters units
  /// to EMU
  ShapeBorder.mm({
    required this.color,
    int width = 1000,
    this.style = LineStyle.solid,
    this.cap = LineCap.flat,
    this.join = LineJoin.round,
    this.dashPattern,
    super.id,
    super.parent,
  })  : width = width.millimetersToEmu().toInt(),
        super(child: null);

  final Color color;

  /// The width of this component in EMU units
  final int width;
  final LineStyle style;
  final LineCap cap;
  final LineJoin join;
  final DashPattern? dashPattern;

  @override
  ShapeBorder get copy => ShapeBorder(
        id: id,
        parent: parent,
        color: color.copy,
        width: width,
        style: style,
        cap: cap,
        join: join,
        dashPattern: dashPattern,
      );

  @override
  ShapeBorder copyWith({
    String? id,
    DocxNode<void>? parent,
    Color? color,
    int? width,
    LineStyle? style,
    LineCap? cap,
    LineJoin? join,
    DashPattern? dashPattern,
  }) {
    return ShapeBorder(
      color: color ?? this.color.copy,
      width: width ?? this.width,
      style: style ?? this.style,
      cap: cap ?? this.cap,
      join: join ?? this.join,
      dashPattern: dashPattern ?? this.dashPattern,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'a:ln',
        attributes: <XmlAttribute>[
          XmlAttribute(
            'w'.toName(),
            width.toString(),
          ),
          if (cap != LineCap.flat)
            XmlAttribute(
              'cap'.toName(),
              _lineCapToXml(cap),
            ),
          if (join != LineJoin.round)
            XmlAttribute(
              'cmpd'.toName(),
              _lineJoinToXml(join),
            ),
        ],
        children: <XmlNode>[
          ...SolidFill(
            color: color,
          ).ensureInitialized(context).buildXml(),
          if (style != LineStyle.solid) _buildLineStyle(style, dashPattern),
        ],
      ),
    ];
  }

  XmlElement _buildLineStyle(LineStyle style, DashPattern? dashPattern) {
    final String? presetDash = _lineStyleToPresetDash(style);

    if (presetDash != null) {
      return XmlElement.tag(
        'a:prstDash',
        attributes: <XmlAttribute>[
          XmlAttribute('val'.toName(), presetDash),
        ],
        isSelfClosing: true,
      );
    } else if (dashPattern != null) {
      return XmlElement.tag(
        'a:custDash',
        children: <XmlNode>[
          XmlElement.tag(
            'a:ds',
            attributes: <XmlAttribute>[
              XmlAttribute('d'.toName(), dashPattern.pattern),
            ],
            isSelfClosing: true,
          ),
        ],
      );
    } else {
      // Default to solid if no pattern specified
      return XmlElement.tag(
        'a:prstDash',
        attributes: <XmlAttribute>[
          XmlAttribute('val'.toName(), 'solid'),
        ],
        isSelfClosing: true,
      );
    }
  }

  String? _lineStyleToPresetDash(LineStyle style) {
    return switch (style) {
      LineStyle.solid => 'solid',
      LineStyle.dash => 'dash',
      LineStyle.dot => 'dot',
      LineStyle.dashDot => 'dashDot',
      LineStyle.dashDotDot => 'dashDotDot',
      LineStyle.longDash => 'lgDash',
      LineStyle.systemDash => 'sysDash',
      LineStyle.systemDot => 'sysDot',
    };
  }

  String _lineCapToXml(LineCap cap) {
    return switch (cap) {
      LineCap.flat => 'flat',
      LineCap.round => 'rnd',
      LineCap.square => 'sq',
    };
  }

  String _lineJoinToXml(LineJoin join) {
    return switch (join) {
      LineJoin.round => 'rnd',
      LineJoin.bevel => 'bevel',
      LineJoin.miter => 'miter',
    };
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <DocxNode<dynamic>>[this] : null;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}

enum LineStyle {
  solid,
  dash,
  dot,
  dashDot,
  dashDotDot,
  longDash,
  systemDash,
  systemDot
}

enum LineCap { flat, round, square }

enum LineJoin { round, bevel, miter }

class DashPattern {
  const DashPattern(this.pattern);
  // e.g., "20000 10000" for 2mm dash, 1mm space

  const DashPattern.easy({
    required int dash,
    required int space,
  }) : pattern = '$dash $space';

  final String pattern;
}
