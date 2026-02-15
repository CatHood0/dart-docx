import '../../../docx.dart';
import '../extensions/num_extensions.dart';

/// A builder class for creating and configuring [Style] objects.
///
/// This class provides a fluent API to define various paragraph and character
/// style properties such as font, size, color, alignment, spacing, and borders.
///
// TODO: we need to filter or make a way to filter some rPr properties
// for styles.xml, since is not allowed using things like bold, italic,
// or toggle attributes. Idk exactly why, but we need to fix it
class StyleBuilder {
  /// Internal constructor for [StyleBuilder].
  ///
  /// [id] is the unique identifier for the style (w:styleId).
  /// [type] specifies if it's a 'paragraph' or 'character' style.
  /// [_names] is the display name of the style in Word.
  StyleBuilder._(this.id, this.type);

  /// Creates a [StyleBuilder] for a paragraph style.
  ///
  /// [id] is the internal ID for the style.
  /// [name] is the display name of the style. If not provided, [id] is used.
  factory StyleBuilder.paragraph(String id) {
    return StyleBuilder._(id, Style.paragraphType);
  }

  /// Creates a [StyleBuilder] for a list style.
  ///
  /// [id] is the internal ID for the style.
  /// [name] is the display name of the style. If not provided, [id] is used.
  factory StyleBuilder.list(String id) {
    return StyleBuilder._(id, Style.listType);
  }

  /// Creates a [StyleBuilder] for a numbering style.
  ///
  /// [id] is the internal ID for the style.
  /// [name] is the display name of the style. If not provided, [id] is used.
  factory StyleBuilder.numbering(String id) {
    return StyleBuilder._(id, Style.numberingType);
  }

  /// Creates a [StyleBuilder] for a character style.
  ///
  /// [id] is the internal ID for the style.
  /// [name] is the display name of the style. If not provided, [id] is used.
  factory StyleBuilder.character(String id) {
    return StyleBuilder._(id, Style.characterType);
  }

  /// Creates a [StyleBuilder] for a paragraph style
  /// that is not in DocumentStylesSheet
  factory StyleBuilder.singularP() {
    return StyleBuilder._(nanoid(5), Style.paragraphType);
  }

  /// Creates a [StyleBuilder] for a character style
  /// that is not in DocumentStylesSheet
  factory StyleBuilder.singularC() {
    return StyleBuilder._(nanoid(5), Style.characterType);
  }

  /// Creates a [StyleBuilder] for a list style
  /// that is not in DocumentStylesSheet
  factory StyleBuilder.singularL() {
    return StyleBuilder._(nanoid(5), Style.listType);
  }

  /// Creates a [StyleBuilder] for a numbering style
  /// that is not in DocumentStylesSheet
  factory StyleBuilder.singularN() {
    return StyleBuilder._(nanoid(5), Style.numberingType);
  }

  /// The internal identifier of the style, used in `w:styleId`.
  final String id;

  /// The display name of the style, used in `w:name`.
  String? _name;

  /// The type of the style, either 'paragraph' or 'character'.
  final String type;

  final List<StyleConfigurator> _configurators = <StyleConfigurator>[];
  // Paragraph properties
  String? _basedOn;
  String? _next;
  bool _widowControl = false;
  Object? _defaultValue;
  int? _uiPriority;
  bool _qFormat = false;
  bool _semiHidden = false;
  bool _unhideWhenUsed = false;
  bool _contextualSpacing = false;
  bool _locked = false;

  // Run properties (character formatting)
  /// Usually used for w:sz that settings the size of
  /// most of the common characters
  num? _fontSize;

  /// Usually used for w:szCs that settings the size of
  /// chinese, japanase and Korean characters
  num? _fontEastAsiaSize;
  String? _fontFamily;
  Color? _color;
  Color? _highlightColor;
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  bool isStrike = false;
  bool isDoubleStrike = false;
  bool _isCaps = false;
  bool _isSmallCaps = false;
  Script? _verticalAlign;

  // Paragraph properties (continued)
  Alignment? _alignment;
  int? _spacingBefore;
  int? _spacingAfter;
  LineRule? _lineRule;
  int? _lineSpacing;
  int? _firstLineIndent;
  int? _leftIndent;
  int? _rightIndent;
  int? _hangingIndent;
  // Useful for RTL languages
  int? _startIndent;
  // Useful for RTL languages
  int? _endIndent;
  bool _keepNext = false;
  bool _keepLines = false;
  int? _outlineLevel;
  bool _pageBreakBefore = false;
  String? _shadingColor;
  ShadingPattern? _shadingPattern;

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
  /// [language] is the language that correspond for this [styleName]
  StyleBuilder name(String styleName) {
    _name = styleName;
    return this;
  }

