import 'package:xml/xml.dart' show XmlNode;

import '../../../../docx.dart';

typedef BuildNodeCallback<T> = T Function(String);

class Builder<T extends DocxNode> extends DocxNode<BuildNodeCallback<T>> {
  Builder({
    required BuildNodeCallback<T> builder,
    super.parent,
    super.id,
  }) : super(child: builder);

  T? _element;

  T build() {
    return child(id);
  }

  @override
  void perform() {
    super.perform();

    if (mounted && _element == null) {
      _element = build()..parent = parent;
    }
  }

  @override
  List<XmlNode> buildXml() {
    return _element!.buildXml();
  }

  @override
  Builder<T> get copy => Builder<T>(
        id: id,
        builder: child,
        parent: parent,
      );

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return _element!.visitAllElement(shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return _element!.visitElement(shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  Builder<T> copyWith({
    BuildNodeCallback<T>? builder,
    String? id,
    DocxNode? parent,
  }) {
    return Builder(
      builder: builder ?? child,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }
}
