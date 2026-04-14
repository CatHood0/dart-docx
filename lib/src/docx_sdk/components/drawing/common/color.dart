import 'package:xml/xml.dart';
import '../../../../../docx.dart';
export '../utils/colors.dart';

enum ColorType { bgr, rgb, theme, system }

enum SystemColor { window, windowText, highlight, highlightText }

/// Color representation in DrawingML.
///
/// Can be specified as RGB value, theme color, or system color.
class Color extends DocxTreeNode<void> {
  // Constructor for build hex integers like: 0xFF000000 or 0x000000
  Color(int value)
      : type = ColorType.rgb,
        alpha = value > 0xFFFFFF ? ((value >> 24) & 0xFF) : -1,
        rgbValue = value & 0xFFFFFF,
        themeColor = null,
        systemColor = null,
        super(child: null);

  Color.raw(int value, [int? alpha])
      : type = ColorType.rgb,
        alpha = alpha ?? -1,
        // this fixes something that haves if you just pass
        // 0x<ColorHex>
        rgbValue = int.parse('$value'),
        themeColor = null,
        systemColor = null,
        super(child: null);

  // Constructor for build hex like: #BBGGRR
  Color.bgr(int value, [int? alpha])
      : type = ColorType.bgr,
        alpha = alpha ?? -1,
        rgbValue = int.parse('$value'),
        themeColor = null,
        systemColor = null,
        super(child: null);

  Color.theme(String themeColorName)
      : type = ColorType.theme,
        themeColor = themeColorName,
        alpha = -1,
        rgbValue = null,
        systemColor = null,
        super(child: null);

  Color.system(SystemColor system)
      : type = ColorType.system,
        alpha = -1,
        systemColor = system,
        rgbValue = null,
        themeColor = null,
        super(child: null);

  /// Constructor para crear color desde valores RGB individuales (0-255)
  Color.fromRgb(int red, int green, int blue, [int? alpha])
      : type = ColorType.rgb,
        alpha = alpha ?? -1,
        rgbValue = (red << 16) | (green << 8) | blue,
        themeColor = null,
        systemColor = null,
        super(child: null);

  /// Constructor para crear color desde valores RGB con canal alpha (0-255)
  Color.fromRgba(int red, int green, int blue, this.alpha)
      : type = ColorType.rgb,
        rgbValue = (red << 16) | (green << 8) | blue,
        themeColor = null,
        systemColor = null,
        super(child: null);

  /// Constructor para crear color desde un string hexadecimal (#RRGGBB o #AARRGGBB)
  Color.fromHex(String hexString, [int? alpha])
      : type = ColorType.rgb,
        alpha = alpha ??
            _parseAlphaFromHex(int.parse('0x${(hexString.substring(1))}')),
        rgbValue = _parseRgbFromHex(int.parse('0x${(hexString.substring(1))}')),
        themeColor = null,
        systemColor = null,
        super(child: null);

  /// Constructor para crear color desde un string hexadecimal sin el signo #
  Color.fromHexWithoutHash(String hexString)
      : type = ColorType.rgb,
        alpha = _extractAlphaFromHexString(hexString),
        rgbValue = _extractRgbFromHexString(hexString),
        themeColor = null,
        systemColor = null,
        super(child: null);

  /// Constructor para crear color desde valores CMYK (convertido a RGB aproximado)
  Color.fromCmyk(int cyan, int magenta, int yellow, int black, [int? alpha])
      : type = ColorType.rgb,
        alpha = alpha ?? -1,
        rgbValue = _cmykToRgb(cyan, magenta, yellow, black),
        themeColor = null,
        systemColor = null,
        super(child: null);

  /// Constructor para crear color desde un valor HSV (convertido a RGB)
  Color.fromHsv(double hue, double saturation, double value, [int? alpha])
      : type = ColorType.rgb,
        alpha = alpha ?? -1,
        rgbValue = _hsvToRgb(hue, saturation, value),
        themeColor = null,
        systemColor = null,
        super(child: null);

  final ColorType type;
  final int? rgbValue;
  final int alpha;
  final String? themeColor;
  final SystemColor? systemColor;

  bool get isRGB => rgbValue != null;

  String? toColorValue() {
    if (rgbValue != null) {
      final String value = rgbValue!.toRadixString(16).padLeft(
            6,
            '0',
          );
      return value;
    }
    return null;
  }

