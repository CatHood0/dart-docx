import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../mixins/ignorable_mixin.dart';

//TODO: we need to make possible skipping componentes like this
// when compatibility mode is not true
// since mc:Choice is the modern solution used instead w:drawing
class Drawing extends DocxTreeNode<DocxTreeNode> with IgnorableMixin {
  Drawing({
    required super.data,
    super.id,
  }) {
    data
      ..parent = this
      ..index = 0
      ..depth = depth + 1;
  }

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'w:drawing',
        isSelfClosing: false,
        children: [
          ...data.buildXml(context: context),
        ],
      ),
    ];
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }

  @override
  DocxTreeNode<DocxTreeNode<dynamic>> get copy => Drawing(
        data: data.copy,
        id: id,
      );

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? <DocxTreeNode<dynamic>>[this]
        : !visitChildrenIfNeeded
            ? null
            : data.visitAllElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? this
        : !visitChildrenIfNeeded
            ? null
            : data.visitElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  bool shouldIgnore() {
    return data is IgnorableMixin && (data as IgnorableMixin).shouldIgnore();
  }
}
