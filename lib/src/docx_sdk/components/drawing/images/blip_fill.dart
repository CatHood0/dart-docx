import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../shared/fill.dart';

// Represents pic:blipFill
class BlipFill extends Fill<void> {
  BlipFill({
    required this.name,
    required this.blip,
    required this.stretch,
    super.id,
  }) : super(child: null);

  BlipFill.pic({
    required this.blip,
    required this.stretch,
    super.id,
  })  : name = 'pic',
        super(child: null);

  BlipFill.annotation({
    required this.blip,
    required this.stretch,
    super.id,
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
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        '$name:blipFill',
        isSelfClosing: false,
        children: <XmlNode>[
          ...blip.buildXml(context: context),
          ...stretch.buildXml(context: context),
        ],
      ),
    ];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxTreeNode<dynamic>>[this];
    if (!visitChildrenIfNeeded) return null;
    return blip.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        stretch.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return blip.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        stretch.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }
}
