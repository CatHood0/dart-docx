import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:blip
class Blip extends DocxNode<String> {
  Blip({
    required String embedRelId,
    super.id,
    super.parent,
  }) : super(child: embedRelId);

  @override
  Blip get copy => Blip(
        embedRelId: child,
        id: id,
        parent: parent,
      );

  @override
  Blip copyWith({
    String? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return Blip(
      embedRelId: child ?? this.child,
      parent: parent ?? this.parent,
      id: id ?? this.id,
    );
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'a:blip',
        attributes: <XmlAttribute>[
          XmlAttribute(XmlName.fromString('r:embed'), child),
        ],
        isSelfClosing: true,
      ),
    ];
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <Blip>[this] : null;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
