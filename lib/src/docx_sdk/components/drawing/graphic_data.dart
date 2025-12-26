import 'package:xml/xml.dart';
import '../../../../docx.dart';

// Represents a:graphicData
class GraphicData extends DocxTreeNode<DocxTreeNode> {
  GraphicData({
    required super.data,
    required this.uri,
    super.id,
  });

  final String uri;

  @override
  GraphicData get copy => GraphicData(
        data: data.copy,
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
