import 'package:xml/xml.dart';

import '../../sdk.dart';

abstract class DocxTreeNode<T> {
  DocxTreeNode({
    required this.data,
    this.parent,
    String? id,
  }) : id = id ?? nanoid(7);

  T data;

  int index = -1;
  int depth = -1;

  /// The xml relations id of this component
  ///
  /// Tipically is modified only when this content
  /// has a relation with .rels file
  String? rId;

  /// The internal random id of this component
  final String id;
  DocxTreeNode? parent;
  DocxTreeNode<T> get copy;
  List<XmlNode> buildXml({required DocumentContext context});
  List<XmlNode> buildXmlStyle({required DocumentContext context});

  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
}
