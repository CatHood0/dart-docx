import 'package:xml/xml.dart';

import '../../../core/extensions/style_to_from_node.dart';
import '../../sdk.dart';

class Paragraph extends ComponentContainer<Iterable<TextRunBase>> {
  Paragraph({
    required Iterable<TextRunBase> data,
    this.style,
  }) : super(parent: null, data: data) {
    for (final TextRunBase content in data) {
      content.parent = this;
    }
  }

  final Style? style;

  @override
  XmlElement buildXml({required DocxComponentContext context}) {
    final List<XmlNode> paragraphChildren = [];
    final List<XmlElement> pPrChildren = [];

    final String paragraphStyleId = style?.styleId ?? 'Normal';
    final Style? resultStyle =
        context.options.docStyles.getStyleById(paragraphStyleId);

    if (resultStyle != null && !resultStyle.isInvalid) {
      final trueStyle = resultStyle.getDeepStyleRelation(context.options.docStyles);
      pPrChildren.addAll(resultStyle.toBlockStyleNodes());
    }

    // Añadir el w:pPr construido al párrafo
    // Si el pPrChildren es vacío, no añadimos w:pPr.
    // Pero para un párrafo, <w:pPr> con <w:pStyle> es casi siempre necesario.
    if (pPrChildren.isNotEmpty) {
      paragraphChildren.add(
        XmlElement.tag(
          xmlParagraphBlockAttrsNode,
          children: pPrChildren,
          isSelfClosing: false,
        ),
      );
    }

    // 2. Añadir los contenidos inline (TextContent, HyperlinkContent, ImageContent)
    // Cada uno de estos debería generar un <w:r> o <w:hyperlink>
    for (final TextRunBase e in data) {
      final XmlNode element = e.buildXml(context: context);
      if (element.children.isEmpty || e.isEmptyData) continue;
      paragraphChildren.add(element);
    }

    // Si el párrafo está completamente vacío y no tiene estilo, podría ser solo un salto de línea
    // o un párrafo vacío que Word puede manejar, pero para seguridad siempre generamos el <w:p>
    return super.runParent(
      attributes: <XmlAttribute>[],
      children: paragraphChildren,
      isSelfClosing: false,
    );
  }

  @override
  List<XmlElement> buildXmlStyle({required DocxComponentContext context}) {
    return <XmlElement>[];
  }

  @override
  Paragraph get copy => Paragraph(
        data: data,
        style: style,
      );

  @override
  TextRunBase? visitElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final element in data) {
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final TextRunBase? foundedEl = element.visitElement(
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
  List<TextRunBase>? visitAllElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (data.isEmpty) return <TextRunBase>[];
    final List<TextRunBase> elements = <TextRunBase>[];
    for (final TextRunBase element in data) {
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<TextRunBase>? foundedEl = element.visitAllElement(
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
