import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:ext
class AnnotationExtents extends DocxTreeNode<dynamic> {
  AnnotationExtents({required this.cx, required this.cy}) : super(child: null);

  AnnotationExtents.zero()
      : cx = 0,
        cy = 0,
        super(child: null);

  final num cx;
  final num cy;

  @override
  AnnotationExtents get copy => AnnotationExtents(cx: cx, cy: cy);

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

