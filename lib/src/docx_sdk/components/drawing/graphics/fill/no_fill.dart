import 'package:xml/xml.dart';
import '../../../../../../docx.dart';
import '../../shared/fill.dart';

/// Indicates that a shape has no fill (transparent).
///
/// Used in [ShapeProperties] to specify that the shape's interior is not filled.
/// Corresponds to the `<a:noFill>` element in DrawingML.
class NoFillComponent extends Fill<void> {
  NoFillComponent() : super(data: null);

  @override
  NoFillComponent get copy => NoFillComponent();

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:noFill',
        isSelfClosing: true,
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
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
