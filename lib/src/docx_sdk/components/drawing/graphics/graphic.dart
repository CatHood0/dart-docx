import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:graphic
class Graphic extends DocxNode<GraphicData> {
  Graphic({
    required super.child,
    super.id,
  });

  Graphic.pic({
    required DocxNode child,
    super.parent,
    super.id,
  }) : super(
          child: GraphicData(
            child: child,
            uri: namespaces['pic']!,
          ),
        );

  Graphic.shape({
    required DocxNode child,
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
  Graphic copyWith({
    GraphicData? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return Graphic(
      child: child ?? this.child.copy,
      id: id ?? this.id,
    )..parent = parent ?? this.parent;
  }

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
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}
