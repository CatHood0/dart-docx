import 'package:xml/xml.dart';

import '../../../core/extensions/style_to_from_node.dart';
import '../../sdk.dart';

class Paragraph extends ComponentContainer<Iterable<RunBase>> {
  Paragraph({
    required Iterable<RunBase> data,
    this.styles = const [],
  }) : super(parent: null, data: data) {
    for (final RunBase content in data) {
      content.parent = this;
    }
  }

  final List<Style> styles;

  @override
  XmlElement buildXml({required DocxComponentContext context}) {
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

    for (final RunBase e in data) {
      final XmlNode element = e.buildXml(context: context);
      if (element.children.isEmpty || e.isEmptyData) continue;
      paragraphChildren.add(element);
    }

    return super.runParent(
      attributes: <XmlAttribute>[],
      children: paragraphChildren,
      isSelfClosing: false,
    );
  }

  @override
  List<XmlElement> buildXmlStyle({required DocxComponentContext context}) {
    final List<XmlElement> pPrChildren = [];
    // to avoid applying the same styles every time, we prefer
    // having something like a memoizer to avoid expensive calls
    //
    // For example, you can have 3 styles that area based on 'Normal'
    // style, so...
    // do you want to apply the 'Normal' style 3 times?
    // right, you don't!
    final Map<String, Style> appliedStyles = <String, Style>{};
    for (final Style style in styles) {
      final String paragraphStyleId = style.styleId;
      Style resultStyle = style;
      // references  has not values to be used, so, we will need to get a usable version
      if (style.isReference) {
        resultStyle = context.options.docStyles.getStyleById(paragraphStyleId)!;
      }
      if (resultStyle.isInvalid ||
          appliedStyles.containsKey(resultStyle.styleId)) {
        continue;
      }
      final Style fullStyle =
          resultStyle.getDeepStyleRelation(context.options.docStyles);
      appliedStyles[fullStyle.styleId] = fullStyle;
      pPrChildren.addAll(fullStyle.toBlockStyleNodes());
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