  /// Obtiene el valor RGB como string hexadecimal (#RRGGBB)
  String toHexString() {
    if (rgbValue != null) {
      return '#${rgbValue!.toRadixString(16).padLeft(6, '0').toUpperCase()}';
    }
    return '#000000';
  }

  /// Obtiene el valor RGB con alpha como string hexadecimal (#AARRGGBB)
  String toHexStringWithAlpha() {
    if (rgbValue != null && alpha != -1) {
      final String alphaHex =
          alpha.toRadixString(16).padLeft(2, '0').toUpperCase();
      final String rgbHex =
          rgbValue!.toRadixString(16).padLeft(6, '0').toUpperCase();
      return '#$alphaHex$rgbHex';
    }
    return toHexString();
  }

  /// Obtiene los componentes RGB individuales (0-255)
  (int red, int green, int blue) get rgbComponents {
    if (rgbValue != null) {
      final int red = (rgbValue! >> 16) & 0xFF;
      final int green = (rgbValue! >> 8) & 0xFF;
      final int blue = rgbValue! & 0xFF;
      return (red, green, blue);
    }
    return (0, 0, 0);
  }

  @override
  Color get copy => switch (type) {
        ColorType.rgb => Color.raw(rgbValue!, alpha),
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

  static int _extractRgbFromHexString(String hexString) {
    String clean = hexString.replaceFirst('#', '');

    if (clean.length == 8) {
      String rgbHex = clean.substring(2);
      return int.parse(rgbHex, radix: 16);
    } else if (clean.length == 6) {
      return int.parse(clean, radix: 16);
    } else {
      throw ArgumentError('Invalid hex format. Use #RRGGBB or #AARRGGBB');
    }
  }

  static int _extractAlphaFromHexString(String hexString) {
    String clean = hexString.replaceFirst('#', '');

    if (clean.length == 8) {
      String alphaHex = clean.substring(0, 2);
      return int.parse(alphaHex, radix: 16);
    }

    return -1;
  }

  static int _parseRgbFromHex(int hexadecimal) {
    // Thanks deepseek, I hate you so much, but you help me this one!

    // If it's a RGB valid value (0-16777215), just return it
    if (hexadecimal >= 0 && hexadecimal <= 0xFFFFFF) {
      return hexadecimal;
    }

    // if it contains alpha (0xAARRGGBB)
    if (hexadecimal > 0xFFFFFF) {
      // this magic trick removes the alpha mask
      return hexadecimal & 0xFFFFFF;
    }

    return 0;
  }

  static int _parseAlphaFromHex(int hex, {int defaultAlpha = -1}) {
    if (hex > 0xFFFFFF) {
      // just get the alpha from the highest bits
      return (hex >> 24) & 0xFF;
    }
    return defaultAlpha;
  }

  static int _cmykToRgb(int cyan, int magenta, int yellow, int black) {
    final double c = cyan / 100;
    final double m = magenta / 100;
    final double y = yellow / 100;
    final double k = black / 100;

    final int red = ((1 - c) * (1 - k) * 255).round();
    final int green = ((1 - m) * (1 - k) * 255).round();
    final int blue = ((1 - y) * (1 - k) * 255).round();

    return (red << 16) | (green << 8) | blue;
  }

  static int _hsvToRgb(double hue, double saturation, double value) {
    final double c = value * saturation;
    final double x = c * (1 - ((hue / 60) % 2 - 1).abs());
    final double m = value - c;

    double r1 = 0, g1 = 0, b1 = 0;

    if (hue >= 0 && hue < 60) {
      r1 = c;
      g1 = x;
      b1 = 0;
    } else if (hue >= 60 && hue < 120) {
      r1 = x;
      g1 = c;
      b1 = 0;
    } else if (hue >= 120 && hue < 180) {
      r1 = 0;
      g1 = c;
      b1 = x;
    } else if (hue >= 180 && hue < 240) {
      r1 = 0;
      g1 = x;
      b1 = c;
    } else if (hue >= 240 && hue < 300) {
      r1 = x;
      g1 = 0;
      b1 = c;
    } else if (hue >= 300 && hue < 360) {
      r1 = c;
      g1 = 0;
      b1 = x;
    }

    final int red = ((r1 + m) * 255).round();
    final int green = ((g1 + m) * 255).round();
    final int blue = ((b1 + m) * 255).round();

    return (red << 16) | (green << 8) | blue;
  }
}
