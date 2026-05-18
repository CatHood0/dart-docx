import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';

class PageBreak extends ComponentContainer {
  PageBreak._(String type, [String? id, DocxNode? parent])
      : _type = type,
        super(parent: parent, id: id, child: null);

  PageBreak.next([String? id, DocxNode? parent])
      : _type = 'nextPage',
        super(parent: parent, id: id, child: null);

  PageBreak.continuous([String? id, DocxNode? parent])
      : _type = 'continuous',
        super(parent: parent, id: id, child: null);

  PageBreak.even([String? id, DocxNode? parent])
      : _type = 'evenPage',
        super(parent: parent, id: id, child: null);

  PageBreak.odd([String? id, DocxNode? parent])
      : _type = 'oddPage',
        super(parent: parent, id: id, child: null);

  final String _type;

  @override
  List<XmlElement> buildXml() {
    return <XmlElement>[
      XmlElement.tag(
        xmlParagraphNode,
        children: <XmlNode>[
          ...buildXmlStyle(),
        ],
        isSelfClosing: false,
      ),
    ];
  }

  @override
  List<XmlElement> buildXmlStyle() {
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
