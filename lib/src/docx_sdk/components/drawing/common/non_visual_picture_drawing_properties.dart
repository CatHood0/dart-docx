import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents pic:cNvPicPr
class NonVisualPictureDrawingProperties extends DocxNode<dynamic> {
  NonVisualPictureDrawingProperties() : super(child: null);

  @override
  NonVisualPictureDrawingProperties get copy => NonVisualPictureDrawingProperties();

  @override
  NonVisualPictureDrawingProperties copyWith({String? id, DocxNode<dynamic>? parent}) {
    return NonVisualPictureDrawingProperties();
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'pic:cNvPicPr',
        isSelfClosing: true,
      ),
    ];
  }

  @override
  List<NonVisualPictureDrawingProperties>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  NonVisualPictureDrawingProperties? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
