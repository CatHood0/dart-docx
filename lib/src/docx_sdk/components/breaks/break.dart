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
  Break({required super.child, super.id, super.parent});

  Break.lineBreak([String? id, DocxNode? parent])
      : super(
          child: BreakType.newline,
          id: id,
          parent: parent,
        );
  Break.pageBreak([String? id, DocxNode? parent])
      : super(
          child: BreakType.page,
          id: id,
          parent: parent,
        );
  Break.columnBreak([String? id, DocxNode? parent])
      : super(
          child: BreakType.column,
          id: id,
          parent: parent,
        );

  @override
  int get dataLength => 0;

  @override
  List<XmlNode> buildXml() {
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
  Break get copy => Break(child: child);


  @override
  bool canMerge(RunBase<dynamic> node) => false;

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
