import 'package:xml/xml.dart';
import '../../../../../docx.dart';

//TODO: tenemos que:
// 1. Chequear por que los offsets no funcionan
// 2. Chequear los offsets de Anchor y que hacen con los shapes
// 3. Generar más demos con diferentes tipos de figuras geometricas
// 4. Crear más pruebas complejas con documentos de investigación cortos
// 5. Generar documentación
//
// Represents a:off
class Offset extends DocxNode<dynamic> {
  Offset({required this.x, required this.y}) : super(child: null);

  Offset.zero()
      : x = 0,
        y = 0,
        super(child: null);

  final num x;
  final num y;

  @override
  Offset get copy => Offset(x: x, y: y);

  @override
  Offset copyWith({
    String? id,
    DocxNode<dynamic>? parent,
    num? x,
    num? y,
  }) {
    return Offset(x: x ?? this.x, y: y ?? this.y);
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
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
