import 'package:docx/docx.dart';
import 'package:docx/src/core/extensions/string_ext.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  Paragraph pr = genInitialParagraph();

  setUp(() {
    pr = genInitialParagraph();
  });

  test('should init a paragraph a build expected xml', () {
    expect(
      pr.buildXml().single.toXmlString(),
      XmlElement.tag(
        'w:p',
        isSelfClosing: false,
        children: <XmlNode>[
          XmlElement.tag(
            'w:pPr',
            children: <XmlNode>[
              XmlElement.tag('w:pStyle',
                  isSelfClosing: true,
                  attributes: <XmlAttribute>[
                    XmlAttribute('w:val'.toName(), 'Normal'),
                  ])
            ],
          ),
        ],
      ).toXmlString(),
    );
  });
  test('should add element to the paragraph', () {
    expect(
      pr.buildXml().single.toXmlString(),
      XmlElement.tag(
        'w:p',
        isSelfClosing: false,
        children: <XmlNode>[
          XmlElement.tag(
            'w:pPr',
            children: <XmlNode>[
              XmlElement.tag(
                'w:pStyle',
                isSelfClosing: true,
                attributes: <XmlAttribute>[
                  XmlAttribute('w:val'.toName(), 'Normal'),
                ],
              )
            ],
          ),
        ],
      ).toXmlString(),
    );

    const String text = 'This is my first element';
    pr.addRun(text.textRun(id: 'element-1'));

    expect(pr.child.length, equals(1));
    expect(pr.child.last.id, equals('element-1'));

    expect(
      pr.buildXml().single.toXmlString(),
      XmlElement.tag(
        'w:p',
        isSelfClosing: false,
        children: <XmlNode>[
          XmlElement.tag(
            'w:pPr',
            children: <XmlNode>[
              XmlElement.tag(
                'w:pStyle',
                isSelfClosing: true,
                attributes: <XmlAttribute>[
                  XmlAttribute('w:val'.toName(), 'Normal'),
                ],
              )
            ],
          ),
          XmlElement.tag(
            'w:r',
            children: <XmlNode>[
              XmlElement.tag(
                'w:t',
                children: [
                  XmlText(text),
                ],
              ),
            ],
          ),
        ],
      ).toXmlString(),
    );
  });

  test('apply styles', () {
    pr.setAlign(Alignment.center);
    expect(
      pr.buildXml().single.toXmlString(),
      XmlElement.tag(
        'w:p',
        isSelfClosing: false,
        children: <XmlNode>[
          XmlElement.tag(
            'w:pPr',
            children: <XmlNode>[
              XmlElement.tag(
                'w:pStyle',
                isSelfClosing: true,
                attributes: <XmlAttribute>[
                  XmlAttribute('w:val'.toName(), 'Normal'),
                ],
              ),
              XmlElement.tag(
                xmlAlignmentNode,
                isSelfClosing: true,
                attributes: <XmlAttribute>[
                  XmlAttribute('w:val'.toName(), 'center'),
                ],
              ),
            ],
          ),
        ],
      ).toXmlString(),
    );
  });

  test('should replace element in the paragraph', () {});
  test('should remove element in the paragraph', () {});
}

Paragraph genInitialParagraph() => Paragraph(
      id: 'my-paragraph-id',
      styles: <Style>[Style.ref('Normal')],
      alignment: null,
      numbering: null,
      children: <RunBase<dynamic>>[],
      pageBreak: ParagraphPageBreak.none,
    );
