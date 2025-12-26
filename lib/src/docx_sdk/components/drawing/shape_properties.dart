import 'package:xml/xml.dart';
import '../../../../docx.dart';
import 'preset_geometry.dart';
import 'transform2d.dart';

// Represents pic:spPr
class ShapeProperties extends DocxTreeNode<dynamic> {
  ShapeProperties({
    required this.transform2D,
    required this.presetGeometry,
  }) : super(data: null);

  final Transform2D transform2D;
  final PresetGeometry presetGeometry;

  @override
  ShapeProperties get copy => ShapeProperties(
        transform2D: transform2D.copy,
        presetGeometry: presetGeometry.copy,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'pic:spPr',
        isSelfClosing: false,
        children: [
          ...transform2D.buildXml(context: context),
          ...presetGeometry.buildXml(context: context),
        ],
      ),
    ];
  }

  @override
  List<ShapeProperties>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    if (!visitChildrenIfNeeded) return null;
    return transform2D.visitAllElement(shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded)
            as List<ShapeProperties>? ??
        presetGeometry.visitAllElement(shouldGetElement,
                visitChildrenIfNeeded: visitChildrenIfNeeded)
            as List<ShapeProperties>?;
  }

  @override
  ShapeProperties? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return transform2D.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) as ShapeProperties? ??
        presetGeometry.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) as ShapeProperties?;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }
}
