import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:graphic
class Graphic extends DocxTreeNode<GraphicData> {
  Graphic({
    required super.child,
    super.id,
  });

  Graphic.pic({
    required DocxTreeNode child,
    super.parent,
    super.id,
  }) : super(
          child: GraphicData(
            child: child,
            uri: namespaces['pic']!,
          ),
        );

  Graphic.shape({
    required DocxTreeNode child,
    super.parent,
    super.id,
  }) : super(
          child: GraphicData(
            child: child,
            uri: namespaces['wps']!,
          ),
        );
 

  @override
  Graphic get copy => Graphic(
        child: child.copy,
        id: id,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:graphic',
        isSelfClosing: false,
        children: child.buildXml(context: context),
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
    return child.visitAllElement(shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return child.visitElement(shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}
