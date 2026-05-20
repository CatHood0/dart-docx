import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../base/empty_node.dart';

class Run extends RunBase<DocxNode> {
  Run({
    required DocxNode component,
    this.wrapInRunMark = true,
    super.id,
    super.parent,
  }) : super(child: component) {
    length += component.length;
    child
      ..parent = this
      ..index = index
      ..depth = depth + 1;
  }

  Run.breaker({
    required Break breaker,
    this.wrapInRunMark = true,
    super.id,
    super.parent,
  }) : super(child: breaker) {
    length += breaker.length;
    breaker
      ..parent = this
      ..index = index
      ..depth = depth + 1;
  }

  factory Run.lineBreak({bool wrapInRunMark = true}) {
    return Run.breaker(breaker: Break.lineBreak(), wrapInRunMark: wrapInRunMark);
  }

  factory Run.pageBreak({bool wrapInRunMark = true}) {
    return Run.breaker(breaker: Break.pageBreak(), wrapInRunMark: wrapInRunMark);
  }

  factory Run.columnBreak({bool wrapInRunMark = true}) {
    return Run.breaker(breaker: Break.columnBreak(), wrapInRunMark: wrapInRunMark);
  }

  bool wrapInRunMark;

  @override
  bool isEmptyNode() {
    return child is EmptyNode;
  }

  @override
  RunBase cut(int offset, int offsetEnd) {
    if (child is TextRun) {
      return child.cast<TextRun>().cut(offset, offsetEnd);
    }
    if (child is HyperlinkRun) {
      return child.cast<TextRun>().cut(offset, offsetEnd);
    }

    return Run(
      component: EmptyNode(),
      id: id,
      parent: parent,
    );
  }

  @override
  (RunBase, RunBase) cutTwo(int offset, int offsetEnd) {
    if (child is TextRun) {
      return child.cast<TextRun>().cutTwo(offset, offsetEnd);
    }
    if (child is HyperlinkRun) {
      return child.cast<TextRun>().cutTwo(offset, offsetEnd);
    }

    return (
      Run(
        component: child,
        id: id,
        parent: parent,
      ),
      Run(
        component: EmptyNode(),
        id: id,
        parent: parent,
      )
    );
  }

  @override
  (RunBase, RunBase, RunBase) cutAll(int offset, int offsetEnd) {
    if (child is TextRun) {
      return child.cast<TextRun>().cutAll(offset, offsetEnd);
    }
    if (child is HyperlinkRun) {
      return child.cast<TextRun>().cutAll(offset, offsetEnd);
    }

    return (
      Run(
        component: offset > 0 ? EmptyNode() : child,
        id: id,
        parent: parent,
      ),
      Run(
        component: EmptyNode(),
        id: id,
        parent: parent,
      ),
      Run(
        component: EmptyNode(),
        id: id,
        parent: parent,
      ),
    );
  }

  @override
  List<XmlNode> buildXml() {
    final DocxNode<dynamic> el = child;
    return wrapInRunMark
        ? <XmlNode>[
            super.runParent(
              nodes: el.buildXml(),
            ),
          ]
        : el.buildXml();
  }

  @override
  int get dataLength => length;

  @override
  Run get copy => Run(
        id: id,
        component: child.copy,
        parent: parent,
      );

  @override
  Run copyWith({
    DocxNode? child,
    String? id,
    DocxNode<dynamic>? parent,
  }) {
    return Run(
      component: child ?? this.child,
      id: id ?? this.id,
      parent: parent ?? this.parent,
    );
  }

  @override
  bool get isEmptyData => false;

  @override
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? <DocxNode<dynamic>>[this]
        : !visitChildrenIfNeeded
            ? null
            : child.visitAllElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this)
        ? this
        : !visitChildrenIfNeeded
            ? null
            : child.visitElement(
                shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded,
              );
  }

  @override
  bool shouldIgnore() {
    return child is IgnorableMixin && (child as IgnorableMixin).shouldIgnore();
  }

  //TODO: improve these methods
  @override
  String toPlainText() {
    return child is PrintableMixin ? (child as PrintableMixin).toPlainText() : '';
  }

  @override
  String toString() {
    return child.toString();
  }
}
