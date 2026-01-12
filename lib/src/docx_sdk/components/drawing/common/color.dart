import 'package:xml/xml.dart';

import '../../../../../docx.dart';

enum ColorType { bgr, rgb, theme, system }

enum SystemColor { window, windowText, highlight, highlightText }

/// Color representation in DrawingML.
///
/// Can be specified as RGB value, theme color, or system color.
class Color extends DocxTreeNode<void> {
  Color.bgr(int value, [int? alpha])
      : type = ColorType.bgr,
        alpha = alpha ?? -1,
        rgbValue = value,
        themeColor = null,
        systemColor = null,
        super(data: null);

  Color.rgb(int value, [int? alpha])
      : type = ColorType.rgb,
        alpha = alpha ?? -1,
        rgbValue =
            value.toString().startsWith('0x') ? value : int.parse('0x$value'),
        themeColor = null,
        systemColor = null,
        super(data: null);

  Color.theme(String themeColorName)
      : type = ColorType.theme,
        themeColor = themeColorName,
        alpha = -1,
        rgbValue = null,
        systemColor = null,
        super(data: null);

  Color.system(SystemColor system)
      : type = ColorType.system,
        alpha = -1,
        systemColor = system,
        rgbValue = null,
        themeColor = null,
        super(data: null);

  final ColorType type;
  final int? rgbValue;
  final int alpha;
  final String? themeColor;
  final SystemColor? systemColor;

  String? toColorValue() {
    if (rgbValue != null) {
      return rgbValue!.toRadixString(16).padLeft(
            6,
            '0',
          );
    }
    return null;
  }

  @override
  Color get copy => switch (type) {
        ColorType.rgb => Color.rgb(rgbValue!, alpha),
        ColorType.bgr => Color.bgr(rgbValue!, alpha),
        ColorType.theme => Color.theme(themeColor!),
        ColorType.system => Color.system(systemColor!),
      };

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return switch (type) {
      ColorType.rgb => <XmlElement>[
          XmlElement.tag(
            'a:srgbClr',
            attributes: <XmlAttribute>[
              XmlAttribute(
                XmlName.fromString('val'),
                toColorValue()!.toUpperCase(),
              ),
            ],
            children: <XmlNode>[
              if (alpha != -1)
                XmlElement.tag(
                  'a:alpha',
                  attributes: <XmlAttribute>[
                    XmlAttribute(
                      XmlName.fromString('val'),
                      alpha.toString(),
                    ),
                  ],
                  isSelfClosing: true,
                ),
            ],
            isSelfClosing: alpha == -1,
          ),
        ],
      ColorType.bgr => <XmlElement>[
          XmlElement.tag(
            'a:srgbClr',
            attributes: <XmlAttribute>[
              XmlAttribute(
                XmlName.fromString('val'),
                toColorValue()!.toUpperCase(),
              ),
            ],
            children: <XmlNode>[
              if (alpha != -1)
                XmlElement.tag(
                  'a:alpha',
                  attributes: <XmlAttribute>[
                    XmlAttribute(
                      XmlName.fromString('val'),
                      alpha.toString(),
                    ),
                  ],
                  isSelfClosing: true,
                ),
            ],
            isSelfClosing: alpha == -1,
          ),
        ],
      ColorType.theme => <XmlElement>[
          XmlElement.tag(
            'a:schemeClr',
            attributes: <XmlAttribute>[
              XmlAttribute(XmlName.fromString('val'), themeColor!),
            ],
            isSelfClosing: true,
          ),
        ],
      ColorType.system => <XmlElement>[
          XmlElement.tag(
            'a:sysClr',
            attributes: <XmlAttribute>[
              XmlAttribute(
                  XmlName.fromString('val'), _systemColorToXml(systemColor!)),
            ],
            isSelfClosing: true,
          ),
        ],
    };
  }

  String _systemColorToXml(SystemColor systemColor) {
    return switch (systemColor) {
      SystemColor.window => 'window',
      SystemColor.windowText => 'windowText',
      SystemColor.highlight => 'highlight',
      SystemColor.highlightText => 'highlightText',
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
    return shouldGetElement(this) ? <Color>[this] : null;
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
