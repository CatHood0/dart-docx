import 'package:meta/meta.dart';
import 'package:xml/xml.dart';
import '../../sdk.dart';

abstract class ComponentContainer<T> extends DocxContent<T> {
  ComponentContainer({
    required super.data,
    super.parent,
  });

  @protected
  XmlElement runParent({
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
