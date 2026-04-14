import 'package:xml/xml.dart';

import '../../../../docx.dart';

/// Wrapper component for DrawingML (Drawing Markup Language) elements.
///
/// This class serves as a container for drawing elements like shapes,
/// images, and other graphical content in DOCX documents. It generates
/// the `w:drawing` XML element that contains DrawingML content.
///
/// DrawingML is the XML-based format used by Microsoft Office for
/// representing vector graphics, images, and other drawing elements.
///
/// Example usage:
/// ```dart
/// final drawing = DrawingML(data: myShapeComponent);
/// ```
class Drawing extends DocxTreeNode<DocxTreeNode> with IgnorableMixin {
  Drawing({
    required super.child,
    super.id,
  }) {
    child
      ..parent = this
      ..index = 0
      ..depth = depth + 1;
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'w:drawing',
        isSelfClosing: false,
        children: <XmlNode>[
          ...child.buildXml(context: context),
        ],
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  DocxTreeNode<DocxTreeNode<dynamic>> get copy => Drawing(
        child: child.copy,
        id: id,
      );

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? <DocxTreeNode<dynamic>>[this]
        : !visitChildrenIfNeeded
            ? null
            : child.visitAllElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? this
        : !visitChildrenIfNeeded
            ? null
            : child.visitElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  bool shouldIgnore() {
    return child is IgnorableMixin && (child as IgnorableMixin).shouldIgnore();
  }
}
