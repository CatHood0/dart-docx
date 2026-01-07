import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../shared/fill.dart';

/// Solid color fill for shapes (a:solidFill).
///
/// Fills the shape geometry with a uniform color, optionally with transparency.
//TODO: support for gradient colors?
class SolidFill extends Fill<Color> {
  SolidFill({
    required super.data,
  });

  @override
  SolidFill get copy => SolidFill(data: data.copy);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:solidFill',
        children: data.buildXml(context: context),
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxTreeNode<dynamic>>[this];
    if (!visitChildrenIfNeeded) return null;
    return data.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return data.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }
}
