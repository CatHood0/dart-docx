import 'package:xml/xml.dart';

import '../../sdk.dart';

class Transform {
  Transform({
    required this.rotation,
    required this.flipHorizontal,
    required this.flipVertical,
  });

  final int rotation;
  final bool flipHorizontal;
  final bool flipVertical;
}

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
  List<XmlNode> buildXmlStyle({required DocumentContext context}) =>
      <XmlNode>[];

  List<DocxTreeNode<T>> repeat(
    int times, {
    DocxTreeNode<T>? Function(int index, DocxTreeNode<T> element)? overrideCopy,
  }) {
    return List<DocxTreeNode<T>>.generate(
      times,
      (int index) =>
          overrideCopy?.call(
            index,
            this,
          ) ??
          copy,
    );
  }

  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
}
