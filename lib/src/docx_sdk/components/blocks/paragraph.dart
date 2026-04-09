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
    required Iterable<RunBase> children,
    Iterable<Style> styles = const <Style>[],
    this.pageBreak = ParagraphPageBreak.none,
    this.numbering,
    this.alignment,
    super.id,
  })  : styles = List.from(styles),
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

  factory Paragraph.run(DocxTreeNode node) => Paragraph(
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
    final (index, remaining) = getIndexByOffset(offset);
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
    final local = math.min(childData.length, remaining);

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

    final (index, local) = getIndexByOffset(offset);
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
              component: DrawingML(
                child: data is ImageData<Uint8List>
                    ? FloatingImage(
                        id: id,
                        child: data.cast(),
                      )
                    : LazyFloatingImage(
                        id: id,
                        child: data.cast(),
                      ),
              ),
            ),
          );
      return;
    }

    super.child.add(
          Run(
            component: DrawingML(
              child: data is ImageData<Uint8List>
                  ? Image(
                      id: id,
                      child: data.cast(),
                      asInline: true,
                    )
                  : LazyImage(
                      id: id,
                      child: data.cast(),
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

    for (final RunBase e in child) {
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
      final String reference =
          '${numbering!.reference}-${numbering!.refId ?? 0}';
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
        ...pPrChildren,
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
        children: child,
        styles: styles,
      );

  @override
  RunBase? visitElement(
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
    if (child.isEmpty) return <RunBase>[];
    final List<RunBase> elements = <RunBase>[];
    for (final RunBase element in child) {
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
  });

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
}
