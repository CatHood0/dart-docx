import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:off
class Offset extends DocxTreeNode<dynamic> {
  Offset({required this.x, required this.y}) : super(data: null);

  Offset.zero()
      : x = 0,
        y = 0,
        super(data: null);

  final num x;
  final num y;

  @override
  Offset get copy => Offset(x: x, y: y);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:off',
        isSelfClosing: true,
        attributes: [
          XmlAttribute(XmlName.fromString('x'), x.toString()),
          XmlAttribute(XmlName.fromString('y'), y.toString()),
        ],
      ),
    ];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}
