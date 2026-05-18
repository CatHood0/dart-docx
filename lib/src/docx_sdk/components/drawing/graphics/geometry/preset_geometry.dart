import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/cast_ext.dart';
import '../../shared/geometry.dart';

// Represents a:prstGeom
class PresetGeometry extends Geometry<List<DocxNode<dynamic>>> {
  PresetGeometry({
    required this.preset,
    Iterable<DocxNode<dynamic>>? data,
  }) : super(child: <DocxNode<dynamic>>[...?data]) {
    if (super.child.isEmpty) {
      super.child.addAll(<DocxNode<dynamic>>[
        AdjustValueList(values: <AdjustValue>[]),
      ]);
    }
  }

  final PresetShapeType preset;

  @override
  PresetGeometry get copy => PresetGeometry(data: child, preset: preset);

  @override
  PresetGeometry copyWith({
    Iterable<DocxNode<dynamic>>? child,
    String? id,
    DocxNode<dynamic>? parent,
    PresetShapeType? preset,
  }) {
    return PresetGeometry(
      preset: preset ?? this.preset,
      data: child ?? this.child,
    )..parent = parent ?? this.parent;
  }

  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
    final List<XmlNode> children = <XmlNode>[];
    for (final DocxNode<dynamic> element in child) {
      if (element is IgnorableMixin && element.cast<IgnorableMixin>().shouldIgnore()) {
        continue;
      }
      children.addAll(element.buildXml(context: context));
    }
    return <XmlElement>[
      XmlElement.tag(
        'a:prstGeom',
        isSelfClosing: false,
        attributes: <XmlAttribute>[
          XmlAttribute(
            XmlName.fromString('prst'),
            preset.xmlValue,
          ),
        ],
        children: children,
      ),
    ];
  }

  @override
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return <DocxNode<dynamic>>[this];
    if (!visitChildrenIfNeeded) return null;
    final List<DocxNode<dynamic>> result = <DocxNode<dynamic>>[];
    for (final DocxNode<dynamic> el in child) {
      final List<DocxNode<dynamic>>? temp = el.visitAllElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (temp != null) return result..addAll(temp);
    }
    return result.isEmpty ? null : result;
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    for (final DocxNode<dynamic> el in child) {
      final DocxNode<dynamic>? temp = el.visitElement(
        shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded,
      );
      if (temp != null) return temp;
    }
    return null;
  }

  @override
  List<XmlNode> buildXmlStyle({required BuildNodeContext context}) {
    return <XmlNode>[];
  }
}
