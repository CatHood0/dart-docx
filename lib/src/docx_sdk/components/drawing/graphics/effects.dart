import 'package:xml/xml.dart';
import '../../../../../docx.dart';
import '../shared/effects.dart';

/// Container for visual effects applied to a shape (a:effectLst).
///
/// Can include multiple effects like shadows, glows, reflections,
/// soft edges, and 3D effects that are rendered in sequence.
class EffectList extends Effect<Iterable<DocxNode>> {
  EffectList({
    required Iterable<DocxNode<dynamic>> children,
  }) : super(child: children) {
    int index = 0;
    for (final DocxNode<dynamic> comp in child) {
      comp
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  @override
  EffectList get copy => EffectList(
        children: child,
      );

  @override
  EffectList copyWith({
    Iterable<DocxNode>? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return EffectList(
      children: child ?? this.child,
    )..parent = parent ?? this.parent;
  }

  @override
  List<XmlNode> buildXml() {
    final List<XmlNode> effectElements = <XmlNode>[];

    for (final DocxNode<dynamic> child in child) {
      effectElements.addAll(child.buildXml());
    }

    return <XmlNode>[
      XmlElement.tag(
        'a:effectLst',
        children: effectElements,
      ),
    ];
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxNode<dynamic>>[this];

    if (!visitChildrenIfNeeded) return null;

    final List<DocxNode<dynamic>> results = <DocxNode<dynamic>>[];
    for (final DocxNode<dynamic> child in child) {
      final List<DocxNode<dynamic>>? childResult = child.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (childResult != null) results.addAll(childResult);
    }

    return results.isNotEmpty ? results : null;
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;

    if (!visitChildrenIfNeeded) return null;

    for (final DocxNode<dynamic> child in child) {
      final DocxNode<dynamic>? result = child.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }

    return null;
  }
}