  StyleBuilder withConfigurators(Iterable<StyleConfigurator> configs) {
    _configurators.addAll(configs);
    return this;
  }

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

  StyleBuilder contextualSpacing(bool shouldUse) {
    _contextualSpacing = shouldUse;
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
  StyleBuilder defaultValue(bool value) {
    _defaultValue = value.toInt();
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

  /// Specifies whether this style should be locked.
  StyleBuilder locked(bool locked) {
    _locked = locked;
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
  StyleBuilder fontSize(num size, [num? eastAsiaSize]) {
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
  StyleBuilder runColor(Color color) {
    assert(color.rgbValue != null, 'run color must have a valid RGB value');
    _color = color;
    return this;
  }

  /// Sets the highlight color for the text in the style.
  ///
  /// [hexColor] is the hexadecimal color code.
  StyleBuilder highlight(Color color) {
    assert(
        color.rgbValue != null, 'highlight color must have a valid RGB value');
    _highlightColor = color;
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

  /// Applies strikethrough formatting to the text.
  ///
  /// Disable double strikethrough if active
  StyleBuilder strikethrough() {
    isStrike = true;
    isDoubleStrike = false;
    return this;
  }

  /// Applies double strikethrough formatting to the text.
  ///
  /// Disable strikethrough if active
  StyleBuilder doubleStrike() {
    isStrike = false;
    isDoubleStrike = true;
    return this;
  }

  /// Applies underline formatting to the text.
  StyleBuilder underline() {
    isUnderline = true;
    return this;
  }

  /// Applies all caps formatting to the text.
  StyleBuilder caps() {
    _isCaps = true;
    _isSmallCaps = false;
    return this;
  }

  /// Applies small caps formatting to the text.
  StyleBuilder smallCaps() {
    _isSmallCaps = true;
    _isCaps = false;
    return this;
  }

  /// Sets the vertical alignment of the text (subscript or superscript).
  ///
  /// [align] specifies the vertical alignment (e.g., [Script.subscript]).
  StyleBuilder __verticalAlign(Script align) {
    _verticalAlign = align;
    return this;
  }

  StyleBuilder subscript() => __verticalAlign(Script.subscript);

  StyleBuilder superscript() => __verticalAlign(Script.superscript);

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
  /// [before] is spacing before the paragraph in twips.
  /// [after] is spacing after the paragraph in twips.
  /// [line] is the line spacing of the element in twips.
  /// This setting is applicable only to paragraph styles.
  StyleBuilder spacing({
    int? before,
    int? after,
    int? line,
    LineRule rule = LineRule.auto,
  }) {
    if (before != null) _spacingBefore = before;
    if (after != null) _spacingAfter = after;
    if (line != null) _lineSpacing = line;
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
  /// [right] is the right indentation for the paragraph in twips.
  /// [hanging] is the hanging indentation for the paragraph in twips.
  /// This setting is applicable only to paragraph styles.
  StyleBuilder indent({
    int? firstLine,
    int? left,
    int? right,
    int? start,
    int? end,
    int? hanging,
  }) {
    if (firstLine != null) _firstLineIndent = firstLine;
    if (left != null) _leftIndent = left;
    if (right != null) _rightIndent = right;
    if (start != null) _startIndent = start;
    if (end != null) _endIndent = end;
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

  /// Forces a page break before the paragraph.
  ///
  /// This setting is applicable only to paragraph styles.
  StyleBuilder pageBreakBefore() {
    _pageBreakBefore = true;
    return this;
  }

  /// Applies shading to the paragraph.
  ///
  /// [color] is the hexadecimal color code for the background (e.g., 'FF0000').
  /// [pattern] is the shading pattern (e.g., [ShadingPattern.solid]).
  /// This setting is applicable only to paragraph styles.
  StyleBuilder paragraphShading({String? color, ShadingPattern? pattern}) {
    if (type == Style.paragraphType) {
      return this;
    }
    if (color != null) _shadingColor = color;
    if (pattern != null) _shadingPattern = pattern;
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
      _borders['top'] = <String, String>{
        'w:val': top.value,
        'w:sz': (topSize ?? 4).toString(), // Default 0.5pt
        'w:color': topColor ?? 'auto',
      };
    }
    if (bottom != null) {
      _borders['bottom'] = <String, String>{
        'w:val': bottom.value,
        'w:sz': (bottomSize ?? 4).toString(),
        'w:color': bottomColor ?? 'auto',
      };
    }
    if (left != null) {
      _borders['left'] = <String, String>{
        'w:val': left.value,
        'w:sz': (leftSize ?? 4).toString(),
        'w:color': leftColor ?? 'auto',
      };
    }
    if (right != null) {
      _borders['right'] = <String, String>{
        'w:val': right.value,
        'w:sz': (rightSize ?? 4).toString(),
        'w:color': rightColor ?? 'auto',
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

    if (_configurators.isNotEmpty) {
      configurators.addAll(_configurators);
    }

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

    if (_qFormat) {
      configurators.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'qFormat',
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

    if (type != Style.characterType) {
      final List<StyleConfigurator> paragraphConfigs = <StyleConfigurator>[];

      if (_spacingBefore != null ||
          _spacingAfter != null ||
          _lineSpacing != null) {
        final Map<String, dynamic> spacingConfigs = <String, dynamic>{
          'w:before': 0,
          'w:after': 0,
        };

        if (_spacingBefore != null) {
          spacingConfigs['w:before'] = _spacingBefore.toString();
        }

        if (_spacingAfter != null) {
          spacingConfigs['w:after'] = _spacingAfter.toString();
        }

        if (_lineSpacing != null) {
          spacingConfigs['w:line'] = _lineSpacing.toString();
          spacingConfigs['w:lineRule'] = _lineRule!.name.toString();
        }

        if (spacingConfigs.isNotEmpty) {
          paragraphConfigs.add(
            StyleConfigurator.noSelfClosing(
              prefix: 'w',
              propertyName: 'spacing',
              attributes: spacingConfigs,
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

      if (_widowControl) {
        paragraphConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'widowControl',
            value: true,
          ),
        );
      }

      if (_contextualSpacing) {
        paragraphConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'contextualSpacing',
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
          _rightIndent != null ||
          _hangingIndent != null) {
        final Map<String, dynamic> indentConfigs = <String, dynamic>{};

        if (_leftIndent != null) {
          indentConfigs['w:left'] = _leftIndent.toString();
        }

        if (_rightIndent != null) {
          indentConfigs['w:right'] = _rightIndent.toString();
        }

        if (_firstLineIndent != null) {
          indentConfigs['w:firstLine'] = _firstLineIndent.toString();
        }

        if (_hangingIndent != null) {
          indentConfigs['w:hanging'] = _hangingIndent.toString();
        }

        if (_startIndent != null) {
          indentConfigs['w:start'] = _startIndent.toString();
        }

        if (_endIndent != null) {
          indentConfigs['w:end'] = _endIndent.toString();
        }

        if (indentConfigs.isNotEmpty) {
          paragraphConfigs.add(
            StyleConfigurator.noSelfClosing(
              prefix: 'w',
              propertyName: 'ind',
              attributes: indentConfigs,
            ),
          );
        }
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

      if (_pageBreakBefore) {
        paragraphConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'pageBreakBefore',
          ),
        );
      }

      if (_shadingColor != null || _shadingPattern != null) {
        final Map<String, dynamic> attributes = <String, dynamic>{};
        if (_shadingColor != null) {
          attributes['w:fill'] = _shadingColor;
          attributes['w:color'] = _shadingColor;
        }
        if (_shadingPattern != null) {
          attributes['w:val'] = _shadingPattern!.value;
        }
        paragraphConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'shd',
            attributes: attributes,
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
            propertyName: 'pBdr',
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
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'sz',
          value: _fontSize!.toInt().toString(),
        ),
      );
    }
    if (_fontEastAsiaSize != null) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'szCs',
          value: _fontEastAsiaSize!.toInt().toString(),
        ),
      );
    }

    if (_color != null) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'color',
          value: _color!.toColorValue()!.toUpperCase(),
        ),
      );
    }

    if (_highlightColor != null) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'highlight',
          value: _highlightColor!.toColorValue()!.toUpperCase(),
        ),
      );
    }

    if (isStrike) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'strike',
        ),
      );
    }

    if (isDoubleStrike) {
      assert(
        !isStrike,
        'strike should not be true '
        'when double strike is also active',
      );
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'dstrike',
          value: true,
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

    if (_isCaps) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'caps',
        ),
      );
    }

    if (_isSmallCaps) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'smallCaps',
        ),
      );
    }

    if (_verticalAlign != null) {
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'vertAlign',
          value: _verticalAlign!.name,
        ),
      );
    }

    if (_language != null) {
      textConfigs.addAll(
        <StyleConfigurator>[
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'lang',
            attributes: <String, dynamic>{'w:val': _language!.language},
          ),
          if (_language!.eastAsia.isNotEmpty)
            StyleConfigurator.selfClosing(
              prefix: 'w',
              propertyName: 'eastAsia',
              attributes: <String, dynamic>{'w:val': _language!.eastAsia},
            ),
          if (_language!.bidi.isNotEmpty)
            StyleConfigurator.selfClosing(
              prefix: 'w',
              propertyName: 'bidi',
              attributes: <String, dynamic>{'w:val': _language!.bidi},
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

    if (_locked) {
      configurators.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'locked',
        ),
      );
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
