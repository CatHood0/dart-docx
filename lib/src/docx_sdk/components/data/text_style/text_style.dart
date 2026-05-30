import '../../../../../docx.dart';

class TextStyle {
  TextStyle({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.smallCaps = false,
    this.caps = false,
    this.fontSize,
    this.fontFamily,
    this.fontColor,
    this.backgroundColor,
    this.spacingBefore,
    this.spacingAfter,
    this.lineSpacing,
    this.lineSpacingRule,
    this.indentLeft,
    this.indentRight,
    this.firstLineIndent,
    this.hangingIndent,
    this.headingLevel,
    this.borders,
    this.widowControl,
    this.keepNext,
    this.keepLines,
    this.outlineLevel,
    this.shadingColor,
    this.shadingPattern,
    this.textAlign = TextAlign.left,
  });

  // Text formatting properties (run properties)
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final bool smallCaps;
  final bool caps;

  // Font properties
  final UnitValue? fontSize;
  final String? fontFamily;
  final Color? fontColor;
  final Color? backgroundColor;

  // Spacing properties
  final UnitValue? spacingBefore;
  final UnitValue? spacingAfter;
  final UnitValue? lineSpacing;
  final LineRule? lineSpacingRule;

  // Indent properties
  final UnitValue? indentLeft;
  final UnitValue? indentRight;
  final UnitValue? firstLineIndent;
  final UnitValue? hangingIndent;
  // heading
  final int? headingLevel;

  // Border properties
  final Borders? borders;

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
  final WidowOrphanControl? widowControl;

  // Keep settings
  final bool? keepNext;
  final bool? keepLines;

  // Outline level
  final int? outlineLevel;

  // Shading
  final Color? shadingColor;
  final ShadingPattern? shadingPattern;
  final TextAlign textAlign;

  TextStyle copyWith({
    TextAlign? textAlign,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? strikethrough,
    bool? smallCaps,
    bool? caps,
    UnitValue? fontSize,
    String? fontFamily,
    Color? fontColor,
    Color? backgroundColor,
    UnitValue? spacingBefore,
    UnitValue? spacingAfter,
    UnitValue? lineSpacing,
    LineRule? lineSpacingRule,
    UnitValue? indentLeft,
    UnitValue? indentRight,
    UnitValue? firstLineIndent,
    UnitValue? hangingIndent,
    Borders? borders,
    WidowOrphanControl? widowControl,
    bool? keepNext,
    bool? keepLines,
    int? outlineLevel,
    Color? shadingColor,
    ShadingPattern? shadingPattern,
    int? headingLevel,
  }) {
    return TextStyle(
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      strikethrough: strikethrough ?? this.strikethrough,
      smallCaps: smallCaps ?? this.smallCaps,
      caps: caps ?? this.caps,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      fontColor: fontColor ?? this.fontColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      spacingBefore: spacingBefore ?? this.spacingBefore,
      spacingAfter: spacingAfter ?? this.spacingAfter,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      lineSpacingRule: lineSpacingRule ?? this.lineSpacingRule,
      indentLeft: indentLeft ?? this.indentLeft,
      indentRight: indentRight ?? this.indentRight,
      firstLineIndent: firstLineIndent ?? this.firstLineIndent,
      hangingIndent: hangingIndent ?? this.hangingIndent,
      borders: borders ?? this.borders,
      widowControl: widowControl ?? this.widowControl,
      keepNext: keepNext ?? this.keepNext,
      keepLines: keepLines ?? this.keepLines,
      outlineLevel: outlineLevel ?? this.outlineLevel,
      shadingColor: shadingColor ?? this.shadingColor,
      shadingPattern: shadingPattern ?? this.shadingPattern,
      headingLevel: headingLevel ?? this.headingLevel,
      textAlign: textAlign ?? this.textAlign,
    );
  }

