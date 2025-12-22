import 'package:xml/xml.dart' show XmlElement;

import '../../../../docx.dart';

class XmlBodyComponent extends XmlComponentBase<DocxDocument> {
  XmlBodyComponent({required DocxDocument document})
      : super(
          value: document,
          xmlKey: 'w:body',
        );

  @override
  XmlElement buildXml(DocumentContext context) {
    return XmlElement.tag(
      xmlKey,
      children: [
        ...value.buildXml(context: context),
      ],
    );
  }
}
