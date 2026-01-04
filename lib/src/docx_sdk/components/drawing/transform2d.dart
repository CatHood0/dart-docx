import 'package:xml/xml.dart';
import '../../../../docx.dart';
import 'offset.dart';

// Represents a:xfrm
class Transform2D extends DocxTreeNode<dynamic> {
  Transform2D({
    required this.offset,
    required this.extents,
  }) : super(data: null);

  final Offset offset;
  final AnnotationExtents extents;

  @override
  Transform2D get copy => Transform2D(
        offset: offset.copy,
        extents: extents.copy,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:xfrm',
        isSelfClosing: false,
        children: [
          ...offset.buildXml(context: context),
          ...extents.buildXml(context: context),
        ],
      ),
    ];
  }

  @override
  List<Transform2D>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    if (!visitChildrenIfNeeded) return null;
    return offset.visitAllElement(shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded)
            as List<Transform2D>? ??
        extents.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) as List<Transform2D>?;
  }

  @override
  Transform2D? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return offset.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) as Transform2D? ??
        extents.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) as Transform2D?;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}
