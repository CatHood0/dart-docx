import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';
import '../../../core/extensions/style_to_from_node.dart';
import '../../sdk.dart';

class Paragraph extends ComponentContainer<Iterable<RunBase>> {
  Paragraph({
    required Iterable<RunBase> data,
    this.styles = const [],
    this.runStyles = const [],
    this.pageBreak = ParagraphPagebreak.none,
    this.numbering,
  }) : super(parent: null, data: data) {
    for (final RunBase content in data) {
      content.parent = this;
    }
  }

  /// All the styles applied to the paragraph
  final List<Style> styles;
  final List<Numbering> references = <Numbering>[];
  final Numbering? numbering;

  /// All the styles applied to the run
  final List<Style> runStyles;
  final ParagraphPagebreak pageBreak;

  @override
  XmlElement buildXml({required DocumentContext context}) {
    final List<XmlNode> paragraphChildren = [];
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
      paragraphChildren.add(_brPageBreak);
    }

    for (final RunBase e in data) {
      final XmlNode element = e.buildXml(context: context);
      if (element.children.isEmpty || e.isEmptyData) continue;
      paragraphChildren.add(element);
    }

    if (pageBreak == ParagraphPagebreak.after) {
      paragraphChildren.add(_brPageBreak);
    }

    return super.runParent(
      attributes: <XmlAttribute>[],
      children: paragraphChildren,
      isSelfClosing: false,
    );
  }

  XmlElement get _brPageBreak => XmlElement.tag(
        'w:r',
        children: [
          XmlElement.tag(
            'w:br',
            attributes: [
              XmlAttribute(
                'w:type'.toName(),
                'page',
              ),
            ],
          )
        ],
      );

  @override
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    final List<XmlElement> pPrChildren = [];

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
          children: [
            XmlElement.tag(
              'w:ilvl',
              attributes: [
                XmlAttribute(
                  'w:val'.toName(),
                  numbering!.level.toString(),
                ),
              ],
            ),
            XmlElement.tag(
              'w:numId',
              attributes: [
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
      final bool shouldShowStyleRef = !style.isReference;
      appliedStyles[style.styleId] = style;
      // references does not require apply of attributes
      if (style.isReference) {
        pPrChildren.addAll(style.toParagraphStyleNodes(
          useConfigurators: false,
        ));
        continue;
      }
      pPrChildren.addAll(style.toParagraphStyleNodes(
        shouldShowStyleRef: shouldShowStyleRef,
      ));
    }
    return <XmlElement>[...pPrChildren];
  }

  @override
  Paragraph get copy => Paragraph(
        data: data,
        styles: styles,
      );

  @override
  RunBase? visitElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final element in data) {
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final RunBase? foundedEl = element.visitElement(
          shouldGetElement,
        );
        if (foundedEl != null) {
          return foundedEl;
        }
      }
    }
    return null;
  }

  @override
  List<RunBase>? visitAllElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (data.isEmpty) return <RunBase>[];
    final List<RunBase> elements = <RunBase>[];
    for (final RunBase element in data) {
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<RunBase>? foundedEl = element.visitAllElement(
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
