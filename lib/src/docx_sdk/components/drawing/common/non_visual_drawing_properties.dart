import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents pic:cNvPr
class NonVisualDrawingProperties extends DocxNode<dynamic> {
  NonVisualDrawingProperties({
    required String id,
    required this.name,
    this.description,
  }) : super(child: null, id: id);

  final String name;
  final String? description;

  @override
  NonVisualDrawingProperties get copy => NonVisualDrawingProperties(
        id: id,
        name: name,
        description: description,
      );

  @override
  NonVisualDrawingProperties copyWith({
    String? id,
    DocxNode<dynamic>? parent,
    String? name,
    String? description,
  }) {
    return NonVisualDrawingProperties(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'pic:cNvPr',
        isSelfClosing: false,
        attributes: [
          XmlAttribute(XmlName.fromString('id'), id.toString()),
          XmlAttribute(XmlName.fromString('name'), name),
          if (description != null)
            XmlAttribute(XmlName.fromString('descr'), description!),
        ],
        children: [
          //TODO: make this customizable
          XmlElement.tag(
            'a:picLocks',
            isSelfClosing: true,
            attributes: [
              XmlAttribute(XmlName.fromString('noChangeAspect'), '1'),
              XmlAttribute(XmlName.fromString('noChangeArrowheads'), '1'),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  List<NonVisualDrawingProperties>? visitAllElement(
      bool Function(DocxNode element) shouldGetElement,
      {bool visitChildrenIfNeeded = true}) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  NonVisualDrawingProperties? visitElement(
      bool Function(DocxNode element) shouldGetElement,
      {bool visitChildrenIfNeeded = true}) {
    return shouldGetElement(this) ? this : null;
  }
}
