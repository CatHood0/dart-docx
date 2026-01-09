import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../mixins/ignorable_mixin.dart';

class DocumentRoot extends DocxTreeNode<Iterable<DocxTreeNode>> {
  DocumentRoot({
    required Iterable<DocxTreeNode> sections,
    super.parent,
    super.id,
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
      // the last column need to ignore the break
      if (content is Column && index + 1 >= sections.length) {
        // ignore: invalid_use_of_protected_member
        content.ignoreBreak = true;
      }
      index++;
    }
  }

  @override
  set depth(int value) {}

  @override
  set index(int value) {}

  void addImage() {}
  void addParagraph() {}
  void addShape() {}

  bool get isEmpty => data.isEmpty;

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    final List<XmlNode> content = <XmlNode>[];
    for (final DocxTreeNode<dynamic> section in data) {
      if (section is IgnorableMixin &&
          (section as IgnorableMixin).shouldIgnore()) {
        continue;
      }
      context.currentContentPart = this;
      content.addAll(section.buildXml(context: context));
    }

    return content;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  DocumentRoot get copy => DocumentRoot(
        id: id,
        sections: data,
        parent: parent,
      );

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxTreeNode<dynamic>>[this];
    if (!visitChildrenIfNeeded) return null;
    for (final DocxTreeNode element in data) {
      if (shouldGetElement(element)) {
        return <DocxTreeNode<dynamic>>[element];
      } else if (visitChildrenIfNeeded) {
        final List<DocxTreeNode<dynamic>>? els = element.visitAllElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (els != null) {
          return els;
        }
      }
    }
    return null;
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    for (final DocxTreeNode element in data) {
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxTreeNode<dynamic>? els = element.visitElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (els != null) {
          return els;
        }
      }
    }
    return null;
  }
}
