import '../../../docx.dart';
import '../extensions/num_extensions.dart';

/// A builder class for creating and configuring table [Style] objects.
///
/// This class provides a fluent API to define table styles including
/// table properties, row properties, cell properties, paragraph properties,
/// character properties, and conditional formatting for table parts.
class TableStyleBuilder {
  /// Internal constructor for [TableStyleBuilder].
  TableStyleBuilder._(this.id);

  /// Creates a [TableStyleBuilder] for a table style.
  ///
  /// [id] is the internal ID for the style.
  factory TableStyleBuilder.table(String id) {
    return TableStyleBuilder._(id);
  }

  /// Creates a [TableStyleBuilder] for a table style
  /// that is not in DocumentStylesSheet
  factory TableStyleBuilder.singularTable() {
    return TableStyleBuilder._(nanoid(5));
  }

  /// The internal identifier of the style, used in `w:styleId`.
  final String id;

  /// The display name of the style, used in `w:name`.
  String? _name;

  /// The type of the style, always 'table' for table styles.
  final String type = Style.tableType;

  final List<StyleConfigurator> _configurators = <StyleConfigurator>[];

  // Basic style properties
  //
  // first metadata that must
  // be in this order
  String? _basedOn;
  String? _next;
  bool _qFormat = false;
  int? _uiPriority;
  // at the last part, visibility
  // are setted
  bool _semiHidden = false;
  bool _unhideWhenUsed = false;
  Object? _defaultValue;

  // ========== (w:tblPr) ==========
  // Table-level properties
  Alignment? _tableAlignment;
  int? _tableWidth;
  // 'dxa', 'pct', 'auto', 'nil'
  String? _tableWidthType;
  int? _tableIndent;
  String? _tableIndentType;
  String? _tblStyleRowBandSize;
  String? _tblStyleColBandSize;
  // 'never', 'overlap'
  String? _tblOverlap;

  // Table borders (w:tblBorders)
  final Map<String, Map<String, String>> _tableBorders =
      <String, Map<String, String>>{};

  // Table shading (w:shd)
  Color? _tableShadingColor;
  ShadingPattern? _tableShadingPattern;

  // Table layout (w:tblLayout)
  // if true then will be 'autofit'
  // if false then will be 'fixed'
  bool? _tableAutoLayout;

  // Table cell margins (w:tblCellMar)
  final Map<String, Map<String, dynamic>> _cellMargins =
      <String, Map<String, dynamic>>{};

  // Table cell spacing (w:tblCellSpacing)
  int? _cellSpacing;
  String? _cellSpacingType;

  // ========== (w:trPr) ==========
  bool? _cantSplit; // w:cantSplit
  bool? _hidden; // w:hidden
  int? _rowHeight;
  String? _rowHeightRule; // 'auto', 'exact', 'atLeast'

  // ========== (w:tcPr) ==========
  Alignment? _cellVerticalAlignment;
  int? _cellWidth;
  String? _cellWidthType;
  String? _gridSpan;
  String? _vMerge; // 'restart', 'continue'
  String? _hMerge; // 'restart', 'continue'
  bool? _noWrap; // w:noWrap
  int? _tcFitText; // w:tcFitText

  // These apply to paragraphs within table cells
  bool _widowControl = false;
  Alignment? _paragraphAlignment;
  int? _spacingBefore;
  int? _spacingAfter;
  LineRule? _lineRule;
  int? _lineSpacing;
  int? _firstLineIndent;
  int? _leftIndent;
  int? _rightIndent;
  int? _hangingIndent;
  int? _startIndent;
  int? _endIndent;
  bool _keepNext = false;
  bool _keepLines = false;
  int? _outlineLevel;
  bool _pageBreakBefore = false;
  String? _paragraphShadingColor;
  ShadingPattern? _paragraphShadingPattern;

  // Paragraph borders (applies to paragraphs within cells)
  final Map<String, Map<String, String>> _paragraphBorders =
      <String, Map<String, String>>{};

  // ========== (w:rPr) ==========
  // These apply to text within table cells
  num? _fontSize;
  num? _fontEastAsiaSize;
  String? _fontFamily;
  String? _color;
  String? _highlightColor;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderline = false;
  bool _isStrike = false;
  bool _isDoubleStrike = false;
  bool _isCaps = false;
  bool _isSmallCaps = false;
  Script? _verticalAlign;
  DocxLanguage? _language;

