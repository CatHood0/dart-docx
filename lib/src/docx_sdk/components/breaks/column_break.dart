import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';

class ColumnBreak extends DocxContent<void> {
  ColumnBreak()
      : super(
          data: null,
        );

  @override
  XmlElement buildXml({required DocumentContext context}) {
    return XmlElement.tag(
      xmlParagraphNode,
      children: [
        XmlElement.tag(
          xmlTextRunNode,
          children: [
            XmlElement.tag(
              'w:br',
              attributes: [
                XmlAttribute(
                  'w:type'.toName(),
                  'column',
                ),
              ],
              isSelfClosing: true,
            ),
          ],
          isSelfClosing: false,
        ),
      ],
      isSelfClosing: false,
    );
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }

  @override
  DocxContent<dynamic> get copy => ColumnBreak();

  @override
  List<DocxContent<dynamic>>? visitAllElement(
    bool Function(DocxContent<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return null;
  }

  @override
  DocxContent<dynamic>? visitElement(
    bool Function(DocxContent<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return null;
  }
}
