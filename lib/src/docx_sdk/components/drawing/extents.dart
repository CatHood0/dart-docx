import 'package:xml/xml.dart';
import '../../../../docx.dart';

// Represents a:ext
class Extents extends DocxTreeNode<dynamic> {
  Extents({required this.cx, required this.cy}) : super(data: null);

  final num cx;
  final num cy;

  @override
  Extents get copy => Extents(cx: cx, cy: cy);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:ext',
        isSelfClosing: true,
        attributes: [
          XmlAttribute(XmlName.fromString('cx'), cx.toString()),
          XmlAttribute(XmlName.fromString('cy'), cy.toString()),
        ],
      ),
    ];
  }

  @override
  List<Extents>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  Extents? visitElement(
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