  final List<ConditionalTableStyle> _conditionalStyles =
      <ConditionalTableStyle>[];

  /// Specifies the ID of the style on which this style is based.
  ///
  /// [styleId] is the `w:styleId` of the base style.
  TableStyleBuilder basedOn(String styleId) {
    _basedOn = styleId;
    return this;
  }

  TableStyleBuilder withConfigurators(Iterable<StyleConfigurator> configs) {
    _configurators.addAll(configs);
    return this;
  }

  /// Sets the display name for the style.
  TableStyleBuilder name(String styleName) {
    _name = styleName;
    return this;
  }

  TableStyleBuilder next(String styleId) {
    _next = styleId;
    return this;
  }

  TableStyleBuilder defaultValue(bool value) {
    _defaultValue = value.toInt();
    return this;
  }

  TableStyleBuilder uiPriority(int priority) {
    _uiPriority = priority;
    return this;
  }

  TableStyleBuilder qFormat(bool enabled) {
    _qFormat = enabled;
    return this;
  }

  TableStyleBuilder semiHidden(bool hidden) {
    _semiHidden = hidden;
    return this;
  }

  TableStyleBuilder unhideWhenUsed(bool unhide) {
    _unhideWhenUsed = unhide;
    return this;
  }

  TableStyleBuilder tableAlignment(Alignment align) {
    _tableAlignment = align;
    return this;
  }

  TableStyleBuilder tableWidth(int width, [String type = 'dxa']) {
    assert(
      <String>['dxa', 'pct', 'auto', 'nil'].contains(type),
      'type "$type" is '
      'not accepted for the width. You can only '
      'set: dxa, pct, auto, or nil types',
    );
    _tableWidth = width;
    _tableWidthType = type;
    return this;
  }

  TableStyleBuilder tableIndent(int indent, [String type = 'dxa']) {
    assert(
      <String>['dxa', 'pct', 'auto', 'nil'].contains(type),
      'type "$type" is '
      'not accepted for the indent. You can only '
      'set: dxa, pct, auto, or nil types',
    );
    _tableIndent = indent;
    _tableIndentType = type;
    return this;
  }

  TableStyleBuilder rowBandSize(String size) {
    _tblStyleRowBandSize = size;
    return this;
  }

  TableStyleBuilder colBandSize(String size) {
    _tblStyleColBandSize = size;
    return this;
  }

  TableStyleBuilder overlap(String overlap) {
    _tblOverlap = overlap;
    return this;
  }

  TableStyleBuilder tableBorders({
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
    BorderStyle? insideH,
    int? insideHSize,
    String? insideHColor,
    BorderStyle? insideV,
    int? insideVSize,
    String? insideVColor,
  }) {
    if (top != null) {
      _tableBorders['top'] = <String, String>{
        'w:val': top.value,
        'w:sz': (topSize ?? 4).toString(),
        'w:color': topColor ?? 'auto',
      };
    }
    if (bottom != null) {
      _tableBorders['bottom'] = <String, String>{
        'w:val': bottom.value,
        'w:sz': (bottomSize ?? 4).toString(),
        'w:color': bottomColor ?? 'auto',
      };
    }
    if (left != null) {
      _tableBorders['left'] = <String, String>{
        'w:val': left.value,
        'w:sz': (leftSize ?? 4).toString(),
        'w:color': leftColor ?? 'auto',
      };
    }
    if (right != null) {
      _tableBorders['right'] = <String, String>{
        'w:val': right.value,
        'w:sz': (rightSize ?? 4).toString(),
        'w:color': rightColor ?? 'auto',
      };
    }
    if (insideH != null) {
      _tableBorders['insideH'] = <String, String>{
        'w:val': insideH.value,
        'w:sz': (insideHSize ?? 4).toString(),
        'w:color': insideHColor ?? 'auto',
      };
    }
    if (insideV != null) {
      _tableBorders['insideV'] = <String, String>{
        'w:val': insideV.value,
        'w:sz': (insideVSize ?? 4).toString(),
        'w:color': insideVColor ?? 'auto',
      };
    }
    return this;
  }

  TableStyleBuilder tableShading({
    required Color color,
    ShadingPattern pattern = ShadingPattern.clear,
  }) {
    _tableShadingColor = color;
    _tableShadingPattern = pattern;
    return this;
  }

  TableStyleBuilder tableLayout(bool auto) {
    _tableAutoLayout = auto;
    return this;
  }

