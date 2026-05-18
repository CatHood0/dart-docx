import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:ext
class AnnotationExtents extends DocxNode<dynamic> {
  AnnotationExtents({required this.cx, required this.cy}) : super(child: null);

  AnnotationExtents.zero()
      : cx = 0,
        cy = 0,
        super(child: null);

  AnnotationExtents.same(num value)
      : cx = value,
        cy = value,
        super(child: null);

  final num cx;
  final num cy;

  @override
  AnnotationExtents get copy => AnnotationExtents(cx: cx, cy: cy);

  @override
  AnnotationExtents copyWith({String? id, DocxNode<dynamic>? parent, num? cx, num? cy}) {
    return AnnotationExtents(cx: cx ?? this.cx, cy: cy ?? this.cy);
  }

  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
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
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<XmlNode> buildXmlStyle({required BuildNodeContext context}) {
    return [];
  }
}
