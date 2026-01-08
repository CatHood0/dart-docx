import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../shared/effects.dart';

/// Container for visual effects applied to a shape (a:effectLst).
///
/// Can include multiple effects like shadows, glows, reflections,
/// soft edges, and 3D effects that are rendered in sequence.
class EffectList extends Effect<Iterable<DocxTreeNode>> {
  EffectList({
    required Iterable<DocxTreeNode<dynamic>> children,
  }) : super(data: children) {
    int index = 0;
    for (final DocxTreeNode<dynamic> comp in data) {
      comp
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  @override
  EffectList get copy => EffectList(
        children: data,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlNode> effectElements = <XmlNode>[];

    for (final DocxTreeNode<dynamic> child in data) {
      effectElements.addAll(child.buildXml(context: context));
    }

    return <XmlElement>[
      XmlElement.tag(
        'a:effectLst',
        children: effectElements,
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxTreeNode<dynamic>>[this];

    if (!visitChildrenIfNeeded) return null;

    final List<DocxTreeNode<dynamic>> results = <DocxTreeNode<dynamic>>[];
    for (final DocxTreeNode<dynamic> child in data) {
      final List<DocxTreeNode<dynamic>>? childResult = child.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (childResult != null) results.addAll(childResult);
    }

    return results.isNotEmpty ? results : null;
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;

    if (!visitChildrenIfNeeded) return null;

    for (final DocxTreeNode<dynamic> child in data) {
      final DocxTreeNode<dynamic>? result = child.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }

    return null;
  }
}
