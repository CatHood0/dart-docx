import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../mixins/ignorable_mixin.dart';

class Run extends RunBase<DocxTreeNode> {
  Run({
    required DocxTreeNode component,
    this.wrapInRunMark = true,
  }) : super(data: component) {
    data
      ..parent = this
      ..index = index
      ..depth = depth + 1;
  }

  bool wrapInRunMark;

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    return wrapInRunMark
        ? <XmlNode>[
            super.runParent(
              nodes: data.buildXml(
                context: context,
              ),
            ),
          ]
        : data.buildXml(context: context);
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }

  @override
  Run get copy => Run(component: data.copy);

  @override
  bool get isEmptyData => false;

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

  //TODO: improve these methods
  @override
  String toPlainText() {
    return data is PrintableMixin ? (data as PrintableMixin).toPlainText() : '';
  }

  @override
  String toString() {
    return data.toString();
  }
}
