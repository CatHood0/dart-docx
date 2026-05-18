import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:graphicData
class GraphicData extends DocxNode<DocxNode> {
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
  GraphicData copyWith({
    DocxNode? child,
    String? id,
    DocxNode<dynamic>? parent,
    String? uri,
  }) {
    return GraphicData(
      child: child ?? this.child.copy,
      uri: uri ?? this.uri,
      id: id ?? this.id,
    )..parent = parent ?? this.parent;
  }

  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
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
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    if (!visitChildrenIfNeeded) return null;
    return child.visitAllElement(shouldGetElement, visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return child.visitElement(shouldGetElement, visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  List<XmlNode> buildXmlStyle({required BuildNodeContext context}) {
    return [];
  }
}
