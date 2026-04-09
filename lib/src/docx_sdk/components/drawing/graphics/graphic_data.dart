import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:graphicData
class GraphicData extends DocxTreeNode<DocxTreeNode> {
  GraphicData({
    required super.child,
    required this.uri,
    super.id,
  });

  final String uri;

  @override
  GraphicData get copy => GraphicData(
        child: child.copy,
        uri: uri,
        id: id,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:graphicData',
        isSelfClosing: false,
        attributes: [
          XmlAttribute(XmlName.fromString('uri'), uri),
        ],
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
