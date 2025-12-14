import 'package:meta/meta.dart';
import 'package:xml/xml.dart';
import '../../exceptions/content_not_processed_exception.dart';
import '../../sdk.dart';

abstract class RunBase<T> extends DocxContent<T> with PrintableMixin {
  RunBase({
    required super.data,
    super.parent,
  });

  @override
  @mustBeOverridden
  String toString() {
    return super.toString();
  }

  bool get isLink;
  String get link;

  bool get isEmptyData;

  @protected
  XmlElement runParent({
    required List<XmlNode> nodes,
    List<XmlNode> runProperties = const [],
  }) {
    if (rId == null && isLink) {
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
    return !isLink
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
  RunBase? visitElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<RunBase>? visitAllElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <RunBase>[this] : null;
  }
}
