import 'package:meta/meta.dart';
import 'package:xml/xml.dart';
import '../../exceptions/content_not_processed_exception.dart';
import '../../sdk.dart';

abstract class RunBase<T> extends DocxNode<T>
    with PrintableMixin, IgnorableMixin {
  RunBase({
    required super.child,
    super.parent,
    super.id,
  });

  @override
  @mustBeOverridden
  String toString() {
    return super.toString();
  }

  bool canMerge(RunBase node);

  @override
  bool isEmptyNode() => this is EmptyNode || dataLength == 0;

  RunBase cut(int offset, int offsetEnd);
  (RunBase, RunBase) cutTwo(int offset, int offsetEnd);
  (RunBase, RunBase, RunBase) cutAll(int offset, int offsetEnd);

  int get dataLength;

  int start = 0;
  int end = 0;

  bool get isEmptyData;

  @protected
  XmlElement runParent({
    required List<XmlNode> nodes,
    List<XmlNode> runProperties = const <XmlNode>[],
  }) {
    if (rId == null && this is HyperlinkRun) {
      throw ContentNotProcessedException(content: this);
    }
    final List<XmlNode> runChildren = <XmlNode>[];

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
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <RunBase>[this] : null;
  }
}
