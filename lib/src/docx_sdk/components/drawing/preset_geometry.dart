import 'package:xml/xml.dart';
import '../../../../docx.dart';
import 'adjust_value_list.dart';

// Represents a:prstGeom
class PresetGeometry extends DocxTreeNode<AdjustValueList> {
  PresetGeometry({required super.data, required this.preset});

  final String preset; // e.g., 'rect'

  @override
  PresetGeometry get copy => PresetGeometry(data: data.copy, preset: preset);

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:prstGeom',
        isSelfClosing: false,
        attributes: [
          XmlAttribute(XmlName.fromString('prst'), preset),
        ],
        children: data.buildXml(context: context),
      ),
    ];
  }

  @override
  List<PresetGeometry>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    if (!visitChildrenIfNeeded) return null;
    return data.visitAllElement(shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded) as List<PresetGeometry>?;
  }

  @override
  PresetGeometry? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return data.visitElement(shouldGetElement,
        visitChildrenIfNeeded: visitChildrenIfNeeded) as PresetGeometry?;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}

