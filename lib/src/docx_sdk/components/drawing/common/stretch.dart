import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../../../../core/extensions/cast_ext.dart';

// Represents a:stretch
class Stretch extends DocxNode<Iterable<DocxNode>> {
  Stretch({required super.child}) {
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
  Stretch get copy => Stretch(child: child);

  @override
  Stretch copyWith({
    Iterable<DocxNode>? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return Stretch(child: child ?? this.child)..parent = parent ?? this.parent;
  }

  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
    final List<XmlNode> children = <XmlNode>[];
    for (final DocxNode<dynamic> element in child) {
      element.init(context);
      if (element is IgnorableMixin && element.cast<IgnorableMixin>().shouldIgnore()) {
        continue;
      }
      children.addAll(element.buildXml(context: context));
    }
    return <XmlElement>[
      XmlElement.tag(
        'a:stretch',
        isSelfClosing: false,
        children: children,
      ),
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
  List<XmlNode> buildXmlStyle({required BuildNodeContext context}) {
    return [];
  }
}
