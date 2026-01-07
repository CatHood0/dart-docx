import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents wp:docPr
class DocProperties extends DocxTreeNode<dynamic> {
  DocProperties({
    required String docPrId,
    required this.name,
    this.description,
    this.relativeHeight,
  }) : super(
          data: null,
          id: docPrId,
        );

  final String name;
  final String? description;
  final String? relativeHeight;

  @override
  DocProperties get copy => DocProperties(
        docPrId: id,
        name: name,
        description: description,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'wp:docPr',
        isSelfClosing: true,
        attributes: [
          XmlAttribute(XmlName.fromString('id'), id.toString()),
          XmlAttribute(XmlName.fromString('name'), name),
          if (description != null)
            XmlAttribute(XmlName.fromString('descr'), description!),
          if (relativeHeight != null)
            XmlAttribute(
              XmlName.fromString('relativeHeight'),
              relativeHeight.toString(),
            ),
        ],
      ),
    ];
  }

  @override
  List<DocProperties>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  DocProperties? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}
