import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/cast_ext.dart';
import '../../shared/geometry.dart';

// Represents a:prstGeom
class PresetGeometry extends Geometry<List<DocxTreeNode<dynamic>>> {
  PresetGeometry({
    required this.preset,
    Iterable<DocxTreeNode<dynamic>>? data,
  }) : super(data: <DocxTreeNode<dynamic>>[...?data]) {
    if (super.data.isEmpty) {
      super.data.addAll(<DocxTreeNode<dynamic>>[
        AdjustValueList(values: <AdjustValue>[]),
      ]);
    }
  }

  final PresetShapeType preset;

  @override
  PresetGeometry get copy => PresetGeometry(data: data, preset: preset);

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
    return <XmlElement>[
      XmlElement.tag(
        'a:prstGeom',
        isSelfClosing: false,
        attributes: <XmlAttribute>[
          XmlAttribute(XmlName.fromString('prst'), preset.name),
        ],
        children: children,
      ),
    ];
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxTreeNode<dynamic>>[this];
    if (!visitChildrenIfNeeded) return null;
    final List<DocxTreeNode<dynamic>> result = <DocxTreeNode<dynamic>>[];
    for (final DocxTreeNode<dynamic> el in data) {
      final List<DocxTreeNode<dynamic>>? temp = el.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (temp != null) return result..addAll(temp);
    }
    return result.isEmpty ? null : result;
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    for (final DocxTreeNode<dynamic> el in data) {
      final DocxTreeNode<dynamic>? temp = el.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (temp != null) return temp;
    }
    return null;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }
}
