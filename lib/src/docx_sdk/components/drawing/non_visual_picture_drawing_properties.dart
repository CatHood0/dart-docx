import 'package:xml/xml.dart';
import '../../../../docx.dart';

// Represents pic:cNvPicPr
class NonVisualPictureDrawingProperties extends DocxTreeNode<dynamic> {
  NonVisualPictureDrawingProperties() : super(data: null);

  @override
  NonVisualPictureDrawingProperties get copy =>
      NonVisualPictureDrawingProperties();

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'pic:cNvPicPr',
        isSelfClosing: true,
      ),
    ];
  }

  @override
  List<NonVisualPictureDrawingProperties>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  NonVisualPictureDrawingProperties? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  List<XmlNode> buildXmlStyle({required DocumentContext context}) {
    return [];
  }
}

