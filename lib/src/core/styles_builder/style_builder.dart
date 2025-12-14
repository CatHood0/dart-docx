import '../../../docx.dart';

class StyleBuilder {
  StyleBuilder._(this.id, this.type, [this._name = '']);

  factory StyleBuilder.paragraph(String id, {String? name}) {
    return StyleBuilder._(id, name ?? id, 'paragraph');
  }

  factory StyleBuilder.character(String id, {String? name}) {
    return StyleBuilder._(id, name ?? id, 'character');
  }

  final String id;
  String _name;
  final String type;

  String? _pageBreak;
  String? _basedOn;
  String? _next;
  bool _widowControl = false;
  bool? _defaultValue;
  int? _uiPriority;
  bool _qFormat = false;
  bool _semiHidden = false;
  bool _unhideWhenUsed = false;

  double? _fontSize;
  String? _fontFamily;
  String? _color;
  String? _highlightColor;
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  Alignment? _alignment;
  int? _spacingBefore;
  int? _spacingAfter;
  int? _lineSpacing;
  int? _firstLineIndent;
  int? _leftIndent;
  int? _hangingIndent;
  bool _keepNext = false;
  bool _keepLines = false;
  int? _outlineLevel;
  String? _language;

  StyleBuilder name(String styleName) {
    _name = styleName;
    return this;
  }

  String get getName => _name;

  StyleBuilder basedOn(String styleId) {
    _basedOn = styleId;
    return this;
  }

  StyleBuilder pageBreakAfter() {
    if (type == 'character') return this;
    _pageBreak = 'after';
    return this;
  }

  StyleBuilder pageBreakBefore() {
    if (type == 'character') return this;
    _pageBreak = 'before';
    return this;
  }

  /// Without widowControl (problem):
  /// text
  /// ┌─────────────────┐ ┌─────────────────┐
  /// │ PAGE 1          │ │ PAGE 2          │
  /// │ ...paragraph    │ │                 │
  /// │ text that       │ │ Chapter 1:      │ ← Orphan
  /// │ continues on    │ │ Introduction    │
  /// │ the next page   │ │ The complete    │
  /// │                 │ │ content here    │
  /// │ End of the      │ │                 │
  /// │ previous text.  │ │                 │
  /// │ Chapter 1:      │ │                 │
  /// └─────────────────┘ └─────────────────┘
  /// With widowControl (corrected):
  /// text
  /// ┌─────────────────┐ ┌─────────────────┐
  /// │ PAGE 1          │ │ PAGE 2          │
  /// │ ...paragraph    │ │ Chapter 1:      │
  /// │ text that       │ │ Introduction    │
  /// │ continues on    │ │ The complete    │
  /// │ the next page   │ │ content here    │
  /// │                 │ │                 │
  /// │ End of the      │ │                 │
  /// │ previous text.  │ │                 │
  /// └─────────────────┘ └─────────────────┘
  ///                  ↑
  ///        Moves "Chapter 1:" to page 2
  ///
  /// Useful when you're creating an writing app
  StyleBuilder activateWindowControl() {
    _widowControl = true;
    return this;
  }

  StyleBuilder next(String styleId) {
    _next = styleId;
    return this;
  }

  StyleBuilder defaultValue(bool isDefault) {
    _defaultValue = isDefault;
    return this;
  }

  StyleBuilder uiPriority(int priority) {
    _uiPriority = priority;
    return this;
  }

  StyleBuilder qFormat(bool enabled) {
    _qFormat = enabled;
    return this;
  }

  StyleBuilder semiHidden(bool hidden) {
    _semiHidden = hidden;
    return this;
  }

  StyleBuilder unhideWhenUsed(bool unhide) {
    _unhideWhenUsed = unhide;
    return this;
  }

  StyleBuilder fontSize(double size) {
    _fontSize = size;
    return this;
  }

  StyleBuilder fontFamily(String family) {
    _fontFamily = family;
    return this;
  }

  StyleBuilder color(String hexColor) {
    _color = hexColor;
    return this;
  }

  StyleBuilder highlight(String hexColor) {
    _highlightColor = hexColor;
    return this;
  }

  StyleBuilder bold() {
    isBold = true;
    return this;
  }

  StyleBuilder italic() {
    isItalic = true;
    return this;
  }

  StyleBuilder underline() {
    isUnderline = true;
    return this;
  }

  StyleBuilder alignment(Alignment align) {
    _alignment = align;
    return this;
  }

  StyleBuilder spacing({int? before, int? after}) {
    if (before != null) _spacingBefore = before;
    if (after != null) _spacingAfter = after;
    return this;
  }

  StyleBuilder lineSpacing(int value) {
    _lineSpacing = value;
    return this;
  }

  StyleBuilder indent({int? firstLine, int? left, int? hanging}) {
    if (firstLine != null) _firstLineIndent = firstLine;
    if (left != null) _leftIndent = left;
    if (hanging != null) _hangingIndent = hanging;
    return this;
  }

  StyleBuilder keepNext(bool keep) {
    _keepNext = keep;
    return this;
  }

  StyleBuilder keepLines(bool keep) {
    _keepLines = keep;
    return this;
  }

  StyleBuilder outlineLevel(int level) {
    _outlineLevel = level;
    return this;
  }

  StyleBuilder lang(String langCode) {
    _language = langCode;
    return this;
  }

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

    if (type == 'paragraph') {
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
                value: 'auto',
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

      if (_pageBreak != null) {
        switch (_pageBreak) {
          case 'before':
            paragraphConfigs.add(
              StyleConfigurator.selfClosing(
                prefix: 'w',
                propertyName: 'pageBreakBefore',
                value: null,
              ),
            );
            break;
          default:
            paragraphConfigs.add(
              StyleConfigurator.selfClosing(
                prefix: 'w',
                propertyName: 'pageBreakBefore',
                value: null,
              ),
            );
        }
      }

      if (_alignment != null) {
        paragraphConfigs.add(
          StyleConfigurator.selfClosing(
            prefix: 'w',
            propertyName: 'jc',
            value: _alignmentToValue(_alignment!),
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
          attributes: {
            'w:ascii': _fontFamily,
            'w:hAnsi': _fontFamily,
            'w:eastAsia': _fontFamily,
            'w:cs': _fontFamily,
          },
        ),
      );
    }

    if (_fontSize != null) {
      final halfPoints = (_fontSize! * 2).toInt();
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
            value: halfPoints.toString(),
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
      textConfigs.add(
        StyleConfigurator.selfClosing(
          prefix: 'w',
          propertyName: 'lang',
          attributes: {'w:val': _language},
        ),
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

    return Style(
      type: type,
      styleId: id,
      styleName: _name,
      defaultValue: _defaultValue,
      configurators: configurators,
    );
  }

  String _alignmentToValue(Alignment alignment) {
    switch (alignment) {
      case Alignment.left:
        return 'left';
      case Alignment.center:
        return 'center';
      case Alignment.right:
        return 'right';
      case Alignment.justify:
        return 'both';
    }
  }
}

enum Alignment { left, center, right, justify }
