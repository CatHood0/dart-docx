import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../../../docx.dart';

@experimental
class LayoutConstraints extends DocxTreeNode<List<DocxTreeNode>> {
  LayoutConstraints({
    required Iterable<DocxTreeNode> children,
    this.minWidth,
    this.maxWidth,
    super.id,
    super.parent,
  }) : super(child: List.from(children)) {
    int index = 0;
    for (final DocxTreeNode<dynamic> content in child) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  /// The max width of the box in DXA units
  final int? maxWidth;

  /// The min height of the box in DXA units
  final int? minWidth;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return child
        .expand<XmlElement>(
          (DocxTreeNode<dynamic> node) => node
              .buildXml(
                context: context,
              )
              .cast(),
        )
        .toList();
  }

  @override
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    return <XmlElement>[];
  }

  @override
  LayoutConstraints get copy => LayoutConstraints(
        id: id,
        maxWidth: maxWidth,
        minWidth: minWidth,
        children: child,
        parent: parent,
      );

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final DocxTreeNode<dynamic> element in child) {
      if (element.isEmptyNode()) continue;
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxTreeNode? foundedEl = element.visitElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          return foundedEl;
        }
      }
    }
    return null;
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (child.isEmpty) return <DocxTreeNode>[];
    final List<DocxTreeNode> elements = <DocxTreeNode>[];
    for (final DocxTreeNode element in child) {
      if (element.isEmptyNode()) continue;
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxTreeNode<dynamic>>? foundedEl = element.visitAllElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          elements.addAll(foundedEl);
        }
      }
    }
    return elements;
  }
}
