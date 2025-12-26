import 'package:xml/xml.dart';
import '../../../../docx.dart';

// Represents a:graphic
class Graphic extends DocxTreeNode<GraphicData> {
  Graphic({
    required super.data,
    super.id,
  });

  @override
  Graphic get copy => Graphic(
        data: data.copy,
        id: id,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:graphic',
        isSelfClosing: false,
        children: data.buildXml(context: context),
      ),
    ];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    if (!visitChildrenIfNeeded) return null;
    return data.visitAllElement(shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return data.visitElement(shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}
