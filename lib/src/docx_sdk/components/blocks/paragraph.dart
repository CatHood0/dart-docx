import 'dart:math' as math;
import 'dart:typed_data';

import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/extensions/style_to_from_node.dart';
import '../../utils/logger/logger_configs.dart';
import '../../xml_components/numbering/abstract_numbering_component.dart';

/// Fundamental document unit for organizing text content.
///
/// Paragraphs are the primary structural element in DOCX documents,
/// containing one or more text runs and optional formatting properties.
/// They support styling, alignment, numbering (lists), and page breaks.
///
/// Paragraphs can be thought of as analogous to `<p>` tags in HTML.
///
/// ## Direct Styling Properties
///
/// Instead of creating separate [Style] objects with [StyleBuilder], you can use
/// direct properties for common formatting. This simplifies common use cases:
///
/// ### Text Formatting
/// ```dart
/// Paragraph.text(
///   text: 'Formatted text',
///   bold: true,
///   italic: true,
///   underline: true,
///   strikethrough: true,
///   smallCaps: true,
///   caps: true,
/// );
/// ```
///
/// ### Font Properties
/// ```dart
/// Paragraph.text(
///   text: 'Custom font',
///   fontSize: 12,  // In Points units
///   fontFamily: 'Arial',   // Font name
///   fontColor: Color(0xFF0000FF),   // Blue text
///   highlightColor: Color(0xFFFFFF00), // Yellow highlight
/// );
/// ```
///
/// ### Spacing & Indentation
/// ```dart
/// Paragraph.text(
///   text: 'Indented text',
///   spacingBefore: 12,     // 240 twips
///   spacingAfter: 6,       // 120 twips
///   indentLeft: 0.5,       // 720 twips
///   indentRight: 0.25,     // 360 twips
///   firstLineIndent: 0.5,  // 720 twips
/// );
/// ```
///
/// ### Borders & Shading
/// ```dart
/// Paragraph.text(
///   text: 'With border',
///   borders: ParagraphBorders(
///     bottom: BorderDefinition(
///       style: BorderStyle.single,
///       size: 6,
///       color: Color(0xFF000000),
///     ),
///   ),
///   shadingColor: Color(0xFFFFFFF0),
///   shadingPattern: ShadingPattern.clear,
/// );
/// ```
///
/// ### Control Properties
/// ```dart
/// Paragraph.text(
///   text: 'Controlled paragraph',
///   widowControl: const WidowOrphanControl(),
///   keepNext: true,        // Keep with next paragraph
///   keepLines: true,       // Keep all lines together
///   outlineLevel: 0,       // Outline level for TOC
/// );
/// ```
///
/// ## Example usage:
/// ```dart
/// final paragraph = Paragraph(
///   children: [
///     TextRun.text(text: 'First line of text.'),
///     TextRun.text(text: ' Second line.'),
///   ],
///   styles: [Style.reference('Normal')],
///   alignment: Alignment.center,
///   numbering: Numbering(reference: 'bulletList', level: 0),
/// );
/// ```
///
/// See also:
/// - [StyleBuilder] for creating complex styles
/// - [ParagraphBorders] for paragraph border configuration
/// - [WidowOrphanControl] for widow/orphan line control
class Paragraph extends ComponentContainer<List<RunBase>> {
  Paragraph({
    required Iterable<RunBase> children,
    Iterable<Style> styles = const <Style>[],
    this.pageBreak = ParagraphPageBreak.none,
    this.numbering,
    this.alignment,
    // Text formatting properties
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.smallCaps = false,
    this.caps = false,
    // Font properties
    this.fontSize,
    this.fontFamily,
    this.fontColor,
    this.highlightColor,
    // Spacing properties
    this.spacingBefore,
    this.spacingAfter,
    this.lineSpacing,
    this.lineSpacingRule,
    // Indent properties
    this.indentLeft,
    this.indentRight,
    this.firstLineIndent,
    this.hangingIndent,
    // Border properties
    this.borders,
    // Widow/Orphan control
    this.widowControl,
    // Keep settings
    this.keepNext,
    this.keepLines,
    // Outline level
    this.outlineLevel,
    // Shading
    this.shadingColor,
    this.shadingPattern,
    int? level,
    super.id,
  })  : headingLevel = level,
        styles = List.from(styles),
        super(parent: null, child: <RunBase<dynamic>>[...children]) {
    int index = 0;
    for (final RunBase content in children) {
      length += content.dataLength;
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  factory Paragraph.text({
    required String text,
    String? id,
    Iterable<Style> styles = const <Style>[],
    Iterable<Object> runStyles = const <Object>[],
    ParagraphPageBreak pageBreak = ParagraphPageBreak.none,
    int? level,
    Numbering? numbering,
    Alignment? align,
    // Text formatting properties
    bool bold = false,
    bool italic = false,
    bool underline = false,
    bool strikethrough = false,
    bool smallCaps = false,
    bool caps = false,
    // Font properties
    num? fontSize,
    String? fontFamily,
    Color? fontColor,
    Color? highlightColor,
    // Spacing properties
    int? spacingBefore,
    int? spacingAfter,
    int? lineSpacing,
    LineRule? lineSpacingRule,
    // Indent properties
    int? indentLeft,
    int? indentRight,
    int? firstLineIndent,
    int? hangingIndent,
    // Border properties
    ParagraphBorders? borders,
    // Widow/Orphan control
    WidowOrphanControl? widowControl,
    // Keep settings
    bool? keepNext,
    bool? keepLines,
    // Outline level
    int? outlineLevel,
    // Shading
    Color? shadingColor,
    ShadingPattern? shadingPattern,
  }) =>
      Paragraph(
        id: id,
        styles: styles,
        numbering: numbering,
        level: level,
        alignment: align,
        pageBreak: pageBreak,
        bold: bold,
        italic: italic,
        underline: underline,
        strikethrough: strikethrough,
        smallCaps: smallCaps,
        caps: caps,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontColor: fontColor,
        highlightColor: highlightColor,
        spacingBefore: spacingBefore,
        spacingAfter: spacingAfter,
        lineSpacing: lineSpacing,
        lineSpacingRule: lineSpacingRule,
        indentLeft: indentLeft,
        indentRight: indentRight,
        firstLineIndent: firstLineIndent,
        hangingIndent: hangingIndent,
        borders: borders,
        widowControl: widowControl,
        keepNext: keepNext,
        keepLines: keepLines,
        outlineLevel: outlineLevel,
        shadingColor: shadingColor,
        shadingPattern: shadingPattern,
        children: <RunBase<dynamic>>[
          TextRun.text(
            text: text,
            styles: List.from(runStyles),
          ),
        ],
      );

  factory Paragraph.empty() => Paragraph(
        children: <RunBase<dynamic>>[
          TextRun.empty(),
        ],
      );

  factory Paragraph.run(
    DocxTreeNode node, {
    Iterable<Style> styles = const <Style>[],
    ParagraphPageBreak pageBreak = ParagraphPageBreak.none,
    Numbering? numbering,
    Alignment? align,
    String? id,
    // Text formatting properties
    bool bold = false,
    bool italic = false,
    bool underline = false,
    bool strikethrough = false,
    bool smallCaps = false,
    bool caps = false,
    // Font properties
    num? fontSize,
    String? fontFamily,
    Color? fontColor,
    Color? highlightColor,
    // Spacing properties
    int? spacingBefore,
    int? spacingAfter,
    int? lineSpacing,
    LineRule? lineSpacingRule,
    // Indent properties
    int? indentLeft,
    int? indentRight,
    int? firstLineIndent,
    int? hangingIndent,
    // Border properties
    ParagraphBorders? borders,
    // Widow/Orphan control
    WidowOrphanControl? widowControl,
    // Keep settings
    bool? keepNext,
    bool? keepLines,
    // Outline level
    int? outlineLevel,
    // Shading
    Color? shadingColor,
    ShadingPattern? shadingPattern,
  }) =>
      Paragraph(
        id: id,
        styles: styles,
        numbering: numbering,
        alignment: align,
        pageBreak: pageBreak,
        bold: bold,
        italic: italic,
        underline: underline,
        strikethrough: strikethrough,
        smallCaps: smallCaps,
        caps: caps,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontColor: fontColor,
        highlightColor: highlightColor,
        spacingBefore: spacingBefore,
        spacingAfter: spacingAfter,
        lineSpacing: lineSpacing,
        lineSpacingRule: lineSpacingRule,
        indentLeft: indentLeft,
        indentRight: indentRight,
        firstLineIndent: firstLineIndent,
        hangingIndent: hangingIndent,
        borders: borders,
        widowControl: widowControl,
        keepNext: keepNext,
        keepLines: keepLines,
        outlineLevel: outlineLevel,
        shadingColor: shadingColor,
        shadingPattern: shadingPattern,
        children: <RunBase<dynamic>>[
          Run(
            component: node,
            wrapInRunMark: true,
          ),
        ],
      );

  /// All the styles applied to the paragraph
  List<Style> styles;
  List<Numbering> references = <Numbering>[];
  Numbering? numbering;

  ParagraphPageBreak pageBreak;
  Alignment? alignment;

  // Text formatting properties (run properties)
  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final bool smallCaps;
  final bool caps;

  // Font properties
  final num? fontSize;
  final String? fontFamily;
  final Color? fontColor;
  final Color? highlightColor;

  // Spacing properties
  final int? spacingBefore;
  final int? spacingAfter;
  final int? lineSpacing;
  final LineRule? lineSpacingRule;

  // Indent properties
  final int? indentLeft;
  final int? indentRight;
  final int? firstLineIndent;
  final int? hangingIndent;
  final int? headingLevel;

  // Border properties
  final ParagraphBorders? borders;

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

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    context.currentContentPart = this;
    final List<XmlNode> paragraphChildren = <XmlNode>[];
    final List<XmlElement> paragraphStyles = buildXmlStyle(context: context);
    if (paragraphStyles.isNotEmpty) {
      paragraphChildren.add(
        XmlElement.tag(
          xmlParagraphBlockAttrsNode,
          children: paragraphStyles,
          isSelfClosing: false,
        ),
      );
    }

    for (final RunBase e in child) {
      context.currentContentPart = this;
      final List<XmlNode> element = e.buildXml(context: context);
      if (e.shouldIgnore() || element.isEmpty || e.isEmptyNode()) {
        continue;
      }
      paragraphChildren.addAll(element);
    }

    if (pageBreak == ParagraphPageBreak.after) {
      paragraphChildren.addAll(Run.pageBreak().buildXml(context: context));
    }

    return <XmlElement>[
      super.paragraph(
        attributes: <XmlAttribute>[],
        children: paragraphChildren,
        isSelfClosing: false,
      ),
    ];
  }

  @override
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    final List<XmlElement> pPrChildren = <XmlElement>[];

    if (numbering != null) {
      if (numbering!.level > 9) {
        throw 'Level cannot be greater than 9. Read more here: '
            'https://answers.microsoft.com/en-us/msoffice/forum/'
            'all/does-word-support-more-than-9-list-levels/'
            'd130fdcd-1781-446d-8c84-c6c79124e4d7';
      }
      checkAbstractNumberingInstanceExistence(context, numbering!.reference);
      assert(
        context.registerInstance != null,
        'registerInstance must not be null at this point',
      );
      context.registerInstance!.call(
        numbering!.reference,
        numbering!.refId ?? 0,
        level: numbering!.level,
      );
      pPrChildren.add(numbering!.build(context));
    }

    bool alreadyHasReference = false;

    if (context.checkStyleRefExistence && headingLevel != null) {
      final Style? header =
          context.options.docStyles.getStyleById('Heading${headingLevel!}');
      if (header != null && !header.isInvalid) {
        alreadyHasReference = true;
        pPrChildren.addAll(header.forParagraphStyle(
          shouldShowStyleRef: true,
          useConfigurators: false,
        ));
      } else {
        CompilerLogger.root.w(
          'Not found heading '
          'level style for $headingLevel. '
          'Heading will be ignored for '
          '$runtimeType:$id at $index with deep tree level $depth, '
          'child of ${parent?.runtimeType}',
        );
      }
    }

    // Build style from direct properties
    final Style? directStyle = _buildDirectStyle(context);
    if (directStyle != null) {
      final List<XmlElement> directStyleXml = directStyle.forParagraphStyle(
        shouldShowStyleRef: false,
        useConfigurators: true,
      );
      pPrChildren.addAll(directStyleXml);
    }

    // to avoid applying the same styles every time, we prefer
    // having something like a memoizer to avoid expensive calls
    //
    // For example, you can have 3 styles that area based on 'Normal'
    // style, so...
    // do you want to apply the 'Normal' style 3 times?
    // right, you don't!
    //TODO: we need to register configurators
    final Map<String, Style> appliedStyles = <String, Style>{};

    if (styles.isEmpty && context.setNormalStyleToNotStyledParagraphs) {
      assert(
        context.defaultNormalStyle.isReference,
        'defaultNormalStyle in DocumentContext is '
        'not a reference. Please, ensure you are '
        'setting a reference style',
      );
      Style? st = context.defaultNormalStyle;
      if (alreadyHasReference || context.checkStyleRefExistence) {
        final Style? normal = context.options.docStyles
            .getStyleById(context.defaultNormalStyle.styleId);
        if (normal != null && !normal.isInvalid) {
          st = normal;
        } else {
          st = null;
          CompilerLogger.root.w(
            'Not found style "${context.defaultNormalStyle.styleId}". '
            'It will be ignored for '
            '$runtimeType:$id at $index with deep tree level $depth, '
            'child of ${parent?.runtimeType}',
          );
        }
      }

      return <XmlElement>[
        ...?st?.forParagraphStyle(),
        ...pPrChildren,
      ];
    }

    for (final Style style in styles) {
      if (style.isInvalid || appliedStyles.containsKey(style.styleId)) {
        continue;
      }
      Style? st = style;
      // Resolve references
      if (alreadyHasReference && st.isReference ||
          context.checkStyleRefExistence) {
        final Style? stemp =
            context.options.docStyles.getStyleById(style.styleId);
        if (stemp != null && !stemp.isInvalid) {
          st = stemp;
        } else {
          st = null;
          CompilerLogger.root.w(
            'Not found style "${style.styleId}". '
            'It will be ignored for '
            '$runtimeType:$id at $index with deep tree level $depth, '
            'child of ${parent?.runtimeType}',
          );
        }
      }
      if (st == null) continue;
      // when a style isnt in DocumentStylesSheet, we prefer ignoring its
      // w:pStyle ref
      appliedStyles[st.styleId] = st;
      final List<XmlElement> xml = st.forParagraphStyle(
        shouldShowStyleRef: alreadyHasReference ? false : st.isReference,
        useConfigurators: !st.isReference,
      );
      pPrChildren.addAll(xml);
    }
    return <XmlElement>[...pPrChildren];
  }

