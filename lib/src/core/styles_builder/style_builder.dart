import '../../../docx.dart';
import '../extensions/num_extensions.dart';

/// A builder class for creating and configuring [Style] objects.
///
/// This class provides a fluent API to define various paragraph and character
/// style properties such as font, size, color, alignment, spacing, and borders.
///
/// ## Quick Examples
///
/// ### Create a Paragraph Style
/// ```dart
/// final style = StyleBuilder.paragraph('CustomHeading')
///   .name('Custom Heading')
///   .fontSize(24)
///   .bold()
///   .fontFamily('Georgia')
///   .runColor(Color(0xFF000080))
///   .build();
/// ```
///
/// ### Create a Character Style
/// ```dart
/// final codeStyle = StyleBuilder.character('CodeText')
///   .name('Code')
///   .fontFamily('Courier New')
///   .fontSize(10)
///   .build();
/// ```
///
/// ### Inline Style (singular - not saved to styles.xml)
/// ```dart
/// // For direct paragraph formatting
/// final inlineStyle = StyleBuilder.singularP()
///   .bold()
///   .fontSize(16)
///   .build();
///
/// // For direct character formatting
/// final charStyle = StyleBuilder.singularC()
///   .italic()
///   .underline()
///   .build();
/// ```
///
/// ### Paragraph with Borders and Spacing
/// ```dart
/// final borderedStyle = StyleBuilder.paragraph('Quote')
///   .name('Quote Style')
///   .indent(left: 720, right: 720)
///   .spacing(before: 240, after: 240)
///   .borders(
///     left: BorderStyle.single,
///     leftSize: 12,
///     leftColor: '808080',
///   )
///   .build();
/// ```
///
/// ## Style Types
///
/// | Factory | Purpose | Example |
/// |---------|---------|---------|
/// | `paragraph()` | Document paragraph styles | Headings, Body Text |
/// | `character()` | Inline character styles | Links, Code |
/// | `list()` | List numbering styles | Bullet/Number lists |
/// | `numbering()` | Numbering definitions | List configurations |
///
/// ## Singular Styles
///
/// Use `singular*` factories when you don't want to save the style
/// to the document's styles.xml but still need style properties:
/// - `singularP()` - Single-use paragraph style
/// - `singularC()` - Single-use character style
/// - `singularL()` - Single-use list style
/// - `singularN()` - Single-use numbering style
class StyleBuilder {
  /// Internal constructor for [StyleBuilder].
  ///
  /// [id] is the unique identifier for the style (w:styleId).
  /// [type] specifies if it's a 'paragraph' or 'character' style.
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

  /// Creates a [StyleBuilder] for a **Paragraph** style
  /// that it's only used for certain cases and will not be reused by
  /// other elements in the document
  factory StyleBuilder.up() {
    return StyleBuilder._(nanoid(5), Style.paragraphType);
  }

  /// Creates a [StyleBuilder] for a **Character** style
  /// that it's only used for certain cases and will not be reused by
  /// other elements in the document
  factory StyleBuilder.uc() {
    return StyleBuilder._(nanoid(5), Style.characterType);
  }

  /// Creates a [StyleBuilder] for a **List** style
  /// that it's only used for certain cases and will not be reused by
  /// other elements in the document
  factory StyleBuilder.ul() {
    return StyleBuilder._(nanoid(5), Style.listType);
  }

  /// Creates a [StyleBuilder] for a **Numbering** style
  /// that it's only used for certain cases and will not be reused by
  /// other elements in the document
  factory StyleBuilder.un() {
    return StyleBuilder._(nanoid(5), Style.numberingType);
  }

  factory StyleBuilder.arial([String? id]) {
    return StyleBuilder._(id ?? nanoid(5), Style.paragraphType)
        .fontFamily('Arial')
        .qFormat(false)
        .keepNext(true);
  }