  TableStyleBuilder cellMargins({
    int? top,
    String? topType,
    int? bottom,
    String? bottomType,
    int? left,
    String? leftType,
    int? right,
    String? rightType,
  }) {
    if (top != null) {
      _cellMargins['top'] = <String, dynamic>{
        'w:w': top.toString(),
        'w:type': topType ?? 'dxa',
      };
    }
    if (bottom != null) {
      _cellMargins['bottom'] = <String, dynamic>{
        'w:w': bottom.toString(),
        'w:type': bottomType ?? 'dxa',
      };
    }
    if (left != null) {
      _cellMargins['left'] = <String, dynamic>{
        'w:w': left.toString(),
        'w:type': leftType ?? 'dxa',
      };
    }
    if (right != null) {
      _cellMargins['right'] = <String, dynamic>{
        'w:w': right.toString(),
        'w:type': rightType ?? 'dxa',
      };
    }
    return this;
  }

  TableStyleBuilder cellSpacing(int spacing, [String type = 'dxa']) {
    _cellSpacing = spacing;
    _cellSpacingType = type;
    return this;
  }

  TableStyleBuilder rowProperties({
    bool? cantSplit,
    bool? hidden,
    int? height,
    TableHeightRule? heightRule,
  }) {
    if (cantSplit != null) _cantSplit = cantSplit;
    if (hidden != null) _hidden = hidden;
    if (height != null) _rowHeight = height;
    if (heightRule != null) _rowHeightRule = heightRule.name;
    return this;
  }

  TableStyleBuilder cellVerticalAlignment(Alignment align) {
    _cellVerticalAlignment = align;
    return this;
  }

  TableStyleBuilder cellWidth(int width, [String type = 'dxa']) {
    _cellWidth = width;
    _cellWidthType = type;
    return this;
  }

  TableStyleBuilder gridSpan(String span) {
    _gridSpan = span;
    return this;
  }

  TableStyleBuilder vMerge(String merge) {
    _vMerge = merge;
    return this;
  }

  TableStyleBuilder hMerge(String merge) {
    _hMerge = merge;
    return this;
  }

  TableStyleBuilder noWrap(bool noWrap) {
    _noWrap = noWrap;
    return this;
  }

  TableStyleBuilder fitText(int fitText) {
    _tcFitText = fitText;
    return this;
  }

  TableStyleBuilder activateWidowControl() {
    _widowControl = true;
    return this;
  }

  TableStyleBuilder paragraphAlignment(Alignment align) {
    _paragraphAlignment = align;
    return this;
  }

