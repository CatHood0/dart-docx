import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';

class PageBreak extends ComponentContainer {
  PageBreak._(String type)
      : _type = type,
        super(parent: null, child: null);

  PageBreak.next()
      : _type = 'nextPage',
        super(parent: null, child: null);

  PageBreak.continuous()
      : _type = 'continuous',
        super(parent: null, child: null);

  PageBreak.even()
      : _type = 'evenPage',
        super(parent: null, child: null);

  PageBreak.odd()
      : _type = 'oddPage',
        super(parent: null, child: null);

  final String _type;

  @override
  List<XmlElement> buildXml({required BuildNodeContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        xmlParagraphNode,
        children: <XmlNode>[
          ...buildXmlStyle(context: context),
        ],
        isSelfClosing: false,
      ),
    ];
  }

  @override
  List<XmlElement> buildXmlStyle({required BuildNodeContext context}) {
    return <XmlElement>[
      XmlElement.tag(
        xmlParagraphBlockAttrsNode,
        children: <XmlNode>[
          XmlElement.tag(
            'w:sectPr',
            children: <XmlNode>[
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
  List<DocxNode<dynamic>>? visitAllElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? <DocxNode<dynamic>>[this] : null;
  }

  @override
  DocxNode<dynamic>? visitElement(
    bool Function(DocxNode<dynamic> element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    return shouldGetElement(this) ? this : null;
  }

  @override
  PageBreak copyWith({String? type, String? id, DocxNode<dynamic>? parent}) {
    return PageBreak._(type ?? _type);
  }
}