  factory StyleBuilder.priority(
      [String? id, int priority = 20, String type = Style.paragraphType]) {
    return StyleBuilder._(id ?? nanoid(5), type).uiPriority(priority);
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

  /// Adds custom [StyleConfigurator] objects to the style.
  ///
  /// Use this method to add low-level XML configurations that aren't
  /// covered by the fluent API methods.
  ///
  /// Example:
  /// ```dart
  /// StyleBuilder.paragraph('Custom')
  ///   .withConfigurators([
  ///     StyleConfigurator.selfClosing(
  ///       prefix: 'w',
  ///       propertyName: 'divId',
  ///       value: '123',
  ///     ),
  ///   ])
  ///   .build();
  /// ```
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

  /// Sets contextual spacing for the paragraph style.
  ///
  /// When true, spacing between paragraphs using this style will ignore
  /// the spacing from the previous paragraph's style.
  ///
  /// Useful for styles like List Paragraph where you don't want double spacing.
  ///
  /// Example:
  /// ```dart
  /// // Without contextualSpacing: extra space between list items
  /// // With contextualSpacing: consistent space between list items
  /// StyleBuilder.paragraph('ListItem')
  ///   .contextualSpacing(true)
  ///   .build();
  /// ```
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

  /// Applies subscript formatting to the text.
  ///
  /// Subscript positions text below the baseline, useful for
  /// chemical formulas (H₂O) or mathematical notations.
  ///
  /// Example:
  /// ```dart
  /// StyleBuilder.character('subscript')
  ///   .subscript()
  ///   .build();
  /// ```
  StyleBuilder subscript() => __verticalAlign(Script.subscript);

  /// Applies superscript formatting to the text.
  ///
  /// Superscript positions text above the baseline, useful for
  /// exponents (x²) or ordinal numbers (1st, 2nd).
  ///
  /// Example:
  /// ```dart
  /// StyleBuilder.character('superscript')
  ///   .superscript()
  ///   .build();
  /// ```
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
  StyleBuilder shading({Color? color, ShadingPattern? pattern}) {
    if (type == Style.paragraphType) {
      return this;
    }
    if (color != null) _shadingColor = color.toColorValue()!.toUpperCase();
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

  static Style get normal => StyleBuilder.paragraph('Normal')
      .name('Normal')
      .fontSize(12.ptToHalfPoints())
      .alignment(Alignment.left)
      .spacing(before: 0, after: 160)
      .lang(DocxLanguage(language: LanguageCodes.englishUS))
      .qFormat(true)
      .build();

  static Style get listParagraph => StyleBuilder.paragraph('ListParagraph')
      .name('List Paragraph')
      .basedOn('Normal')
      .keepNext(true)
      .keepLines(true)
      .activateWindowControl()
      .contextualSpacing(true)
      .qFormat(true)
      .build();

  static Style get defaultParagraphFont =>
      StyleBuilder.character('DefaultParagraphFont')
          .name('Default Paragraph Font')
          .defaultValue(true)
          .build();

  static Style get hyperlink => StyleBuilder.character('Hyperlink')
      .name('Hyperlink')
      .runColor(Color(0x0563C1))
      .underline()
      .build();

  static Style get heading1 => StyleBuilder.paragraph('Heading1')
      .name('Heading 1')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(24.ptToHalfPoints())
      .bold()
      .spacing(before: 480)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(0)
      .uiPriority(9)
      .qFormat(true)
      .build();

  static Style get heading2 => StyleBuilder.paragraph('Heading2')
      .name('Heading 2')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(18.ptToHalfPoints())
      .bold()
      .spacing(before: 360, after: 80)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(1)
      .uiPriority(9)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading3 => StyleBuilder.paragraph('Heading3')
      .name('Heading 3')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(14.ptToHalfPoints())
      .bold()
      .spacing(before: 280, after: 80)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(2)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading4 => StyleBuilder.paragraph('Heading4')
      .name('Heading 4')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(12.ptToHalfPoints())
      .bold()
      .spacing(before: 240, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(3)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading5 => StyleBuilder.paragraph('Heading5')
      .name('Heading 5')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(12.ptToHalfPoints())
      .bold()
      .spacing(before: 220, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(4)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading6 => StyleBuilder.paragraph('Heading6')
      .name('Heading 6')
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(10.ptToHalfPoints())
      .bold()
      .spacing(before: 200, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(5)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static List<Style> get standardDocumentStyles => <Style>[
        normal,
        listParagraph,
        defaultParagraphFont,
        ...TableStyleBuilder.standardTableStyles,
        hyperlink,
        heading1,
        heading2,
        heading3,
        heading4,
        heading5,
        heading6,
      ];

  static List<Style> styles({
    bool shouldNormal = true,
    bool shouldListParagraph = true,
    bool shouldDefaultParagraphFont = true,
    bool shouldHyperlink = true,
    bool shouldHeading1 = true,
    bool shouldHeading2 = true,
    bool shouldHeading3 = true,
    bool shouldHeading4 = true,
    bool shouldHeading5 = true,
    bool shouldHeading6 = true,
    bool shouldTables = true,
  }) =>
      <Style>[
        if (shouldNormal) normal,
        if (shouldListParagraph) listParagraph,
        if (shouldDefaultParagraphFont) defaultParagraphFont,
        if (shouldTables) ...TableStyleBuilder.standardTableStyles,
        if (shouldHyperlink) hyperlink,
        if (shouldHeading1) heading1,
        if (shouldHeading2) heading2,
        if (shouldHeading3) heading3,
        if (shouldHeading4) heading4,
        if (shouldHeading5) heading5,
        if (shouldHeading6) heading6,
      ];

  //TODO: implement this or remove it
  // as far as i know, this directly
  // it's not needed
  static List<dynamic> latentStyles() {
    return [];
  }
}
