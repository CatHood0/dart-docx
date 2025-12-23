import '../../../docx.dart';

/// A builder class for creating and configuring [Style] objects.
///
/// This class provides a fluent API to define various paragraph and character
/// style properties such as font, size, color, alignment, spacing, and borders.
///
/// TODO: refactor this file and separate elements in granular parts
/// TODO: we need to make this immutable
class StyleBuilder {
  /// Internal constructor for [StyleBuilder].
  ///
  /// [id] is the unique identifier for the style (w:styleId).
  /// [type] specifies if it's a 'paragraph' or 'character' style.
  /// [_name] is the display name of the style in Word.
  StyleBuilder._(this.id, this.type, [this._name = '']);

  /// Creates a [StyleBuilder] for a paragraph style.
  ///
  /// [id] is the internal ID for the style.
  /// [name] is the display name of the style. If not provided, [id] is used.
  factory StyleBuilder.paragraph(String id, {String? name}) {
    return StyleBuilder._(id, Style.paragraphType, name ?? '');
  }

  /// Creates a [StyleBuilder] for a character style.
  ///
  /// [id] is the internal ID for the style.
  /// [name] is the display name of the style. If not provided, [id] is used.
  factory StyleBuilder.character(String id, {String? name}) {
    return StyleBuilder._(id, Style.characterType, name ?? id);
  }

  /// Creates a [StyleBuilder] for a paragraph style
  /// that is not in DocumentStylesSheet
  factory StyleBuilder.singularP({String? name}) {
    return StyleBuilder._(nanoid(5), Style.paragraphType, name ?? '');
  }

  /// Creates a [StyleBuilder] for a character style
  /// that is not in DocumentStylesSheet
  factory StyleBuilder.singularC({String? name}) {
    return StyleBuilder._(nanoid(5), Style.characterType, name ?? '');
  }

  /// The internal identifier of the style, used in `w:styleId`.
  final String id;

  /// The display name of the style, used in `w:name`.
  String _name;

  /// The type of the style, either 'paragraph' or 'character'.
  final String type;

  List<StyleConfigurator> _configurators = [];
  // Paragraph properties
  String? _basedOn;
  String? _next;
  bool _widowControl = false;
  bool? _defaultValue;
  int? _uiPriority;
  bool _qFormat = false;
  bool _semiHidden = false;
  bool _unhideWhenUsed = false;

  // Run properties (character formatting)
  /// Usually used for w:sz that settings the size of
  /// most of the common characters
  double? _fontSize;

  /// Usually used for w:szCs that settings the size of
  /// chinese, japanase and Korean characters
  double? _fontEastAsiaSize;
  String? _fontFamily;
  String? _color;
  String? _highlightColor;
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;

  // Paragraph properties (continued)
  Alignment? _alignment;
  int? _spacingBefore;
  int? _spacingAfter;
  LineRule? _lineRule;
  int? _lineSpacing;
  int? _firstLineIndent;
  int? _leftIndent;
  int? _hangingIndent;
  bool _keepNext = false;
  bool _keepLines = false;
  int? _outlineLevel;

  // Language setting for runs
  DocxLanguage? _language;

  /// Stores the configuration for paragraph borders.
  ///
  /// The map keys represent border sides ('top', 'bottom', 'left', 'right').
  /// The nested map contains border attributes like 'val' (style), 'sz' (size),
  /// and 'color' (hex code).
  /// E.g., `{'top': {'val': 'single', 'sz': '4', 'color': 'auto'}}`
  final Map<String, Map<String, String>> _borders =
      <String, Map<String, String>>{};

  /// Sets the display name for the style.
  ///
  /// [styleName] is the name that will be shown in the Word editor.
  StyleBuilder name(String styleName) {
    _name = styleName;
    return this;
  }

  StyleBuilder withConfigurators(Iterable<StyleConfigurator> configs) {
    _configurators.addAll(configs);
    return this;
  }

  /// Gets the current display name of the style.
  String get getName => _name;

