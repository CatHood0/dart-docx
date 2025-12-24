import 'package:xml/xml.dart';

import '../../../core/extensions/string_ext.dart';
import '../../docx_component_context.dart';
import '../base/docx_content.dart';
import '../base/run_base.dart';

enum BreakType {
  column,
  page,
  newline,
}

class Break extends RunBase<BreakType> {
  Break({required super.data});

  Break.lineBreak() : super(data: BreakType.newline);
  Break.pageBreak() : super(data: BreakType.page);
  Break.columnBreak() : super(data: BreakType.column);

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    return <XmlNode>[
      XmlElement.tag(
        'w:br',
        attributes: [
          if (data != BreakType.newline)
            XmlAttribute(
              'w:type'.toName(),
              data.name,
            ),
        ],
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  Break get copy => Break(data: data);

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

  @override
  bool get isEmptyData => false;

  @override
  bool shouldIgnore() {
    return false;
  }

  @override
  String toPlainText() {
    return '';
  }

  @override
  String toString() {
    return toPlainText();
  }
}
