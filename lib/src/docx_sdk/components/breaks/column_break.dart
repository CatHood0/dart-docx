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
  DocxTreeNode<dynamic> get copy => ColumnBreak();

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
}
