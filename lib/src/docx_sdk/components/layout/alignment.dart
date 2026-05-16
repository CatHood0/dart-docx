import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';

class Align extends DocxNode<DocxNode> {
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
  Align copyWith({
    DocxNode? child,
    String? id,
    DocxNode<dynamic>? parent,
    Alignment? alignment,
  }) {
    return Align(
      alignment: alignment ?? this.alignment,
      child: child ?? this.child,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    if (shouldGetElement(child)) {
      return child;
    } else if (visitChildrenIfNeeded) {
      final DocxNode? foundedEl = child.visitElement(
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
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (child.isEmptyNode() || child.castOrNull<IgnorableMixin>()?.shouldIgnore() == true) {
      return <DocxNode>[];
    }
    final List<DocxNode> elements = <DocxNode>[];
    if (shouldGetElement(child)) {
      elements.add(child);
    } else if (visitChildrenIfNeeded) {
      final List<DocxNode<dynamic>>? foundedEl = child.visitAllElement(
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
