import 'package:xml/xml.dart' show XmlNode;

import '../../../../docx.dart';

typedef BuildNodeCallback<T> = T Function(DocumentContext, String);

class LazyNode<T extends DocxNode> extends DocxNode<BuildNodeCallback<T>> {
  LazyNode({
    required super.child,
    super.parent,
    super.id,
  });

  T build(DocumentContext context) => child(context, id);

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
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return <DocxNode<dynamic>>[];
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return null;
  }

  @override
  LazyNode<T> copyWith({
    BuildNodeCallback<T>? child,
    String? id,
    DocxNode? parent,
  }) {
    return LazyNode(
      child: child ?? this.child,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
