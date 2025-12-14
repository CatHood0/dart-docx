import 'package:xml/xml.dart';

import '../../sdk.dart';

abstract class DocxContent<T> {
  DocxContent({
    required this.data,
    this.parent,
  }) : id = nanoid(7);

  final T data;
  String? rId;
  final String id;
  ComponentContainer? parent;
  DocxContent<T> get copy;
  XmlNode buildXml({required DocxComponentContext context});
  List<XmlNode> buildXmlStyle({required DocxComponentContext context});
  DocxContent? visitElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
  List<DocxContent>? visitAllElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  });
}