  /// Specifies the ID of the style on which this style is based.
  ///
  /// [styleId] is the `w:styleId` of the base style.
  StyleBuilder basedOn(String styleId) {
    _basedOn = styleId;
    return this;
  }

  /// Activates Widow/Orphan control for the paragraph.
  ///
  /// Widow/Orphan control prevents single lines of a paragraph from being left
  /// alone at the top or bottom of a page.
  ///
  /// Example:
  /// Without widowControl (problem):
  /// ```
  /// ┌─────────────────┐ ┌─────────────────┐
  /// │ PAGE 1          │ │ PAGE 2          │
  /// │ ...paragraph    │ │                 │
  /// │ text that       │ │ Chapter 1:      │ ← Orphan
  /// │ continues on    │ │ Introduction    │
  /// └─────────────────┘ └─────────────────┘
  /// ```
  /// With widowControl (corrected):
  /// ```
  /// ┌─────────────────┐ ┌─────────────────┐
  /// │ PAGE 1          │ │ PAGE 2          │
  /// │ ...paragraph    │ │ Chapter 1:      │
  /// │ text that       │ │ Introduction    │
  /// └─────────────────┘ └─────────────────┘
  /// ```
  /// Useful when creating a writing application to improve readability.
  /// This setting is applicable only to paragraph styles.
  StyleBuilder activateWindowControl() {
    _widowControl = true;
    return this;
  }

  /// Specifies the `w:styleId` of the style that is applied to the next paragraph
  /// when the current paragraph ends.
  ///
  /// This setting is applicable only to paragraph styles.
  StyleBuilder next(String styleId) {
    _next = styleId;
    return this;
  }

  /// Sets whether this style is a default style for the document.
  ///
  /// [isDefault] true if it's a default style, false otherwise.
  StyleBuilder defaultValue(bool isDefault) {
    _defaultValue = isDefault;
    return this;
  }

  /// Specifies the UI priority of the style in the Word interface.
  ///
  /// Styles with lower priority values are displayed first.
  /// [priority] is an integer representing the priority level.
  StyleBuilder uiPriority(int priority) {
    _uiPriority = priority;
    return this;
  }

  /// Specifies whether this style should be included in the Quick Style gallery.
  ///
  /// [enabled] true to include in Quick Styles, false otherwise.
  StyleBuilder qFormat(bool enabled) {
    _qFormat = enabled;
    return this;
  }

  /// Specifies whether this style should be hidden from the user interface.
  ///
  /// [hidden] true to hide the style, false to show it.
  StyleBuilder semiHidden(bool hidden) {
    _semiHidden = hidden;
    return this;
  }

  /// Specifies whether this style should become visible in the UI when it is used.
  ///
  /// [unhide] true to unhide when used, false otherwise.
  StyleBuilder unhideWhenUsed(bool unhide) {
    _unhideWhenUsed = unhide;
    return this;
  }

  /// Sets the font size for the style.
  ///
  /// [size] is the font size in points (e.g., 12.0).
  StyleBuilder fontSize(double size, [double? eastAsiaSize]) {
    _fontSize = size;
    _fontEastAsiaSize = eastAsiaSize ?? size;
    return this;
  }

  /// Sets the font family for the style.
  ///
  /// [family] is the name of the font family (e.g., 'Times New Roman').
  StyleBuilder fontFamily(String family) {
    _fontFamily = family;
    return this;
  }

  /// Sets the text color for the style.
  ///
  /// [hexColor] is the hexadecimal color code (e.g., 'FF0000' for red).
  StyleBuilder color(String hexColor) {
    _color = hexColor;
    return this;
  }

  /// Sets the highlight color for the text in the style.
  ///
  /// [hexColor] is the hexadecimal color code.
  StyleBuilder highlight(String hexColor) {
    _highlightColor = hexColor;
    return this;
  }

  /// Applies bold formatting to the text.
  StyleBuilder bold() {
    isBold = true;
    return this;
  }

  /// Applies italic formatting to the text.
  StyleBuilder italic() {
    isItalic = true;
    return this;
  }

