import 'package:xml/xml.dart';
import '../../../../docx.dart';
import 'non_visual_drawing_properties.dart';
import 'non_visual_picture_drawing_properties.dart';

// Represents pic:nvPicPr
class NonVisualPictureProperties extends DocxTreeNode<dynamic> {
  NonVisualPictureProperties({
    required this.nonVisualDrawingProperties,
    required this.nonVisualPictureDrawingProperties,
  }) : super(data: null);

  final NonVisualDrawingProperties nonVisualDrawingProperties;
  final NonVisualPictureDrawingProperties nonVisualPictureDrawingProperties;

  @override
  NonVisualPictureProperties get copy => NonVisualPictureProperties(
        nonVisualDrawingProperties: nonVisualDrawingProperties.copy,
        nonVisualPictureDrawingProperties:
            nonVisualPictureDrawingProperties.copy,
      );

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'pic:nvPicPr',
        isSelfClosing: false,
        children: [
          ...nonVisualDrawingProperties.buildXml(context: context),
          ...nonVisualPictureDrawingProperties.buildXml(context: context),
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
    return nonVisualDrawingProperties.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        nonVisualPictureDrawingProperties.visitAllElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return nonVisualDrawingProperties.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        nonVisualPictureDrawingProperties.visitElement(shouldGetElement,
            visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}
