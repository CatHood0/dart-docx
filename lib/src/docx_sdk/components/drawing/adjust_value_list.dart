import 'package:xml/xml.dart';
import '../../../../docx.dart';

// Represents a:avLst
class AdjustValueList extends DocxTreeNode<dynamic> {
  AdjustValueList() : super(data: null);

  @override
  AdjustValueList get copy => AdjustValueList();

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        'a:avLst',
        isSelfClosing: true,
      ),
    ];
  }

  @override
  List<AdjustValueList>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  AdjustValueList? visitElement(
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

