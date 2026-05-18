import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../../../../../docx.dart';

@experimental
class LayoutConstraints extends DocxNode<List<DocxNode>> {
  LayoutConstraints({
    required Iterable<DocxNode> children,
    this.minWidth,
    this.maxWidth,
    super.id,
    super.parent,
  }) : super(child: List.from(children)) {
    int index = 0;
    for (final DocxNode<dynamic> content in child) {
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
  List<XmlElement> buildXml() {
    return child
        .expand<XmlElement>(
          (DocxNode<dynamic> node) => node
              .ensureInitialized(
                context,
              )
              .buildXml()
              .cast(),
        )
        .toList();
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
  LayoutConstraints copyWith({
    Iterable<DocxNode>? child,
    String? id,
    DocxNode<dynamic>? parent,
    int? minWidth,
    int? maxWidth,
  }) {
    return LayoutConstraints(
      children: child ?? this.child,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final DocxNode<dynamic> element in child) {
      if (element.isEmptyNode()) continue;
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxNode? foundedEl = element.visitElement(
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
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (child.isEmpty) return <DocxNode>[];
    final List<DocxNode> elements = <DocxNode>[];
    for (final DocxNode element in child) {
      if (element.isEmptyNode()) continue;
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxNode<dynamic>>? foundedEl = element.visitAllElement(
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
