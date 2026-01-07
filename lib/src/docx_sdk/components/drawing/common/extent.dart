import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents wp:extent
class Extent extends DocxTreeNode<dynamic> {
  Extent({required this.cx, required this.cy}) : super(data: null);

  final num cx;
  final num cy;

  @override
  Extent get copy => Extent(cx: cx, cy: cy);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'wp:extent',
        attributes: [
          XmlAttribute(XmlName.fromString('cx'), cx.toString()),
          XmlAttribute(XmlName.fromString('cy'), cy.toString()),
        ],
        isSelfClosing: true,
      ),
    ];
  }

  @override
  List<Extent>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  Extent? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }
}

