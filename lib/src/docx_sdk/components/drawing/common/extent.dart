import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents wp:extent
class Extent extends DocxNode<dynamic> {
  Extent({required this.cx, required this.cy}) : super(child: null);

  final num cx;
  final num cy;

  @override
  Extent get copy => Extent(cx: cx, cy: cy);

  @override
  Extent copyWith({
    String? id,
    DocxNode<dynamic>? parent,
    num? cx,
    num? cy,
  }) {
    return Extent(cx: cx ?? this.cx, cy: cy ?? this.cy);
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
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