  /// Applies underline formatting to the text.
  StyleBuilder underline() {
    isUnderline = true;
    return this;
  }

  /// Sets the paragraph alignment.
  ///
  /// [align] specifies the horizontal alignment (e.g., [Alignment.left]).
  /// This setting is applicable only to paragraph styles.
  StyleBuilder alignment(Alignment align) {
    _alignment = align;
    return this;
  }

  /// Sets the spacing before and after the paragraph.
  ///
  /// [before] is spacing before the paragraph in twips (1/20th of a point).
  /// [after] is spacing after the paragraph in twips.
  /// This setting is applicable only to paragraph styles.
  StyleBuilder spacing({
    int? before,
    int? after,
    int? line,
    LineRule rule = LineRule.auto,
  }) {
    if (before != null) _spacingBefore = before;
    if (after != null) _spacingAfter = after;
    if (line != null) _lineSpacing = after;
    _lineRule = rule;
    return this;
  }

  /// Sets the line spacing for the paragraph.
  ///
  /// [value] is the line spacing in twips.
  /// This setting is applicable only to paragraph styles.
  StyleBuilder lineSpacing(int value) {
    _lineSpacing = value;
    return this;
  }

  /// Sets the paragraph indentation.
  ///
  /// [firstLine] is the indentation for the first line of the paragraph in twips.
  /// [left] is the left indentation for the paragraph in twips.
  /// [hanging] is the hanging indentation for the paragraph in twips.
  /// This setting is applicable only to paragraph styles.
  StyleBuilder indent({int? firstLine, int? left, int? hanging}) {
    if (firstLine != null) _firstLineIndent = firstLine;
    if (left != null) _leftIndent = left;
    if (hanging != null) _hangingIndent = hanging;
    return this;
  }

  /// Specifies that the paragraph should be kept with the next paragraph
  /// on the same page.
  ///
  /// [keep] true to keep with next, false otherwise.
  /// This setting is applicable only to paragraph styles.
  StyleBuilder keepNext(bool keep) {
    _keepNext = keep;
    return this;
  }

  /// Specifies that all lines of the paragraph should be kept together
  /// on the same page.
  ///
  /// [keep] true to keep lines together, false otherwise.
  /// This setting is applicable only to paragraph styles.
  StyleBuilder keepLines(bool keep) {
    _keepLines = keep;
    return this;
  }

  /// Sets the outline level for the paragraph.
  ///
  /// [level] is an integer from 0 to 8 (0 for Body Text, 1-8 for heading levels).
  /// This setting is applicable only to paragraph styles.
  StyleBuilder outlineLevel(int level) {
    _outlineLevel = level;
    return this;
  }

  /// Sets the language for the text.
  ///
  /// [langCode] is the language code (e.g., 'en-US', 'es-MX').
  StyleBuilder lang(DocxLanguage language) {
    _language = language;
    return this;
  }

  /// Configures the borders for the paragraph.
  ///
  /// This method is applicable only to paragraph styles.
  ///
  /// - [top], [bottom], [left], [right] specify the [BorderStyle] for each side.
  /// - [topSize], [bottomSize], [leftSize], [rightSize] specify the border thickness
  ///   in eighths of a point (e.g., 4 for 0.5pt, 8 for 1pt). Default is 4.
  /// - [topColor], [bottomColor], [leftColor], [rightColor] specify the border color
  ///   as a hexadecimal string (e.g., '000000' for black). Default is 'auto'.
  StyleBuilder borders({
    BorderStyle? top,
    int? topSize,
    String? topColor,
    BorderStyle? bottom,
    int? bottomSize,
    String? bottomColor,
    BorderStyle? left,
    int? leftSize,
    String? leftColor,
    BorderStyle? right,
    int? rightSize,
    String? rightColor,
  }) {
    // Borders apply to paragraph blocks, not characters.
    if (type != Style.paragraphType) {
      return this;
    }

    if (top != null) {
      _borders['top'] = {
        'val': top.value,
        'sz': (topSize ?? 4).toString(), // Default 0.5pt
        'color': topColor ?? 'auto',
      };
    }
    if (bottom != null) {
      _borders['bottom'] = {
        'val': bottom.value,
        'sz': (bottomSize ?? 4).toString(),
        'color': bottomColor ?? 'auto',
      };
    }
    if (left != null) {
      _borders['left'] = {
        'val': left.value,
        'sz': (leftSize ?? 4).toString(),
        'color': leftColor ?? 'auto',
      };
    }
    if (right != null) {
      _borders['right'] = {
        'val': right.value,
        'sz': (rightSize ?? 4).toString(),
        'color': rightColor ?? 'auto',
      };
    }
    return this;
  }

