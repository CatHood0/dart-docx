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
  XmlElement buildXml({required DocxComponentContext context}) {
    return XmlElement.tag(
      xmlParagraphNode,
      children: [
        ...buildXmlStyle(context: context),
      ],
      isSelfClosing: false,
    );
  }

  @override
  List<XmlElement> buildXmlStyle({required DocxComponentContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        xmlParagraphBlockAttrsNode,
        children: <XmlNode>[
          XmlDefaults.sectPr(
            elements: [
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
  DocxContent? visitElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    return null;
  }

  @override
  List<DocxContent>? visitAllElement(
    bool Function(DocxContent element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return null;
  }
}
