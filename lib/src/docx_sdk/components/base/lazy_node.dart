import 'package:xml/xml.dart' show XmlNode;

import '../../../../docx.dart';

class LazyNode<T extends DocxTreeNode>
    extends DocxTreeNode<T Function(DocumentContext, String)> {
  LazyNode({
    required super.child,
    super.parent,
    super.id,
  });

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    final T value = child(context, id);
    return value.buildXml(context: context);
  }

  @override
  LazyNode<T> get copy => LazyNode<T>(
        child: child,
        parent: parent,
        id: id,
      );

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return <DocxTreeNode<dynamic>>[];
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return null;
  }
}
