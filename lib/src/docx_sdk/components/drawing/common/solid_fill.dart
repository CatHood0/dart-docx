import 'package:xml/xml.dart';

import '../../../../../docx.dart';
import '../shared/fill.dart';

/// Solid color fill for shapes (a:solidFill).
///
/// Fills the shape geometry with a uniform color, optionally with transparency.
//TODO: support for gradient colors?
class SolidFill extends Fill<Color> {
  SolidFill({
    required Color color,
  }) : super(child: color);

  @override
  SolidFill get copy => SolidFill(color: child.copy);

  @override
  SolidFill copyWith({
    String? id,
    DocxNode<Color>? parent,
    Color? color,
  }) {
    return SolidFill(color: color ?? child.copy);
  }

  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:solidFill',
        children: child.buildXml(context: context),
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required BuildNodeContext context}) {
    return <XmlNode>[];
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxNode<dynamic>>[this];
    if (!visitChildrenIfNeeded) return null;
    return child.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return child.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }
}
