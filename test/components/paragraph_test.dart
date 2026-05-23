import 'package:docx/docx.dart';
import 'package:docx/src/core/extensions/cast_ext.dart';
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
    pr
      ..setAlign(Alignment.center)
      ..setStyle(Style.ref('body'))
      ..setPageBreak(ParagraphPageBreak.before);
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
                  XmlAttribute('w:val'.toName(), 'body'),
                ],
              ),
              XmlElement.tag(
                xmlAlignmentNode,
                isSelfClosing: true,
                attributes: <XmlAttribute>[
                  XmlAttribute('w:val'.toName(), 'center'),
                ],
              ),
              XmlElement.tag(
                xmlParagraphPageBreakBefore,
                isSelfClosing: true,
              ),
            ],
          ),
        ],
      ).toXmlString(),
    );
  });

  test('should replace element in the paragraph', () {
    final List<String> text = ['this', 'is', 'my', 'birthday'];
    final Iterable<TextRun> runs = text.map(
      (String e) => TextRun.text(text: e),
    );

    pr.addAll(
      [
        ...runs,
      ],
    );

    expect(pr.child.length, equals(text.length));
    expect(pr.child.last.cast<TextRun>().child.text, equals(text.last));

    final TextRun element = pr.child.elementAt(2).cast();
    pr.updateElement(
      TextRun.text(text: 'replaced'),
      index: 2,
      strict: false,
    );

    expect(
      element.dirty,
      isTrue,
      reason: 'dirty should be true when '
          'removed of the tree, but found ${element.dirty}',
    );
    expect(
      element.mounted,
      isFalse,
      reason: 'mounted should be false when '
          'removed of the tree, but found ${element.mounted}',
    );

    expect(
      pr.child.elementAt(2).cast<TextRun>().child.text,
      equals('replaced'),
    );

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
                  XmlText('this'),
                ],
              ),
            ],
          ),
          XmlElement.tag(
            'w:r',
            children: <XmlNode>[
              XmlElement.tag(
                'w:t',
                children: [
                  XmlText('is'),
                ],
              ),
            ],
          ),
          XmlElement.tag(
            'w:r',
            children: <XmlNode>[
              XmlElement.tag(
                'w:t',
                children: [
                  XmlText('replaced'),
                ],
              ),
            ],
          ),
          XmlElement.tag(
            'w:r',
            children: <XmlNode>[
              XmlElement.tag(
                'w:t',
                children: [
                  XmlText('birthday'),
                ],
              ),
            ],
          ),
        ],
      ).toXmlString(),
    );
  });

  test('should remove element in the paragraph', () {
    LoggablePhaseConfig(
      log: print,
      level: LogLevel.all,
      enabled: true,
      loggablePhases: {
        DocxPaths.contentTypesPath,
      },
    ).init();
    final List<String> text = ['this', 'is', 'my', 'birthday'];
    final Iterable<TextRun> runs = text.map(
      (String e) => TextRun.text(text: e),
    );

    pr.addAll(
      [
        ...runs,
      ],
    );

    expect(pr.child.length, equals(text.length));
    expect(pr.child.last.cast<TextRun>().child.text, equals(text.last));

    final TextRun element = pr.child.elementAt(2).cast();
    pr.remove(element);

    expect(
      element.dirty,
      isTrue,
      reason: 'dirty should be true when '
          'removed of the tree, but found ${element.dirty}',
    );
    expect(
      element.mounted,
      isFalse,
      reason: 'mounted should be false when '
          'removed of the tree, but found ${element.mounted}',
    );

    expect(
      pr.child.elementAt(2).cast<TextRun>().child.text,
      equals('replaced'),
    );

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
                  XmlText('this'),
                ],
              ),
            ],
          ),
          XmlElement.tag(
            'w:r',
            children: <XmlNode>[
              XmlElement.tag(
                'w:t',
                children: [
                  XmlText('is'),
                ],
              ),
            ],
          ),
          XmlElement.tag(
            'w:r',
            children: <XmlNode>[
              XmlElement.tag(
                'w:t',
                children: [
                  XmlText('birthday'),
                ],
              ),
            ],
          ),
        ],
      ).toXmlString(),
    );
  });
}

Paragraph genInitialParagraph() => Paragraph(
      id: 'my-paragraph-id',
      styles: <Style>[Style.ref('Normal')],
      alignment: null,
      numbering: null,
      children: <RunBase<dynamic>>[],
      pageBreak: ParagraphPageBreak.none,
    );
