import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../../../../core/extensions/string_ext.dart';

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

/// ShapeOutline/border styling for shapes (a:ln).
///
/// Defines the line properties around the shape perimeter, including
/// color, width, dash pattern, and cap/join styles.
class ShapeOutline extends DocxTreeNode<void> {
  ShapeOutline({
    required this.color,
    required this.width,
    this.style = LineStyle.solid,
    this.cap = LineCap.flat,
    this.join = LineJoin.round,
    this.dashPattern,
  }) : super(data: null);

  final Color color;

  /// The width of this component in EMU units
  final int width;
  final LineStyle style;
  final LineCap cap;
  final LineJoin join;
  final DashPattern? dashPattern;

  @override
  ShapeOutline get copy => ShapeOutline(
        color: color.copy,
        width: width,
        style: style,
        cap: cap,
        join: join,
        dashPattern: dashPattern,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    context.currentContentPart = this;
    return <XmlElement>[
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
            data: color,
          ).buildXml(context: context),
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
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <DocxTreeNode<dynamic>>[this] : null;
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
