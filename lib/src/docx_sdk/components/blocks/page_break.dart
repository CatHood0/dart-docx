import 'package:xml/xml.dart';

import '../../../../docx.dart';
import '../../../core/extensions/string_ext.dart';

class PageBreak extends ComponentContainer {
  PageBreak(this.type, [String? id, DocxNode? parent])
      : super(
          parent: parent,
          id: id,
          child: null,
        );

  PageBreak.next([String? id, DocxNode? parent])
      : type = 'nextPage',
        super(parent: parent, id: id, child: null);

  PageBreak.continuous([String? id, DocxNode? parent])
      : type = 'continuous',
        super(parent: parent, id: id, child: null);

  PageBreak.even([String? id, DocxNode? parent])
      : type = 'evenPage',
        super(parent: parent, id: id, child: null);

  PageBreak.odd([String? id, DocxNode? parent])
      : type = 'oddPage',
        super(parent: parent, id: id, child: null);

  final String type;

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
                    type,
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
  PageBreak get copy => PageBreak(type);

  @override
  PageBreak copyWith({String? type, String? id, DocxNode<dynamic>? parent}) {
    return PageBreak(
      type ?? this.type,
      id ?? this.id,
      parent ?? this.parent,
    );
  }

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
}
