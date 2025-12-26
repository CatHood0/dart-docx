import 'package:meta/meta.dart';
import 'package:xml/xml.dart';
import '../../exceptions/content_not_processed_exception.dart';
import '../../mixins/ignorable_mixin.dart';
import '../../sdk.dart';

abstract class RunBase<T> extends DocxTreeNode<T>
    with PrintableMixin, IgnorableMixin {
  RunBase({
    required super.data,
    super.parent,
    super.id,
  });

  @override
  @mustBeOverridden
  String toString() {
    return super.toString();
  }

  bool get isEmptyData;

  @protected
  XmlElement runParent({
    required List<XmlNode> nodes,
    List<XmlNode> runProperties = const [],
  }) {
    if (rId == null && this is HyperlinkRun) {
      throw ContentNotProcessedException(content: this);
    }
    final List<XmlNode> runChildren = [];

    if (runProperties.isNotEmpty) {
      runChildren.add(
        XmlElement.tag(
          xmlParagraphInlineAttsrNode,
          children: runProperties,
          isSelfClosing: false,
        ),
      );
    }

    runChildren.addAll(nodes);

    final XmlElement run = XmlElement.tag(
      xmlTextRunNode,
      children: runChildren,
      isSelfClosing: false,
    );
    return this is! HyperlinkRun
        ? run
        : XmlElement.tag(
            xmlHyperlinkNode,
            attributes: <XmlAttribute>[
              XmlAttribute(
                XmlName.fromString('r:id'),
                rId!,
              ),
            ],
            children: <XmlNode>[run],
            isSelfClosing: false,
          );
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <RunBase>[this] : null;
  }
}
