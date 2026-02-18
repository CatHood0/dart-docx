import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';

class PageBreak extends ComponentContainer {
  PageBreak._(String type)
      : _type = type,
        super(parent: null, data: null);

  PageBreak.next()
      : _type = 'nextPage',
        super(parent: null, data: null);

  PageBreak.continuous()
      : _type = 'continuous',
        super(parent: null, data: null);

  PageBreak.even()
      : _type = 'evenPage',
        super(parent: null, data: null);

  PageBreak.odd()
      : _type = 'oddPage',
        super(parent: null, data: null);

  final String _type;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    return [
      XmlElement.tag(
        xmlParagraphNode,
        children: [
          ...buildXmlStyle(context: context),
        ],
        isSelfClosing: false,
      ),
    ];
  }

  @override
  List<XmlElement> buildXmlStyle({required DocumentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        xmlParagraphBlockAttrsNode,
        children: <XmlNode>[
          XmlElement.tag(
            'w:sectPr',
            children: [
              XmlElement.tag(
                'w:type',
                attributes: <XmlAttribute>[
                  XmlAttribute(
                    'w:val'.toName(),
                    _type,
                  ),
                ],
              ),
            ],
          ),
        ],
        isSelfClosing: false,
      ),
    ];
  }

  @override
  PageBreak get copy => PageBreak._(_type);

  @override
  List<DocxTreeNode<dynamic>>? visitAllElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? [this] : null;
  }

  @override
  DocxTreeNode<dynamic>? visitElement(
    bool Function(DocxTreeNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }
}