  TableStyleBuilder spacing({
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

  TableStyleBuilder lineSpacing(int value) {
    _lineSpacing = value;
    return this;
  }

  TableStyleBuilder indent({
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

  TableStyleBuilder keepNext(bool keep) {
    _keepNext = keep;
    return this;
  }

  TableStyleBuilder keepLines(bool keep) {
    _keepLines = keep;
    return this;
  }

  TableStyleBuilder outlineLevel(int level) {
    _outlineLevel = level;
    return this;
  }

  TableStyleBuilder pageBreakBefore() {
    _pageBreakBefore = true;
    return this;
  }

  TableStyleBuilder paragraphShading({String? color, ShadingPattern? pattern}) {
    if (color != null) _paragraphShadingColor = color;
    if (pattern != null) _paragraphShadingPattern = pattern;
    return this;
  }

  TableStyleBuilder paragraphBorders({
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
    if (top != null) {
      _paragraphBorders['top'] = <String, String>{
        'w:val': top.value,
        'w:sz': (topSize ?? 4).toString(),
        'w:color': topColor ?? 'auto',
      };
    }
    if (bottom != null) {
      _paragraphBorders['bottom'] = <String, String>{
        'w:val': bottom.value,
        'w:sz': (bottomSize ?? 4).toString(),
        'color': bottomColor ?? 'auto',
      };
    }
    if (left != null) {
      _paragraphBorders[''] = <String, String>{
        'w:val': left.value,
        'w:sz': (leftSize ?? 4).toString(),
        'w:color': leftColor ?? 'auto',
      };
    }
    if (right != null) {
      _paragraphBorders['right'] = <String, String>{
        'w:val': right.value,
        'w:sz': (rightSize ?? 4).toString(),
        'w:color': rightColor ?? 'auto',
      };
    }
    return this;
  }

  // ========== CHARACTER PROPERTIES METHODS ==========
  TableStyleBuilder fontSize(num size, [num? eastAsiaSize]) {
    _fontSize = size;
    _fontEastAsiaSize = eastAsiaSize ?? size;
    return this;
  }

  TableStyleBuilder fontFamily(String family) {
    _fontFamily = family;
    return this;
  }

  TableStyleBuilder runColor(Color color) {
    assert(color.rgbValue != null, 'run color must have a valid RGB value');
    _color = color.toColorValue()?.toUpperCase();
    return this;
  }

  TableStyleBuilder highlight(Color color) {
    assert(
        color.rgbValue != null, 'highlight color must have a valid RGB value');
    _highlightColor = color.toColorValue()?.toUpperCase();
    return this;
  }

  TableStyleBuilder bold() {
    _isBold = true;
    return this;
  }

  TableStyleBuilder italic() {
    _isItalic = true;
    return this;
  }

  TableStyleBuilder strikethrough() {
    _isStrike = true;
    _isDoubleStrike = false;
    return this;
  }

  TableStyleBuilder doubleStrike() {
    _isStrike = false;
    _isDoubleStrike = true;
    return this;
  }

  TableStyleBuilder underline() {
    _isUnderline = true;
    return this;
  }

  TableStyleBuilder caps() {
    _isCaps = true;
    _isSmallCaps = false;
    return this;
  }

  TableStyleBuilder smallCaps() {
    _isSmallCaps = true;
    _isCaps = false;
    return this;
  }

  TableStyleBuilder verticalAlign(Script align) {
    _verticalAlign = align;
    return this;
  }

  TableStyleBuilder subscript() => verticalAlign(Script.subscript);
  TableStyleBuilder superscript() => verticalAlign(Script.superscript);

  TableStyleBuilder lang(DocxLanguage language) {
    _language = language;
    return this;
  }

  TableStyleBuilder addConditionalStyle(
    ConditionalTableStyle conditionalStyle,
  ) {
    _conditionalStyles.add(conditionalStyle);
    return this;
  }

  /// Builds and returns the final [Style] object for the table style.
  Style build() {
    final List<StyleConfigurator> configurators = <StyleConfigurator>[
      ..._configurators
    ];


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

    final List<StyleConfigurator> tblPrConfigs = <StyleConfigurator>[];

    if (_tableAlignment != null) {
      if (_tableWidth != null && _tableWidthType != null) {
        tblPrConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'tblW',
            attributes: <String, dynamic>{
              'w:w': _tableWidth.toString(),
              'w:type': _tableWidthType,
            },
          ),
        );
      }
      tblPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'jc',
          value: _tableAlignment!.name,
        ),
      );
    }

    if (_tableIndent != null && _tableIndentType != null) {
      tblPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'tblInd',
          attributes: <String, dynamic>{
            'w:w': _tableIndent.toString(),
            'w:type': _tableIndentType,
          },
        ),
      );
    }

