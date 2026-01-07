import 'package:xml/xml.dart';

import '../../../../../../docx.dart';

/// Adjust handle for interactive shape modification.
class AdjustHandle {
  const AdjustHandle({
    required this.position,
    this.minimum,
    this.maximum,
  });

  final String position; // formula like "0,0" or "500000,0"
  final String? minimum; // formula like "0,0"
  final String? maximum; // formula like "1000000,1000000"
}

// Represents a:avLst
class HandlesList extends DocxTreeNode<Iterable<AdjustHandle>> {
  HandlesList({
    Iterable<AdjustHandle> values = const <AdjustHandle>[],
  }) : super(data: values);

  @override
  HandlesList get copy => HandlesList(values: data);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:ahLst',
        children: data.map((AdjustHandle handle) {
          final List<XmlAttribute> positionAttributes = <XmlAttribute>[
            XmlAttribute(XmlName.fromString('pos'), handle.position),
          ];

          if (handle.minimum != null) {
            positionAttributes.add(
              XmlAttribute(XmlName.fromString('min'), handle.minimum!),
            );
          }

          if (handle.maximum != null) {
            positionAttributes.add(
              XmlAttribute(XmlName.fromString('max'), handle.maximum!),
            );
          }

          return XmlElement.tag(
            'a:ah',
            attributes: positionAttributes,
            isSelfClosing: true,
          );
        }),
      )
    ];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <DocxTreeNode<dynamic>>[this] : null;
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
