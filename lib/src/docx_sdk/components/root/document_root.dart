import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../mixins/ignorable_mixin.dart';

class DocumentRoot extends DocxTreeNode<Iterable<DocxTreeNode>> {
  DocumentRoot({
    required Iterable<DocxTreeNode> sections,
    super.parent,
  })  : assert(
            parent == null,
            'root must not be in any other '
            'point than the main build of the tree'),
        super(data: sections) {
    this.index = -1;
    depth = -1;
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
  set depth(int value) {}

  @override
  set index(int value) {}

  bool get isEmpty => data.isEmpty;

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    final List<XmlNode> content = <XmlNode>[];
    for (final DocxTreeNode<dynamic> section in data) {
      if (section is IgnorableMixin &&
          (section as IgnorableMixin).shouldIgnore()) {
        continue;
      }
      context.currentContentPart = section;
      content.addAll(section.buildXml(context: context));
    }
    return content;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  DocumentRoot get copy => DocumentRoot(sections: data, parent: parent);

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (data.isEmpty) return [];
    final List<DocxTreeNode> elements = [];
    for (final DocxTreeNode element in data) {
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxTreeNode>? foundedEl = element
            .visitAllElement(
              shouldGetElement,
              visitChildrenIfNeeded: true,
            )
            ?.cast<DocxTreeNode>();
        if (foundedEl != null) {
          elements.addAll(foundedEl);
        }
      }
    }
    return elements;
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    // TODO: implement visitElement
    throw UnimplementedError();
  }
}
