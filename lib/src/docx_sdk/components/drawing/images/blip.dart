import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:blip
class Blip extends DocxTreeNode<String> {
  Blip({required String embedRelId}) : super(child: embedRelId);

  @override
  Blip get copy => Blip(embedRelId: child);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
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
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <Blip>[this] : null;
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
    return <XmlNode>[];
  }
}

