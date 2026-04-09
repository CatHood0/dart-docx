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
      pr.buildXml(context: DocumentContext.test()).single.toXmlString(),
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
      pr.buildXml(context: DocumentContext.test()).single.toXmlString(),
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
  test('should replace element in the paragraph', () {});
  test('should remove element in the paragraph', () {});
}

Paragraph genInitialParagraph() => Paragraph(
      id: 'my-paragraph-id',
      children: <RunBase<dynamic>>[],
      styles: <Style>[],
      alignment: null,
      numbering: null,
      pageBreak: ParagraphPageBreak.none,
    );
