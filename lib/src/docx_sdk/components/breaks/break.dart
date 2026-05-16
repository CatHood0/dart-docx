import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';

enum BreakType {
  column,
  page,
  newline,
  tab,
}

class Break extends RunBase<BreakType> {
  Break({required super.child});

  Break.lineBreak() : super(child: BreakType.newline);
  Break.pageBreak() : super(child: BreakType.page);
  Break.columnBreak() : super(child: BreakType.column);

  @override
  int get dataLength => 0;

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    return <XmlNode>[
      XmlElement.tag(
        'w:br',
        attributes: [
          if (child != BreakType.newline)
            XmlAttribute(
              'w:type'.toName(),
              child.name,
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
  Break get copy => Break(child: child);

  @override
  Break copyWith({String? id, DocxNode<BreakType>? parent, BreakType? child}) {
    return Break(child: child ?? this.child);
  }

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return null;
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
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

  @override
  RunBase<dynamic> cut(int offset, int offsetEnd) {
    return Run(component: this).cut(offset, offsetEnd);
  }

  @override
  (RunBase<dynamic>, RunBase<dynamic>, RunBase<dynamic>) cutAll(
    int offset,
    int offsetEnd,
  ) {
    return Run(component: this).cutAll(offset, offsetEnd);
  }

  @override
  (RunBase<dynamic>, RunBase<dynamic>) cutTwo(
    int offset,
    int offsetEnd,
  ) {
    return Run(component: this).cutTwo(offset, offsetEnd);
  }
}
