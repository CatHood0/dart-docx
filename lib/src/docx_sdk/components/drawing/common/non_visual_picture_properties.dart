import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents pic:nvPicPr
class NonVisualPictureProperties extends DocxNode<dynamic> {
  NonVisualPictureProperties({
    required this.nonVisualDrawingProperties,
    required this.nonVisualPictureDrawingProperties,
  }) : super(child: null);

  final NonVisualDrawingProperties nonVisualDrawingProperties;
  final NonVisualPictureDrawingProperties nonVisualPictureDrawingProperties;

  @override
  NonVisualPictureProperties get copy => NonVisualPictureProperties(
        nonVisualDrawingProperties: nonVisualDrawingProperties.copy,
        nonVisualPictureDrawingProperties: nonVisualPictureDrawingProperties.copy,
      );

  @override
  NonVisualPictureProperties copyWith({
    String? id,
    DocxNode<dynamic>? parent,
    NonVisualDrawingProperties? nonVisualDrawingProperties,
    NonVisualPictureDrawingProperties? nonVisualPictureDrawingProperties,
  }) {
    return NonVisualPictureProperties(
      nonVisualDrawingProperties: nonVisualDrawingProperties ?? this.nonVisualDrawingProperties,
      nonVisualPictureDrawingProperties: nonVisualPictureDrawingProperties ?? this.nonVisualPictureDrawingProperties,
    );
  }

  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
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
  List<DocxNode>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return [this];
    if (!visitChildrenIfNeeded) return null;
    return nonVisualDrawingProperties.visitAllElement(shouldGetElement, visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        nonVisualPictureDrawingProperties.visitAllElement(shouldGetElement, visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  DocxNode? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (shouldGetElement(this)) return this;
    if (!visitChildrenIfNeeded) return null;
    return nonVisualDrawingProperties.visitElement(shouldGetElement, visitChildrenIfNeeded: visitChildrenIfNeeded) ??
        nonVisualPictureDrawingProperties.visitElement(shouldGetElement, visitChildrenIfNeeded: visitChildrenIfNeeded);
  }

  @override
  List<XmlNode> buildXmlStyle({required BuildNodeContext context}) {
    return [];
  }
}
