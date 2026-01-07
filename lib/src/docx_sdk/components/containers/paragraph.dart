import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/extensions/style_to_from_node.dart';

class Paragraph extends ComponentContainer<Iterable<RunBase>> {
  Paragraph({
    required Iterable<RunBase> data,
    Iterable<Style> styles = const <Style>[],
    Iterable<Style> runStyles = const <Style>[],
    this.pageBreak = ParagraphPagebreak.none,
    this.numbering,
    super.id,
  })  : styles = List.from(styles),
        runStyles = List.from(runStyles),
        super(parent: null, data: data) {
    int index = 0;
    for (final RunBase content in data) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  factory Paragraph.empty() => Paragraph(
        data: <RunBase>[
          TextRun.empty(),
        ],
      );

  /// All the styles applied to the paragraph
  List<Style> styles;
  List<Numbering> references = <Numbering>[];
  Numbering? numbering;

  /// All the styles applied to the run
  List<Style> runStyles;
  ParagraphPagebreak pageBreak;

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

    if (pageBreak == ParagraphPagebreak.before) {
      styles.add(StyleBuilder.singularP().pageBreakBefore().build());
    }

    for (final RunBase e in data) {
      final List<XmlNode> element = e.buildXml(context: context);
      if (e.shouldIgnore() || element.isEmpty) {
        continue;
      }
      paragraphChildren.addAll(element);
    }

    if (pageBreak == ParagraphPagebreak.after) {
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
    for (final Style style in styles) {
      // references  has not values to be used, so, we will need to get a usable version
      if (style.isInvalid || appliedStyles.containsKey(style.styleId)) {
        continue;
      }
      // when a style isnt in DocumentStylesSheet, we prefer ignoring its
      // w:pStyle ref
      appliedStyles[style.styleId] = style;
      // references does not require apply of attributes
      pPrChildren.addAll(style.forParagraphStyle(
        shouldShowStyleRef: style.isReference,
        useConfigurators: !style.isReference,
      ));
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

enum ParagraphPagebreak {
  after,
  before,
  none,
}

class Numbering {
  Numbering({required this.reference, this.level = 0, this.instance});

  final String reference;
  final int level;

  /// Usually you set an instance num
  /// when you want to separate the current
  /// element from other lists
  //NOTE: should we manage these values internally
  // to make this more easy to maintain?
  final int? instance;
}
