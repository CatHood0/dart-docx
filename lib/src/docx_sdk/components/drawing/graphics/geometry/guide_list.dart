import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/string_ext.dart';

/// Geometry guide for parameterized shapes.
class GeometryGuide {
  const GeometryGuide({
    required this.name,
    required this.formula,
  });

  final String name;
  final String formula;
}

// Represents a:avLst
class GeometryGuideList extends DocxTreeNode<Iterable<GeometryGuide>> {
  GeometryGuideList({
    Iterable<GeometryGuide> values = const <GeometryGuide>[],
  }) : super(child: values);

  @override
  GeometryGuideList get copy => GeometryGuideList(values: child);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:gdLst',
        isSelfClosing: child.isEmpty,
        children: <XmlNode>[
          ...child.map((GeometryGuide el) {
            return XmlElement.tag(
              'a:gd',
              attributes: <XmlAttribute>[
                XmlAttribute('name'.toName(), el.name),
                XmlAttribute('fmla'.toName(), el.formula.toString()),
              ],
            );
          })
        ],
      ),
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
