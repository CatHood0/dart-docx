import 'package:meta/meta.dart';
import 'package:xml/xml.dart';
import '../../sdk.dart';

abstract class ComponentContainer<T> extends DocxTreeNode<T> {
  ComponentContainer({
    required super.child,
    super.parent,
    super.id,
  });

  @protected
  XmlElement paragraph({
    required List<XmlAttribute> attributes,
    required List<XmlNode> children,
    bool isSelfClosing = false,
  }) {
    return XmlElement.tag(
      xmlParagraphNode,
      attributes: attributes,
      children: children,
      isSelfClosing: isSelfClosing,
    );
  }
}