  //TODO: we need to detect during compilation if more than two elements share the same text_style has
  // when them share it, we can just create a custom style and inject directly that styles reference to the paragraph
  // to optimize the final file
  //_ 
  // We can call it: "deduplication optimization"
  /// Builds a Style from direct paragraph properties.
  ///
  /// This allows applying formatting directly without requiring StyleBuilder.
  Style? toStyle() {
    final StyleBuilder builder = StyleBuilder.up();

    if (bold) builder.bold();
    if (italic) builder.italic();
    if (underline) builder.underline();
    if (strikethrough) builder.strikethrough();
    if (smallCaps) builder.smallCaps();
    if (caps) builder.caps();

    if (fontSize != null) builder.fontSize(fontSize!);
    if (fontFamily != null) builder.fontFamily(fontFamily!);
    if (fontColor != null) builder.runColor(fontColor!);
    if (backgroundColor != null) builder.highlight(backgroundColor!);

    if (spacingBefore != null || spacingAfter != null || lineSpacing != null) {
      builder.spacing(
        before: spacingBefore!,
        after: spacingAfter!,
        line: lineSpacing!,
        rule: lineSpacingRule ?? LineRule.auto,
      );
    }

    if (indentLeft != null ||
        indentRight != null ||
        firstLineIndent != null ||
        hangingIndent != null) {
      builder.indent(
        left: indentLeft!,
        right: indentRight!,
        firstLine: firstLineIndent!,
        hanging: hangingIndent,
      );
    }

    // Borders
    if (borders != null) {
      _applyBorders(builder, borders!);
    }

    // Widow/Orphan control
    if (widowControl != null) {
      builder.activateWindowControl();
    }

    // Keep settings
    if (keepNext == true) builder.keepNext(true);
    if (keepLines == true) builder.keepLines(true);

    // Outline level
    if (outlineLevel != null) builder.outlineLevel(outlineLevel!);

    // Shading
    if (shadingColor != null || shadingPattern != null) {
      builder.shading(
        color: shadingColor,
        pattern: shadingPattern,
      );
    }

    return builder.build();
  }

  /// Applies paragraph borders from ParagraphBorders object.
  void _applyBorders(StyleBuilder builder, Borders borders) {
    if (borders.top != null) {
      builder.borders(
        top: borders.top!.style,
        topSize: borders.top!.size,
        topColor: borders.top!.color,
      );
    }
    if (borders.bottom != null) {
      builder.borders(
        bottom: borders.bottom!.style,
        bottomSize: borders.bottom!.size,
        bottomColor: borders.bottom!.color,
      );
    }
    if (borders.left != null) {
      builder.borders(
        left: borders.left!.style,
        leftSize: borders.left!.size,
        leftColor: borders.left!.color,
      );
    }
    if (borders.right != null) {
      builder.borders(
        right: borders.right!.style,
        rightSize: borders.right!.size,
        rightColor: borders.right!.color,
      );
    }
  }
}

/// Controls widow and orphan line handling for paragraphs.
///
/// Widow/orphan control prevents single lines of a paragraph from appearing
/// alone at the top or bottom of a page.
///
/// - **Widow**: The last line of a paragraph appearing alone at the top of a page
/// - **Orphan**: The first line of a paragraph appearing alone at the bottom of a page
///
/// Example usage:
/// ```dart
/// final pr = Paragraph.text(
///   text: 'Important paragraph',
///   widowOrphanControl: const WidowOrphanControl(),
/// );
/// ```
class WidowOrphanControl {
  /// Creates a [WidowOrphanControl] instance.
  ///
  /// [controlLines] enables or disables widow/orphan control.
  /// [lines] sets the number of lines to keep together (default: 2).
  const WidowOrphanControl({
    this.controlLines = true,
    this.lines = 2,
  });

  /// Whether widow/orphan control is enabled.
  final bool controlLines;

  /// Number of lines to keep with next paragraph (widow)
  /// or on current page (orphan). Default is 2.
  final int lines;
}
