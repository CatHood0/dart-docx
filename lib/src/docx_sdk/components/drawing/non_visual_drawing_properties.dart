import 'package:xml/xml.dart';
import '../../../../docx.dart';

// Represents pic:cNvPr
class NonVisualDrawingProperties extends DocxTreeNode<dynamic> {
  NonVisualDrawingProperties({
    required String id,
    required this.name,
    this.description,
  }) : super(data: null, id: id);

  final String name;
  final String? description;

  @override
  NonVisualDrawingProperties get copy => NonVisualDrawingProperties(
        id: id,
        name: name,
        description: description,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'pic:cNvPr',
        isSelfClosing: true,
        attributes: [
          XmlAttribute(XmlName.fromString('id'), id.toString()),
          XmlAttribute(XmlName.fromString('name'), name),
          if (description != null)
            XmlAttribute(XmlName.fromString('descr'), description!),
        ],
      ),
    ];
  }

  @override
  List<NonVisualDrawingProperties>? visitAllElement(
      bool Function(DocxTreeNode element) shouldGetElement,
      {bool visitChildrenIfNeeded = true}) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  NonVisualDrawingProperties? visitElement(
      bool Function(DocxTreeNode element) shouldGetElement,
      {bool visitChildrenIfNeeded = true}) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    // TODO: implement buildXmlStyle
    throw UnimplementedError();
  }
}

