import 'package:xml/xml.dart';

import '../../sdk.dart';

abstract class DocxContent<T> {
  DocxContent({
    required this.data,
    this.parent,
  }) : id = nanoid(7);

  final T data;

  /// The xml relations id of this component
  String? rId;

  /// The internal random id of this component
  final String id;
  ComponentContainer? parent;
  DocxContent<T> get copy;
  XmlNode buildXml({required DocumentContext context});
  List<XmlNode> buildXmlStyle({required DocumentContext context});
  DocxContent? visitElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
  List<DocxContent>? visitAllElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
}