    if (_tblStyleRowBandSize != null) {
      tblPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'tblStyleRowBandSize',
          value: _tblStyleRowBandSize!,
        ),
      );
    }

    if (_tblStyleColBandSize != null) {
      tblPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'tblStyleColBandSize',
          value: _tblStyleColBandSize!,
        ),
      );
    }

    if (_tblOverlap != null) {
      tblPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'tblOverlap',
          value: _tblOverlap!,
        ),
      );
    }

    if (_tableBorders.isNotEmpty) {
      final List<StyleConfigurator> borderConfigs = <StyleConfigurator>[];
      _tableBorders.forEach((String key, Map<String, String> value) {
        borderConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: key,
            attributes: value,
          ),
        );
      });
      tblPrConfigs.add(
        StyleConfigurator.noSelfClosing(
          prefix: 'w',
          propertyName: 'tblBorders',
          configurators: borderConfigs,
        ),
      );
    }

    if (_tableShadingColor != null && _tableShadingPattern != null) {
      final Map<String, dynamic> shdAttributes = <String, dynamic>{};
      shdAttributes['w:fill'] = _tableShadingColor!.toColorValue()!;
      shdAttributes['w:val'] = _tableShadingPattern!.value;
      tblPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'shd',
          attributes: shdAttributes,
        ),
      );
    }

    // Table layout
    if (_tableAutoLayout != null) {
      tblPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'tblLayout',
          attributes: <String, dynamic>{
            'w:type': _tableAutoLayout! ? 'autofit' : 'fixed',
          },
        ),
      );
    }

    if (_cellMargins.isNotEmpty) {
      final List<StyleConfigurator> cellMarginConfigs = <StyleConfigurator>[];
      _cellMargins.forEach((String key, Map<String, dynamic> value) {
        cellMarginConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: key,
            attributes: value,
          ),
        );
      });
      tblPrConfigs.add(
        StyleConfigurator.noSelfClosing(
          prefix: 'w',
          propertyName: 'tblCellMar',
          configurators: cellMarginConfigs,
        ),
      );
    }

    if (_cellSpacing != null && _cellSpacingType != null) {
      tblPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'tblCellSpacing',
          attributes: <String, dynamic>{
            'w:w': _cellSpacing.toString(),
            'w:type': _cellSpacingType,
          },
        ),
      );
    }

    if (tblPrConfigs.isNotEmpty) {
      configurators.add(
        StyleConfigurator.noSelfClosing(
          prefix: 'w',
          propertyName: 'tblPr',
          configurators: tblPrConfigs,
        ),
      );
    }

    final List<StyleConfigurator> trPrConfigs = <StyleConfigurator>[];

    if (_cantSplit != null) {
      trPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'cantSplit',
          value: _cantSplit.toString(),
        ),
      );
    }

    if (_hidden != null) {
      trPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'hidden',
          value: _hidden.toString(),
        ),
      );
    }

    if (_rowHeight != null && _rowHeightRule != null) {
      trPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'trHeight',
          attributes: <String, dynamic>{
            'w:val': _rowHeight.toString(),
            'w:hRule': _rowHeightRule,
          },
        ),
      );
    }

    if (trPrConfigs.isNotEmpty) {
      configurators.add(
        StyleConfigurator.noSelfClosing(
          prefix: 'w',
          propertyName: 'trPr',
          configurators: trPrConfigs,
        ),
      );
    }

    // ========== BUILD CELL PROPERTIES (w:tcPr) ==========
    final List<StyleConfigurator> tcPrConfigs = <StyleConfigurator>[];

    if (_cellVerticalAlignment != null) {
      tcPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'vAlign',
          value: _cellVerticalAlignment!.name,
        ),
      );
    }

    if (_cellWidth != null && _cellWidthType != null) {
      tcPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'tcW',
          attributes: <String, dynamic>{
            'w:w': _cellWidth.toString(),
            'w:type': _cellWidthType,
          },
        ),
      );
    }

    if (_gridSpan != null) {
      tcPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'gridSpan',
          value: _gridSpan!,
        ),
      );
    }

    if (_vMerge != null) {
      tcPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'vMerge',
          value: _vMerge!,
        ),
      );
    }

    if (_hMerge != null) {
      tcPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'hMerge',
          value: _hMerge!,
        ),
      );
    }

    if (_noWrap != null) {
      tcPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'noWrap',
          value: _noWrap.toString(),
        ),
      );
    }

    if (_tcFitText != null) {
      tcPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'tcFitText',
          value: _tcFitText.toString(),
        ),
      );
    }

    if (tcPrConfigs.isNotEmpty) {
      configurators.add(
        StyleConfigurator.noSelfClosing(
          prefix: 'w',
          propertyName: 'tcPr',
          configurators: tcPrConfigs,
        ),
      );
    }

    // ========== BUILD PARAGRAPH PROPERTIES (w:pPr) ==========
    final List<StyleConfigurator> pPrConfigs = <StyleConfigurator>[];

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
        pPrConfigs.add(
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'spacing',
            attributes: spacingConfigs,
          ),
        );
      }
    }

    if (_widowControl) {
      pPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'widowControl',
          value: true,
        ),
      );
    }

    if (_paragraphAlignment != null) {
      pPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'jc',
          value: _paragraphAlignment!.name,
        ),
      );
    }

    if (_firstLineIndent != null ||
        _leftIndent != null ||
        _rightIndent != null ||
        _hangingIndent != null ||
        _startIndent != null ||
        _endIndent != null) {
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
        pPrConfigs.add(
          StyleConfigurator.noSelfClosing(
            prefix: 'w',
            propertyName: 'ind',
            attributes: indentConfigs,
          ),
        );
      }
    }

    if (_keepNext) {
      pPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'keepNext',
        ),
      );
    }

    if (_keepLines) {
      pPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'keepLines',
        ),
      );
    }

    if (_outlineLevel != null) {
      pPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'outlineLvl',
          value: _outlineLevel.toString(),
        ),
      );
    }

    if (_pageBreakBefore) {
      pPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'pageBreakBefore',
        ),
      );
    }

    if (_paragraphShadingColor != null || _paragraphShadingPattern != null) {
      final Map<String, dynamic> attributes = <String, dynamic>{};
      if (_paragraphShadingColor != null) {
        attributes['w:fill'] = _paragraphShadingColor;
        attributes['w:color'] = _paragraphShadingColor;
      }
      if (_paragraphShadingPattern != null) {
        attributes['w:val'] = _paragraphShadingPattern!.value;
      }
      pPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'shd',
          attributes: attributes,
        ),
      );
    }

    // Paragraph borders
    if (_paragraphBorders.isNotEmpty) {
      final List<StyleConfigurator> borderConfigs = <StyleConfigurator>[];
      _paragraphBorders.forEach((String key, Map<String, String> value) {
        borderConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: key,
            attributes: value,
          ),
        );
      });
      pPrConfigs.add(
        StyleConfigurator.noSelfClosing(
          prefix: 'w',
          propertyName: 'pBdr',
          configurators: borderConfigs,
        ),
      );
    }

    // ========== BUILD CHARACTER PROPERTIES (w:rPr) ==========
    final List<StyleConfigurator> rPrConfigs = <StyleConfigurator>[];

    if (_fontFamily != null) {
      rPrConfigs.add(
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
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'sz',
          value: _fontSize!.toInt().toString(),
        ),
      );
    }
    if (_fontEastAsiaSize != null) {
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'szCs',
          value: _fontEastAsiaSize!.toInt().toString(),
        ),
      );
    }

    if (_color != null) {
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'color',
          value: _color,
        ),
      );
    }

    if (_highlightColor != null) {
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'highlight',
          value: _highlightColor,
        ),
      );
    }

    if (_isStrike) {
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'strike',
        ),
      );
    }

    if (_isDoubleStrike) {
      assert(
        !_isStrike,
        'strike should not be true when double strike is also active',
      );
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'dstrike',
          value: true,
        ),
      );
    }

    if (_isBold) {
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'b',
        ),
      );
    }

    if (_isItalic) {
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'i',
        ),
      );
    }

    if (_isUnderline) {
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'u',
          value: 'single',
        ),
      );
    }

    if (_isCaps) {
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'caps',
        ),
      );
    }

    if (_isSmallCaps) {
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'smallCaps',
        ),
      );
    }

    if (_verticalAlign != null) {
      rPrConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'vertAlign',
          value: _verticalAlign!.name,
        ),
      );
    }

    if (_language != null) {
      rPrConfigs.addAll(
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

    final List<StyleConfigurator> tcPr = <StyleConfigurator>[];
    if (pPrConfigs.isNotEmpty || rPrConfigs.isNotEmpty) {
      tcPr.add(
        StyleConfigurator.noSelfClosing(
          prefix: 'w',
          propertyName: 'pPr',
          configurators: <StyleConfigurator>[
            ...pPrConfigs,
            if (rPrConfigs.isNotEmpty)
              StyleConfigurator.noSelfClosing(
                prefix: 'w',
                propertyName: 'rPr',
                configurators: rPrConfigs,
              ),
          ],
        ),
      );
    }
    if (tcPr.isNotEmpty) {
      configurators.add(StyleConfigurator.noSelfClosing(
        prefix: 'w',
        propertyName: 'tcPr',
        configurators: tcPr,
      ));
    }

    // ========== (w:tblStylePr) ==========
    for (final ConditionalTableStyle condStyle in _conditionalStyles) {
      configurators.add(condStyle.toStyleConfigurator());
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

    return Style(
      type: type,
      styleId: id,
      defaultValue: _defaultValue,
      configurators: configurators,
      styleName: _name,
    );
  }
}

/// Represents a conditional table style for specific table parts.
class ConditionalTableStyle {
  ConditionalTableStyle(this.type, this.style);

  final String type;
  final TableStyleBuilder style;

  StyleConfigurator toStyleConfigurator() {
    final Style builtStyle = style.build();
    return StyleConfigurator.noSelfClosing(
      prefix: 'w',
      propertyName: 'tblStylePr',
      attributes: <String, dynamic>{'w:type': type},
      configurators: builtStyle.configurators,
    );
  }
}
