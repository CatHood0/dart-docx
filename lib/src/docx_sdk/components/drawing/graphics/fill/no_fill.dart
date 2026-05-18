import 'package:xml/xml.dart';
import '../../../../../../docx.dart';

/// Indicates that a shape has no fill (transparent).
///
/// Used in [ShapeProperties] to specify that the shape's interior is not filled.
/// Corresponds to the `<a:noFill>` element in DrawingML.
class NoFillComponent extends Fill<void> {
  NoFillComponent() : super(child: null);

  @override
  NoFillComponent get copy => NoFillComponent();

  @override
  NoFillComponent copyWith({
    String? id,
    DocxNode<void>? parent,
  }) {
    return NoFillComponent()..parent = parent ?? this.parent;
  }

  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:noFill',
        isSelfClosing: true,
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
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
