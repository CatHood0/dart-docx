import 'package:xml/xml.dart';

import '../../../../docx.dart';
import 'break.dart';

class ColumnBreak extends ComponentContainer<void> {
  ColumnBreak()
      : super(
          data: null,
        );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      ...Paragraph(
        data: <RunBase<dynamic>>[
          Break(data: BreakType.column),
        ],
      ).buildXml(context: context),
    ];
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
