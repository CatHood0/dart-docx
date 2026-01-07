import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents pic:spPr
class PictureShapeProperties extends DocxTreeNode<dynamic> {
  PictureShapeProperties({
    required this.transform2D,
    required this.presetGeometry,
  }) : super(data: null);

  final Transform2D transform2D;
  final PresetGeometry presetGeometry;

  @override
  PictureShapeProperties get copy => PictureShapeProperties(
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
          XmlElement.tag('a:noFill', isSelfClosing: true),
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
    return transform2D.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        presetGeometry.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return transform2D.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        presetGeometry.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return <XmlNode>[];
  }
}