  /// Builds a Style from direct paragraph properties.
  ///
  /// This allows applying formatting directly without requiring StyleBuilder.
  Style? _buildDirectStyle(DocumentContext context) {
    final StyleBuilder builder = StyleBuilder.singularP();
    if (pageBreak != ParagraphPageBreak.none) builder.pageBreakBefore();
    if (alignment != null) builder.alignment(alignment!);

    if (context.childOfAncestorOfExactType<Align>()) {
      final Alignment al = context.getAncestorOfExactType<Align>()!.alignment;
      CompilerLogger.root
          .d('Replace current align $alignment to found ancestor ${al.name}');
      builder.alignment(al);
    }

    if (bold) builder.bold();
    if (italic) builder.italic();
    if (underline) builder.underline();
    if (strikethrough) builder.strikethrough();
    if (smallCaps) builder.smallCaps();
    if (caps) builder.caps();

    if (fontSize != null) builder.fontSize(fontSize!.ptToHalfPoints());
    if (fontFamily != null) builder.fontFamily(fontFamily!);
    if (fontColor != null) builder.runColor(fontColor!);
    if (highlightColor != null) builder.highlight(highlightColor!);

    if (spacingBefore != null || spacingAfter != null || lineSpacing != null) {
      builder.spacing(
        before: spacingBefore!.ptToTwips(),
        after: spacingAfter!.ptToTwips(),
        line: lineSpacing!.ptToTwips(),
        rule: lineSpacingRule ?? LineRule.auto,
      );
    }

    if (indentLeft != null ||
        indentRight != null ||
        firstLineIndent != null ||
        hangingIndent != null) {
      builder.indent(
        left: indentLeft!.inchesToTwips(),
        right: indentRight!.inchesToTwips(),
        firstLine: firstLineIndent!.inchesToTwips(),
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
  void _applyBorders(StyleBuilder builder, ParagraphBorders borders) {
    if (borders.top != null) {
      builder.borders(
        top: borders.top!.style,
        topSize: borders.top!.size,
        topColor: borders.top!.color?.toColorValue()!.toUpperCase(),
      );
    }
    if (borders.bottom != null) {
      builder.borders(
        bottom: borders.bottom!.style,
        bottomSize: borders.bottom!.size,
        bottomColor: borders.bottom!.color?.toColorValue()!.toUpperCase(),
      );
    }
    if (borders.left != null) {
      builder.borders(
        left: borders.left!.style,
        leftSize: borders.left!.size,
        leftColor: borders.left!.color?.toColorValue()!.toUpperCase(),
      );
    }
    if (borders.right != null) {
      builder.borders(
        right: borders.right!.style,
        rightSize: borders.right!.size,
        rightColor: borders.right!.color?.toColorValue()!.toUpperCase(),
      );
    }
  }

  @override
  Paragraph get copy => Paragraph(
        id: id,
        children: child,
        alignment: alignment,
        pageBreak: pageBreak,
        numbering: numbering,
        styles: styles,
        bold: bold,
        italic: italic,
        underline: underline,
        strikethrough: strikethrough,
        smallCaps: smallCaps,
        caps: caps,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontColor: fontColor,
        highlightColor: highlightColor,
        spacingBefore: spacingBefore,
        spacingAfter: spacingAfter,
        lineSpacing: lineSpacing,
        lineSpacingRule: lineSpacingRule,
        indentLeft: indentLeft,
        indentRight: indentRight,
        firstLineIndent: firstLineIndent,
        hangingIndent: hangingIndent,
        borders: borders,
        widowControl: widowControl,
        keepNext: keepNext,
        keepLines: keepLines,
        outlineLevel: outlineLevel,
        shadingColor: shadingColor,
        shadingPattern: shadingPattern,
      );

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final RunBase<dynamic> element in child) {
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxTreeNode? foundedEl = element.visitElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          return foundedEl;
        }
      }
    }
    return null;
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (child.isEmpty) return <RunBase>[];
    final List<DocxTreeNode> elements = <DocxTreeNode>[];
    for (final RunBase element in child) {
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxTreeNode>? foundedEl = element.visitAllElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          elements.addAll(foundedEl);
        }
      }
    }
    return elements;
  }

  void checkAbstractNumberingInstanceExistence(
    DocumentContext context,
    String ref,
  ) {
    // Checks if context provided comes from
    // a test or [visitElement] callback
    // to avoid exceptions during checking. And then, we
    // just ignore it
    if (context.getAbstractNumId != null) {
      final XmlNumberingComponent c =
          context.numberingStore.buildNumberingXmlDocumentComponent();
      final XmlAbstractNumComponent? abstractInstance =
          c.abstractNumberingMap[ref];
      //TODO: put this exception in another place
      // or create a custom Exception for this particular thing
      if (abstractInstance == null) {
        throw Exception(
          '''No registered abstract instance for $ref. Please, ensure that you are passing the NumberingOption in "numberingOption" property from DocumentOptions class.
  NumberingOptions(
    refKey: '$ref',
    levels: <LevelOptions>[
        LevelOptions(
          level: 0,
          format: LevelFormat.bullet, // or "LevelFormat.decimal"
          text: '\u25CF', // or "%1." for digits or list of letters
          start: 1,
          paragraphStyle: StyleBuilder.paragraph('$ref-lvl0')
            .indent(
              left: 0.5.inchesToTwips(),
              hanging: 0.25.inchesToTwips(),
            )
            .build(),
          runStyle: StyleBuilder.character('$ref-lvl0')
            .fontFamily('Symbol')
            .build(),
        ),
        LevelOptions(
          level: 1,
          format: LevelFormat.bullet, // or "LevelFormat.decimal"
          text: '\u25CF', // or "%2." for digits or list of letters (never use the same text for different levels)
          start: 1,
          paragraphStyle: StyleBuilder.paragraph('$ref-lvl1')
            .indent(
              left: 1.0.inchesToTwips(),
              hanging: 0.25.inchesToTwips(),
            )
            .build(),
          runStyle: StyleBuilder.character('$ref-lvl0')
            .fontFamily('Symbol')
            .build(),
        ),
    ],
  );
''',
        );
      }
    }
  }

  void addRun(RunBase run) {
    child.add(run);
  }

  void addRunFirst(RunBase run) {
    child.insert(0, run);
  }

  void addRunAt(int index, RunBase run) {
    child.insert(index, run);
  }

  @override
  void addAll(List<DocxTreeNode<dynamic>> components) {
    for (final DocxTreeNode<dynamic> v in components) {
      length += v.length;
      if (v is RunBase) {
        child.add(v);
        continue;
      }

      child.add(Run(component: v));
    }
  }

  @override
  void insertText(
    String text, {
    int? offset,
    int? path,
    List<Object>? styles,
    bool mergeStyles = true,
  }) {
    assert(
      styles == null ||
          styles.every((Object e) => e is Attributes || e is Style),
      'styles must be only Attributes or Style type',
    );
    offset ??= 0;
    if (path != null) {
      return;
    }
    final (int index, int remaining) = getIndexByOffset(offset);
    if (index == -1) {
      addRun(
        TextRun.text(
          text: text,
          styles: styles ?? <Object>[],
        ),
      );
      return;
    }

    final RunBase<dynamic> run = child.elementAt(index);

    if (run is Run && (run.child is! TextRun && run.child is! HyperlinkRun)) {
      addRun(
        TextRun.text(
          text: text,
          styles: styles ?? <Object>[],
        ),
      );
      return;
    }

    final DocxTreeNode<dynamic> childData = run is Run ? run.child : run;
    final int local = math.min(childData.length, remaining);

    if (childData is TextRun) {
      childData.insertText(
        text,
        offset: local,
        mergeStyles: true,
        styles: styles,
      );
    } else if (childData is HyperlinkRun) {
      childData.insertText(
        text,
        offset: local,
        mergeStyles: true,
        styles: styles,
      );
    }
  }

  (int, int) getIndexByOffset(int offset, {int startOffset = 0}) {
    final int index = child.indexWhere((RunBase<dynamic> e) {
      if ((startOffset + e.length) > offset) {
        return true;
      }
      startOffset += e.length;
      return false;
    });
    return (index, startOffset);
  }

  Paragraph cut(int offset, int offsetEnd) {
    if (offset < 0 || offset >= length || offsetEnd < 0 || offsetEnd > length) {
      return Paragraph.empty();
    }

    assert(offset < offsetEnd, 'offsets must be normalized');

    final (int index, int local) = getIndexByOffset(offset);
    if (index == -1) {
      return Paragraph.empty();
    }

    int remaining = offsetEnd - local;
    int start = local - offset;
    final List<RunBase> runs = <RunBase<dynamic>>[];

    for (int i = index; i < child.length; i++) {
      if (remaining <= 0) break;
      final (
        RunBase<dynamic> left,
        RunBase<dynamic> center,
        RunBase<dynamic> right
      ) = child[i].cutAll(start, remaining);

      //TODO: check if this works as expected
      if ((!left.isEmptyData || left.length > 0) && !left.isEmptyNode()) {
        runs.add(left);
      }
      if (!center.isEmptyData && !center.isEmptyNode()) {
        runs.add(center);
      }
      if (!right.isEmptyData && !right.isEmptyNode()) {
        runs.add(right);
      }
      start = 0;
      remaining -= center.length;
    }

    return Paragraph(children: runs, styles: styles.toList());
  }

  @override
  void addImage(
    ImageData<Object> data, {
    required bool anchored,
    String? id,
  }) {
    if (anchored) {
      super.child.add(
            Run(
              component: Drawing(
                child: data is ImageData<Uint8List>
                    ? FloatingImage(
                        id: id,
                        data: data.cast(),
                      )
                    : LazyFloatingImage(
                        id: id,
                        data: data.cast(),
                      ),
              ),
            ),
          );
      return;
    }

    super.child.add(
          Run(
            component: Drawing(
              child: data is ImageData<Uint8List>
                  ? Image(
                      id: id,
                      data: data.cast(),
                      asInline: true,
                    )
                  : LazyImage(
                      id: id,
                      data: data.cast(),
                      asInline: true,
                    ),
            ),
          ),
        );
  }

  @override
  void updateElement(DocxTreeNode component, {int? index, bool strict = true}) {
    if (component is! RunBase) return;

    final int i = index ??
        child.indexWhere((RunBase<dynamic> el) => component.id == el.id);
    if (i <= -1) {
      CompilerLogger.root.w(
        'Tried to updated an '
        'element using: $component, '
        'but there is no match for it',
      );
      return;
    }

    final RunBase<dynamic> element = child[i];
    if (strict && component.child.runtimeType != element.child.runtimeType ||
        component.id != element.id) {
      return;
    }

    length -= element.length;

    CompilerLogger.root.d(
      'Replaced | $element | '
      'state using | $component | '
      'state at: $i in $runtimeType class type',
    );

    length += component.length;

    child[i] = component.copy.cast<RunBase>();
  }
}

