import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../mixins/ignorable_mixin.dart';

// Represents a:stretch
class Stretch extends DocxTreeNode<Iterable<DocxTreeNode>> {
  Stretch({required super.data}) {
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
  Stretch get copy => Stretch(data: data);

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
        'a:stretch',
        isSelfClosing: false,
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
