import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents pic:blipFill
class BlipFill extends Fill<void> {
  BlipFill({
    required this.name,
    required this.blip,
    required this.stretch,
    super.id,
    super.parent,
  }) : super(child: null);

  BlipFill.pic({
    required this.blip,
    required this.stretch,
    super.id,
    super.parent,
  })  : name = 'pic',
        super(child: null);

  BlipFill.annotation({
    required this.blip,
    required this.stretch,
    super.id,
    super.parent,
  })  : name = 'a',
        super(child: null);

  final String name;
  final Blip blip;
  final Stretch stretch;

  @override
  BlipFill get copy => BlipFill(
        blip: blip.copy,
        stretch: stretch.copy,
        name: name,
        id: id,
        parent: parent,
      );

  @override
  BlipFill copyWith({
    String? id,
    DocxNode<void>? parent,
    String? name,
    Blip? blip,
    Stretch? stretch,
  }) {
    return BlipFill(
      name: name ?? this.name,
      blip: blip ?? this.blip.copy,
      stretch: stretch ?? this.stretch.copy,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        '$name:blipFill',
        isSelfClosing: false,
        children: <XmlNode>[
          ...blip.ensureInitialized(context).buildXml(),
          ...stretch.ensureInitialized(context).buildXml(),
        ],
      ),
    ];
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxNode<dynamic>>[this];
    if (!visitChildrenIfNeeded) return null;
    return blip.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        stretch.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return blip.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        stretch.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }
}
