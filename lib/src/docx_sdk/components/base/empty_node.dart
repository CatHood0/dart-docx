import 'package:xml/xml.dart';

import '../../sdk.dart';

class EmptyNode extends DocxNode<void> with IgnorableMixin {
  EmptyNode() : super(child: null);

  @override
  List<XmlNode> buildXml({required BuildNodeContext context}) {
    return <XmlNode>[];
  }

  @override
  DocxNode<dynamic> get copy => throw UnimplementedError();

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return null;
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return null;
  }

  @override
  bool shouldIgnore() => true;

  @override
  EmptyNode copyWith({String? id, DocxNode<void>? parent}) {
    return EmptyNode();
  }
}
