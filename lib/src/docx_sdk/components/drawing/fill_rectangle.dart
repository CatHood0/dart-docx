import 'package:xml/xml.dart';
import '../../../../docx.dart';

// Represents a:fillRect
class FillRectangle extends DocxTreeNode<dynamic> {
  FillRectangle() : super(data: null);

  @override
  FillRectangle get copy => FillRectangle();

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:fillRect',
        isSelfClosing: true,
      ),
    ];
  }

  @override
  List<FillRectangle>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  FillRectangle? visitElement(
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