  /// Builds and returns the final [Style] object based on the configurations
  /// set in the builder.
  ///
  /// This method aggregates all configured properties into a list of
  /// [StyleConfigurator] objects and creates a new [Style] instance.
  Style build() {
    final List<StyleConfigurator> configurators = <StyleConfigurator>[];

    if (_basedOn != null) {
      configurators.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'basedOn',
          value: _basedOn!,
        ),
      );
    }

    if (_next != null) {
      configurators.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'next',
          value: _next!,
        ),
      );
    }

    if (_uiPriority != null) {
      configurators.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'uiPriority',
          value: _uiPriority!.toString(),
        ),
      );
    }

    if (_qFormat) {
      configurators.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'qFormat',
        ),
      );
    }

    if (_semiHidden) {
      configurators.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'semiHidden',
        ),
      );
    }

    if (_unhideWhenUsed) {
      configurators.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'unhideWhenUsed',
        ),
      );
    }

    if (type == Style.paragraphType) {
      final paragraphConfigs = <StyleConfigurator>[];

      if (_spacingBefore != null ||
          _spacingAfter != null ||
          _lineSpacing != null) {
        final spacingConfigs = <StyleConfigurator>[];

        if (_spacingBefore != null) {
          spacingConfigs.add(
            StyleConfigurator.selfClosing(
              prefix: 'w',
              propertyName: 'before',
              value: _spacingBefore.toString(),
            ),
          );
        }

        if (_spacingAfter != null) {
          spacingConfigs.add(
            StyleConfigurator.selfClosing(
              prefix: 'w',
              propertyName: 'after',
              value: _spacingAfter.toString(),
            ),
          );
        }

        if (_lineSpacing != null) {
          spacingConfigs
            ..add(
              StyleConfigurator.selfClosing(
                prefix: 'w',
                propertyName: 'line',
                value: _lineSpacing.toString(),
              ),
            )
            ..add(
              StyleConfigurator.selfClosing(
                prefix: 'w',
                propertyName: 'lineRule',
                value: _lineRule!.name,
              ),
            );
        }

        if (spacingConfigs.isNotEmpty) {
          paragraphConfigs.add(
            StyleConfigurator.noSelfClosing(
              prefix: 'w',
              propertyName: 'spacing',
              configurators: spacingConfigs,
            ),
          );
        }
      }

      if (_widowControl) {
        paragraphConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'widowControl',
            value: true,
          ),
        );
      }

      if (_alignment != null) {
        paragraphConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'jc',
            value: _alignment!.name,
          ),
        );
      }

      if (_firstLineIndent != null ||
          _leftIndent != null ||
          _hangingIndent != null) {
        final indentConfigs = <StyleConfigurator>[];

        if (_firstLineIndent != null) {
          indentConfigs.add(
            StyleConfigurator.selfClosing(
              prefix: 'w',
              propertyName: 'firstLine',
              value: _firstLineIndent.toString(),
            ),
          );
        }

        if (_leftIndent != null) {
          indentConfigs.add(
            StyleConfigurator.selfClosing(
              prefix: 'w',
              propertyName: 'left',
              value: _leftIndent.toString(),
            ),
          );
        }

        if (_hangingIndent != null) {
          indentConfigs.add(
            StyleConfigurator.selfClosing(
              prefix: 'w',
              propertyName: 'hanging',
              value: _hangingIndent.toString(),
            ),
          );
        }

        if (indentConfigs.isNotEmpty) {
          paragraphConfigs.add(
            StyleConfigurator.noSelfClosing(
              prefix: 'w',
              propertyName: 'ind',
              configurators: indentConfigs,
            ),
          );
        }
      }

      if (_keepNext) {
        paragraphConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'keepNext',
          ),
        );
      }

      if (_keepLines) {
        paragraphConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'keepLines',
          ),
        );
      }

      if (_outlineLevel != null) {
        paragraphConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'outlineLvl',
            value: _outlineLevel.toString(),
          ),
        );
      }

      // Generate border configurators if any border is set
      if (_borders.isNotEmpty) {
        final List<StyleConfigurator> borderConfigs = <StyleConfigurator>[];
        _borders.forEach((
          String key,
          Map<String, String> value,
        ) {
          borderConfigs.add(
            StyleConfigurator.selfClosing(
              prefix: 'w',
              // 'top', 'bottom', 'left', 'right'
              propertyName: key,
              // {'val': 'single', 'sz': '4', 'color': 'auto'}
              attributes: value,
            ),
          );
        });
        paragraphConfigs.add(
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pBdr', // Paragraph Borders container
            configurators: borderConfigs,
          ),
        );
      }

      if (paragraphConfigs.isNotEmpty) {
        configurators.add(
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'pPr',
            configurators: paragraphConfigs,
          ),
        );
      }
    }

    final List<StyleConfigurator> textConfigs = <StyleConfigurator>[];

    if (_fontFamily != null) {
      textConfigs.add(
        StyleConfigurator.noSelfClosing(
          prefix: 'w',
          propertyName: 'rFonts',
          attributes: <String, dynamic>{
            'w:ascii': _fontFamily,
            'w:hAnsi': _fontFamily,
            'w:eastAsia': _fontFamily,
            'w:cs': _fontFamily,
          },
        ),
      );
    }

    if (_fontSize != null) {
      final int halfPoints = (_fontSize! * 2).toInt();
      final int halfPointsCs = (_fontEastAsiaSize! * 2).toInt();
      textConfigs
        ..add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'sz',
            value: halfPoints.toString(),
          ),
        )
        ..add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'szCs',
            value: halfPointsCs.toString(),
          ),
        );
    }

    if (_color != null) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'color',
          value: _color,
        ),
      );
    }

    if (_highlightColor != null) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'highlight',
          value: _highlightColor,
        ),
      );
    }

    if (isBold) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'b',
        ),
      );
    }

    if (isItalic) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'i',
        ),
      );
    }

    if (isUnderline) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'u',
          value: 'single',
        ),
      );
    }

    if (_language != null) {
      textConfigs.addAll(
        [
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'lang',
            attributes: {'w:val': _language!.language},
          ),
          if (_language!.eastAsia.isNotEmpty)
            StyleConfigurator.selfClosing(
              prefix: 'w',
              propertyName: 'eastAsia',
              attributes: {'w:val': _language!.eastAsia},
            ),
          if (_language!.bidi.isNotEmpty)
            StyleConfigurator.selfClosing(
              prefix: 'w',
              propertyName: 'bidi',
              attributes: {'w:val': _language!.bidi},
            ),
        ],
      );
    }

    if (textConfigs.isNotEmpty) {
      configurators.add(
        StyleConfigurator.noSelfClosing(
          prefix: 'w',
          propertyName: 'rPr',
          configurators: textConfigs,
        ),
      );
    }

    if (_configurators.isNotEmpty) {
      configurators.addAll(_configurators);
    }

    return Style(
      type: type,
      styleId: id,
      styleName: _name,
      defaultValue: _defaultValue,
      configurators: configurators,
    );
  }
}

/// Represents the horizontal alignment options for a paragraph.
enum Alignment { left, center, right, both }

enum LineRule {
  atLeast('atLeast'),
  exact('exact'),
  auto('auto');

  /// Creates a [LineRule] with its corresponding WordML value.
  const LineRule(this.value);

  /// The WordML string value for the spacing style.
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
