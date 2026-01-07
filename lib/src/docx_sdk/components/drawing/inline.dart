import 'package:xml/xml.dart';
import '../../../../docx.dart';
import '../../../core/extensions/cast_ext.dart';
import '../../../core/extensions/string_ext.dart';
import '../../mixins/ignorable_mixin.dart';

// Represents wp:inline
class Inline extends DocxTreeNode<Iterable<DocxTreeNode>> {
  Inline({
    required Iterable<DocxTreeNode> components,
    required this.name,
    required this.width,
    required this.height,
    required this.distance,
    super.id,
  }) : super(data: components) {
    int index = 0;
    for (final DocxTreeNode<dynamic> content in data) {
      content
        ..parent = this
        ..index = index
        ..depth = depth + 1;
      index++;
    }
  }

  final TextDistance distance;

  int? elementId;
  final String name;
  final num width;
  final num height;

  @override
  Inline get copy => Inline(
        id: id,
        height: height,
        name: name,
        width: width,
        components: data,
        distance: distance,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    final List<XmlNode> children = <XmlNode>[];
    for (final DocxTreeNode<dynamic> element in data) {
      if (element is IgnorableMixin &&
          element.cast<IgnorableMixin>().shouldIgnore()) {
        continue;
      }
      context.currentContentPart = element;
      children.addAll(element.buildXml(context: context));
    }
    elementId ??= context.drawingStore.getNextId(id);
    context.currentContentPart = this;
    return <XmlElement>[
      XmlElement.tag(
        'wp:inline',
        attributes: <XmlAttribute>[
          XmlAttribute(
            'distT'.toName(),
            distance.top.toString(),
          ),
          XmlAttribute(
            'distB'.toName(),
            distance.bottom.toString(),
          ),
          XmlAttribute(
            'distL'.toName(),
            distance.left.toString(),
          ),
          XmlAttribute(
            'distR'.toName(),
            distance.right.toString(),
          ),
        ],
        isSelfClosing: children.isEmpty,
        children: <XmlNode>[
          ...Extent(
            cx: width,
            cy: height,
          ).buildXml(context: context),
          ...DocProperties(
            docPrId: elementId!.toString(),
            name: name,
            description: name,
          ).buildXml(context: context),
          ...children,
        ],
      ),
    ];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    if (!visitChildrenIfNeeded) return null;
    for (final DocxTreeNode<dynamic> el in data) {
      final List<DocxTreeNode<dynamic>>? result = el.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }
    return null;
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    for (final DocxTreeNode<dynamic> el in data) {
      final DocxTreeNode<dynamic>? result = el.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (result != null) return result;
    }
    return null;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}
