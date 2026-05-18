import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:graphic
class Graphic extends DocxNode<GraphicData> {
  Graphic({
    required super.child,
    super.id,
    super.parent,
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
        id: id,
        parent: parent,
        child: child.copy,
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
      parent: parent ?? this.parent,
    );
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'a:graphic',
        isSelfClosing: false,
        children: child.ensureInitialized(context).buildXml(),
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
    return child.visitAllElement(shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return child.visitElement(shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded);
  }
}
