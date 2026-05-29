import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:ext
class AnnotationExtents extends DocxNode<dynamic> {
  AnnotationExtents({
    required this.cx,
    required this.cy,
    super.id,
    super.parent,
  }) : super(child: null);

  AnnotationExtents.zero()
      : cx = Emu(0),
        cy = Emu(0),
        super(child: null);

  AnnotationExtents.same(UnitValue value)
      : cx = value,
        cy = value,
        super(child: null);

  final UnitValue cx;
  final UnitValue cy;

  @override
  AnnotationExtents get copy => AnnotationExtents(
        id: id,
        cx: cx,
        cy: cy,
        parent: parent,
      );

  @override
  AnnotationExtents copyWith({
    UnitValue? cx,
    UnitValue? cy,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return AnnotationExtents(
      id: id ?? this.id,
      cx: cx ?? this.cx,
      cy: cy ?? this.cy,
      parent: parent ?? this.parent,
    );
  }

  @override
  List<XmlElement> buildXml() {
    return <XmlElement>[
      XmlElement.tag(
        'a:ext',
        isSelfClosing: true,
        attributes: [
          XmlAttribute(XmlName.fromString('cx'), cx.toEmu().toString()),
          XmlAttribute(XmlName.fromString('cy'), cy.toEmu().toString()),
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
}
