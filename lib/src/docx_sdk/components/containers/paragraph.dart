import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/extensions/style_to_from_node.dart';

/// Fundamental document unit for organizing text content.
///
/// Paragraphs are the primary structural element in DOCX documents,
/// containing one or more text runs and optional formatting properties.
/// They support styling, alignment, numbering (lists), and page breaks.
///
/// Paragraphs can be thought of as analogous to `<p>` tags in HTML.
///
/// Example usage:
/// ```dart
/// final paragraph = Paragraph(
///   data: [
///     TextRun.text(text: 'First line of text.'),
///     TextRun.text(text: ' Second line.'),
///   ],
///   styles: [Style.reference('Normal')],
///   alignment: Alignment.center,
///   numbering: Numbering(reference: 'bulletList', level: 0),
/// );
/// ```
class Paragraph extends ComponentContainer<List<RunBase>> {
  Paragraph({
    required Iterable<RunBase> data,
    Iterable<Style> styles = const <Style>[],
    this.pageBreak = ParagraphPageBreak.none,
    this.numbering,
    this.alignment,
    super.id,
  })  : styles = List.from(styles),
        super(parent: null, data: <RunBase<dynamic>>[...data]) {
    int index = 0;
    for (final RunBase content in data) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  factory Paragraph.text({
    required String text,
    Iterable<Style> styles = const <Style>[],
    Iterable<Object> runStyles = const <Object>[],
    ParagraphPageBreak pageBreak = ParagraphPageBreak.none,
    Numbering? numbering,
    Alignment? align,
  }) =>
      Paragraph(
        styles: styles,
        numbering: numbering,
        alignment: align,
        pageBreak: pageBreak,
        data: <RunBase<dynamic>>[
          TextRun.text(
            text: text,
            styles: List.from(runStyles),
          ),
        ],
      );

  factory Paragraph.empty() => Paragraph(
        data: <RunBase<dynamic>>[
          TextRun.empty(),
        ],
      );

  /// All the styles applied to the paragraph
  List<Style> styles;
  List<Numbering> references = <Numbering>[];
  Numbering? numbering;

  ParagraphPageBreak pageBreak;
  Alignment? alignment;

  void addRun(RunBase run) {
    data.add(run);
  }

  void addRunFirst(RunBase run) {
    data.insert(0, run);
  }

  void addRunAt(int index, RunBase run) {
    data.insert(index, run);
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
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

    if (pageBreak == ParagraphPageBreak.before) {
      styles.add(
        StyleBuilder.singularP().pageBreakBefore().build(),
      );
    }

    if (alignment != null) {
      styles.add(
        StyleBuilder.singularP()
            .alignment(
              alignment!,
            )
            .build(),
      );
    }

    for (final RunBase e in data) {
      final List<XmlNode> element = e.buildXml(context: context);
      if (e.shouldIgnore() || element.isEmpty) {
        continue;
      }
      paragraphChildren.addAll(element);
    }

    if (pageBreak == ParagraphPageBreak.after) {
      paragraphChildren.addAll(
        Run(
          // will return this break in a <w:r>
          wrapInRunMark: true,
          component: Break.pageBreak(),
        ).buildXml(context: context),
      );
    }

    return <XmlElement>[
      super.runParent(
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
      //TODO:  we need to check if the reference exist
      // in the options
      assert(
        context.registerInstance != null,
        'registerInstance must not be null at this point',
      );
      context.registerInstance!.call(
        numbering!.reference,
        numbering!.instance ?? 0,
      );
      final String reference =
          '${numbering!.reference}-${numbering!.instance ?? 0}';
      pPrChildren.add(
        XmlElement.tag(
          'w:numPr',
          children: <XmlNode>[
            XmlElement.tag(
              'w:ilvl',
              attributes: <XmlAttribute>[
                XmlAttribute(
                  'w:val'.toName(),
                  numbering!.level.toString(),
                ),
              ],
            ),
            XmlElement.tag(
              'w:numId',
              attributes: <XmlAttribute>[
                XmlAttribute(
                  'w:val'.toName(),
                  context.getConcreteNumId!(reference)!.toString(),
                ),
              ],
            ),
          ],
        ),
      );
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
      return <XmlElement>[
        ...context.defaultNormalStyle.forParagraphStyle(),
      ];
    }

    for (final Style style in styles) {
      if (style.isInvalid || appliedStyles.containsKey(style.styleId)) {
        continue;
      }
      // when a style isnt in DocumentStylesSheet, we prefer ignoring its
      // w:pStyle ref
      appliedStyles[style.styleId] = style;
      final List<XmlElement> xml = style.forParagraphStyle(
        shouldShowStyleRef: style.isReference,
        useConfigurators: !style.isReference,
      );
      pPrChildren.addAll(xml);
    }
    return <XmlElement>[...pPrChildren];
  }

  @override
  Paragraph get copy => Paragraph(
        id: id,
        data: data,
        styles: styles,
      );

  @override
  RunBase? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final RunBase<dynamic> element in data) {
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxTreeNode? foundedEl = element.visitElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          // to avoid issues, we wrap with this
          if (foundedEl is! RunBase) {
            return Run(component: foundedEl);
          }
          return foundedEl;
        }
      }
    }
    return null;
  }

  @override
  List<RunBase>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (data.isEmpty) return <RunBase>[];
    final List<RunBase> elements = <RunBase>[];
    for (final RunBase element in data) {
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<RunBase<dynamic>>? foundedEl = element
            .visitAllElement(
              shouldGetElement,
              visitChildrenIfNeeded: true,
            )
            ?.cast<RunBase>();
        if (foundedEl != null) {
          elements.addAll(foundedEl);
        }
      }
    }
    return elements;
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
  Numbering({required this.reference, this.level = 0, this.instance});

  /// Reference key to a numbering definition in [NumberingOptions].
  final String reference;

  /// List nesting level (0-9). Level 0 is the top-level list item.
  final int level;

  /// Usually you set an instance num
  /// when you want to separate the current
  /// element from other lists
  //NOTE: should we manage these values internally
  // to make this more easy to maintain?
  final int? instance;
}
