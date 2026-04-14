import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';

class Align extends DocxTreeNode<DocxTreeNode> {
  Align({
    required super.child,
    required this.alignment,
    super.id,
    super.parent,
  }) {
    child.parent = this;
    child.index = 0;
    child.depth = depth + 1;
  }

  final Alignment alignment;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      ...child.buildXml(context: context).cast(),
    ];
  }

  @override
  Align get copy => Align(
        id: id,
        alignment: alignment,
        parent: parent,
        child: child,
      );

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    if (shouldGetElement(child)) {
      return child;
    } else if (visitChildrenIfNeeded) {
      final DocxTreeNode? foundedEl = child.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: true,
      );
      if (foundedEl != null) {
        return foundedEl;
      }
    }
    return null;
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (child.isEmptyNode() ||
        child.castOrNull<IgnorableMixin>()?.shouldIgnore() == true) {
      return <DocxTreeNode>[];
    }
    final List<DocxTreeNode> elements = <DocxTreeNode>[];
    if (shouldGetElement(child)) {
      elements.add(child);
    } else if (visitChildrenIfNeeded) {
      final List<DocxTreeNode<dynamic>>? foundedEl = child.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: true,
      );
      if (foundedEl != null) {
        elements.addAll(foundedEl);
      }
    }
    return elements;
  }
}