/// Controls page break behavior for paragraphs.
enum ParagraphPageBreak {
  /// Insert page break after this paragraph.
  after,

  /// Insert page break before this paragraph.
  before,

  /// No page break (default).
  none,
}

/// Configuration for numbered or bulleted list items.
///
/// Defines how a paragraph participates in document numbering (lists).
/// Each numbering reference corresponds to a list definition in the
/// document's numbering store.
class Numbering {
  Numbering({
    required this.reference,
    this.level = 0,
    this.refId,
  }) : assert(
          level >= 0 && level <= 9,
          'Numbering level must be between 0 and 9. '
          'Word does not support more than 9 list levels.',
        );

  /// Reference key to a numbering definition in [NumberingOptions].
  final String reference;

  /// List nesting level (0-9). Level 0 is the top-level list item.
  final int level;

  /// The unique reference id of this item
  ///
  /// Share the same id when you need a continuous
  /// count of your items
  ///
  /// Change the id between the item when you need
  /// to reset the list count
  final int? refId;

  String get concreteRef => '$reference-${refId ?? 0}';

  XmlElement build(DocumentContext context) {
    return XmlElement.tag(
      'w:numPr',
      children: <XmlNode>[
        XmlElement.tag(
          'w:ilvl',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              level.toString(),
            ),
          ],
        ),
        XmlElement.tag(
          'w:numId',
          attributes: <XmlAttribute>[
            XmlAttribute(
              'w:val'.toName(),
              context.getConcreteNumId!(concreteRef)!.toString(),
            ),
          ],
        ),
      ],
    );
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
