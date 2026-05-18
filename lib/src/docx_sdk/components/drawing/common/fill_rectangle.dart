import 'package:xml/xml.dart';
import '../../../../../docx.dart';

// Represents a:fillRect
class FillRectangle extends DocxNode<dynamic> {
  FillRectangle() : super(child: null);

  @override
  FillRectangle get copy => FillRectangle();

  @override
  FillRectangle copyWith({String? id, DocxNode<dynamic>? parent}) {
    return FillRectangle();
  }

  @override
  List<XmlNode> buildXml() {
    return <XmlNode>[
      XmlElement.tag(
        'a:fillRect',
        isSelfClosing: true,
      ),
    ];
  }

  @override
  List<FillRectangle>? visitAllElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  FillRectangle? visitElement(
    bool Function(DocxNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
