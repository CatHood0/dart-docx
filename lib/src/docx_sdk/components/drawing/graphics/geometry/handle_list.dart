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
class HandlesList extends DocxNode<Iterable<AdjustHandle>> {
  HandlesList({
    Iterable<AdjustHandle> values = const <AdjustHandle>[],
  }) : super(child: values);

  @override
  HandlesList get copy => HandlesList(values: child);

  @override
  HandlesList copyWith({
    Iterable<AdjustHandle>? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return HandlesList(
      values: child ?? this.child,
    )..parent = parent ?? this.parent;
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:ahLst',
        children: child.map((AdjustHandle handle) {
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
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <DocxNode<dynamic>>[this] : null;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }
}
