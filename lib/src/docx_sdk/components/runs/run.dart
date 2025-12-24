import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../mixins/ignorable_mixin.dart';

class Run extends RunBase<DocxContent> {
  Run({
    required DocxContent component,
    this.wrapInRunMark = false,
  }) : super(data: component);

  bool wrapInRunMark;

  @override
  List<XmlNode> buildXml({required DocumentContext context}) {
    return wrapInRunMark
        ? <XmlNode>[
            super.runParent(
                nodes: data.buildXml(
              context: context,
            )),
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
  List<DocxContent>? visitAllElement(
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
    bool visitChildrenIfNeeded = false,
  }) {
    return data.visitElement(
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
