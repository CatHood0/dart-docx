import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents wp:extent
class Extent extends DocxNode<dynamic> {
  Extent({
    required this.cx,
    required this.cy,
    super.id,
    super.parent,
  }) : super(child: null);

  final UnitValue cx;
  final UnitValue cy;

  @override
  Extent get copy => Extent(
        id: id,
        cx: cx,
        cy: cy,
        parent: parent,
      );

  @override
  Extent copyWith({
    String? id,
    DocxNode<dynamic>? parent,
    UnitValue? cx,
    UnitValue? cy,
  }) {
    return Extent(
      id: id ?? this.id,
      cx: cx ?? this.cx,
      cy: cy ?? this.cy,
      parent: parent ?? this.parent,
    );
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'wp:extent',
        attributes: [
          XmlAttribute(XmlName.fromString('cx'), cx.toEmu().toString()),
          XmlAttribute(XmlName.fromString('cy'), cy.toEmu().toString()),
        ],
        isSelfClosing: true,
      ),
    ];
  }

  @override
  List<Extent>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  Extent? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
