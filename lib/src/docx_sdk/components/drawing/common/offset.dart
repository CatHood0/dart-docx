import 'package:xml/xml.dart';
import '../../../../../docx.dart';

//TODO:
// 1. check exactly why makes offsets not working for graphics
// 2. check how offsets behaves when using Anchor and WPShape
//
// Represents a:off
class Offset extends DocxNode<dynamic> {
  Offset({
    required this.x,
    required this.y,
    super.id,
    super.parent,
  }) : super(child: null);

  Offset.zero()
      : x = const Emu(0),
        y = const Emu(0),
        super(child: null);

  final UnitValue x;
  final UnitValue y;

  @override
  Offset get copy => Offset(
        id: id,
        x: x,
        y: y,
        parent: parent,
      );

  @override
  Offset copyWith({
    String? id,
    DocxNode<dynamic>? parent,
    UnitValue? x,
    UnitValue? y,
  }) {
    return Offset(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      parent: parent ?? this.parent,
    );
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'a:off',
        isSelfClosing: true,
        attributes: [
          XmlAttribute(
            XmlName.fromString('x'),
            x.toEmu().toString(),
          ),
          XmlAttribute(
            XmlName.fromString('y'),
            y.toEmu().toString(),
          ),
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
