import 'package:xml/xml.dart';

import '../../sdk.dart';

class EmptyNode extends DocxTreeNode<void> with IgnorableMixin {
  EmptyNode() : super(child: null);

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  DocxTreeNode<dynamic> get copy => throw UnimplementedError();

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return null;
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return null;
  }

  @override
  bool shouldIgnore() => true;
}
