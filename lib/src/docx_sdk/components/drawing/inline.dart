import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../mixins/ignorable_mixin.dart';

// Represents wp:inline
class Inline extends DocxTreeNode<Iterable<DocxTreeNode>> {
  Inline({
    required Iterable<DocxTreeNode> components,
  }) : super(data: components) {
    int index = 0;
    for (final DocxTreeNode<dynamic> content in data) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  @override
  Inline get copy => Inline(components: data);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlNode> children = <XmlNode>[];
    for (final DocxTreeNode<dynamic> element in data) {
      if (element is IgnorableMixin &&
          element.cast<IgnorableMixin>().shouldIgnore()) {
        continue;
      }
      context.currentContentPart = element;
      children.addAll(element.buildXml(context: context));
    }
    context.currentContentPart = this;
    return <XmlElement>[
      XmlElement.tag(
        'wp:inline',
        isSelfClosing: children.isEmpty,
        children: children,
      ),
    ];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    if (!visitChildrenIfNeeded) return null;
    for (final DocxTreeNode<dynamic> el in data) {
      final List<DocxTreeNode<dynamic>>? result = el.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }
    return null;
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    for (final DocxTreeNode<dynamic> el in data) {
      final DocxTreeNode<dynamic>? result = el.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }
    return null;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}
