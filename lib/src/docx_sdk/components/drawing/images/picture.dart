import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';

// Represents pic:pic
class Picture extends DocxNode<Iterable<DocxNode>> {
  Picture({
    required Iterable<DocxNode> components,
  }) : super(child: components) {
    int index = 0;
    for (final DocxNode<dynamic> content in child) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  @override
  Picture get copy => Picture(components: child);

  @override
  Picture copyWith({
    Iterable<DocxNode>? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return Picture(
      components: child ?? this.child,
    )..parent = parent ?? this.parent;
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlNode> children = <XmlNode>[];
    for (final DocxNode<dynamic> element in child) {
      if (element is IgnorableMixin && element.cast<IgnorableMixin>().shouldIgnore()) {
        continue;
      }
      context.currentContentPart = element;
      children.addAll(element.buildXml(context: context));
    }
    context.currentContentPart = this;
    return <XmlElement>[
      XmlElement.tag('pic:pic', isSelfClosing: false, children: children),
    ];
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    if (!visitChildrenIfNeeded) return null;
    for (final DocxNode<dynamic> el in child) {
      final List<DocxNode<dynamic>>? result = el.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }
    return null;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    for (final DocxNode<dynamic> el in child) {
      final DocxNode<dynamic>? result = el.visitElement(
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
