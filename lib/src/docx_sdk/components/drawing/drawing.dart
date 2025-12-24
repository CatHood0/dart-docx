import 'package:xml/xml.dart';

import '../../../../docx.dart';

class Drawing extends DocxContent<DocxContent> {
  Drawing({required super.data});

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    return <XmlNode>[
      XmlElement.tag(
        'w:drawing',
        isSelfClosing: false,
        children: [
          ...data.buildXml(context: context),
        ],
      ),
    ];
  }

  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  DocxContent<DocxContent<dynamic>> get copy => Drawing(data: data.copy);

  @override
  List<DocxContent<dynamic>>? visitAllElement(
    bool Function(DocxContent<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return data.visitAllElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }

  @override
  DocxContent<dynamic>? visitElement(
    bool Function(DocxContent<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return data.visitElement(
      shouldGetElement,
      visitChildrenIfNeeded: visitChildrenIfNeeded,
    );
  }
}
