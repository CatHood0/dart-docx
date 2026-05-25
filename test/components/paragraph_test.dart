import 'package:docx/docx.dart';
import 'package:docx/src/core/extensions/cast_ext.dart';
import 'package:docx/src/core/extensions/string_ext.dart';
import 'package:docx/src/docx_sdk/registry/docx_registry.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  Paragraph pr = genInitialParagraph();

  setUpAll(() {
    DocxRegistry.setDefaultRegistries();
  });

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

  test('should transform to json expected', () {
    expect(
        pr.toJson(),
        equals(<String, dynamic>{
          'id': 'my-paragraph-id',
          'children': [],
          'alignment': null,
          'pageBreak': 2,
          'numbering': null,
          'textStyle': null,
          'styles': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'my-style',
              'type': '',
              'styleId': 'Normal',
              'defaultValue': null,
              'revisionIdDefault': null,
              'revisionIdPPr': null,
              'revisionIdRun': null,
              'revisionIdRPr': null,
              'isReference': true,
              'configurators': <dynamic>[],
              '__runtimeType__': 'Style'
            }
          ],
          '__runtimeType__': 'Paragraph',
        }));
  });

  group('modifications', () {
    late Paragraph original;
    setUp(() {
      pr = genInitialParagraph();
      final List<String> text = ['this', 'is', 'my', 'birthday'];
      final Iterable<TextRun> runs = text.map(
        (String e) => TextRun.text(text: e),
      );

      pr.addAll([...runs]);

      expect(pr.child.length, equals(text.length));
      expect(pr.child.last.cast<TextRun>().child.text, equals(text.last));
      original = pr.copy;
    });

    test('should replace element in the paragraph', () {
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
      final TextRun element = pr.child[2].cast();
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
        equals('birthday'),
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

    test('should create paragraph with correct runs', () {
      expect(original.child.length, equals(4));
      expect(original.length, equals(16));
      expect(original.child[0].cast<TextRun>().child.text, equals('this'));
      expect(original.child[1].cast<TextRun>().child.text, equals('is'));
      expect(original.child[2].cast<TextRun>().child.text, equals('my'));
      expect(original.child[3].cast<TextRun>().child.text, equals('birthday'));
    });

    test('should add run at the end (modifies original)', () {
      final TextRun newRun = TextRun.text(text: ' party');
      original.addRun(newRun);

      expect(original.child.length, equals(5));
      expect(original.length, equals(22));
      expect(original.child.last.cast<TextRun>().child.text, equals(' party'));
      expect(original.child.last.start, equals(16));
      expect(original.child.last.end, equals(22));
    });

    test('should add run at the beginning (modifies original)', () {
      final TextRun newRun = TextRun.text(text: 'Happy ');
      original.addRunFirst(newRun);

      expect(original.child.length, equals(5));
      expect(original.length, equals(22));
      expect(original.child.first.cast<TextRun>().child.text, equals('Happy '));
      expect(original.child.first.start, equals(0));
      expect(original.child.first.end, equals(6));

      expect(original.child[1].start, equals(6));
      expect(original.child[1].end, equals(10));
    });

    test('should add run at specific index (modifies original)', () {
      final TextRun newRun = TextRun.text(text: ' very ');
      original.addRunAt(2, newRun);

      expect(original.child.length, equals(5));
      expect(original.length, equals(22));
      expect(original.child[2].cast<TextRun>().child.text, equals(' very '));
      expect(original.child[2].start, equals(6));
      expect(original.child[2].end, equals(12));

      expect(original.child[3].start, equals(12));
      expect(original.child[3].end, equals(14));
      expect(original.child[4].start, equals(14));
      expect(original.child[4].end, equals(22));
    });

    test('should insert text at beginning (modifies original)', () {
      original.insertText('Hello ', offset: 0);

      expect(original.length, equals(22));
      final String fullText = _getFullText(original);
      expect(fullText, startsWith('Hello '));
    });

    test('should insert text in the middle (modifies original)', () {
      String fullText = _getFullText(original);
      original.insertText(' wonderful ', offset: 4);

      expect(original.length, equals(27));
      fullText = _getFullText(original);
      expect(fullText, equals('thisis wonderful mybirthday'));
    });

    test('should cut segment from paragraph (returns new, original unchanged)',
        () {
      final Paragraph cutSegment = original.cut(1, 4);

      expect(cutSegment.length, equals(3));
      final String cutText = _getFullText(cutSegment);
      expect(cutText, equals('his'));

      expect(original.length, equals(16));
      expect(original.child.length, equals(4));
      expect(_getFullText(original), equals('thisismybirthday'));
    });

    test(
        'should remove segment from paragraph (returns new, original unchanged)',
        () {
      final Paragraph remaining = original.deleteRange(1, 4);

      expect(remaining.length, equals(13));
      final String remainingText = _getFullText(remaining);
      expect(remainingText, equals('tismybirthday'));

      expect(original.length, equals(16));
      expect(_getFullText(original), equals('thisismybirthday'));
    });

    test(
        'should remove segment crossing multiple runs (returns new, original unchanged)',
        () {
      final Paragraph remaining = original.deleteRange(4, 8);

      expect(remaining.length, equals(12),
          reason: '"${_getFullText(remaining)}"');
      final String remainingText = _getFullText(remaining);
      expect(remainingText, equals('thisbirthday'));

      expect(_getFullText(original), equals('thisismybirthday'));
    });

    test(
        'should remove segment from middle to end (returns new, original unchanged)',
        () {
      final Paragraph remaining = original.deleteRange(6, 16);

      expect(remaining.length, equals(6));
      final String remainingText = _getFullText(remaining);
      expect(remainingText, equals('thisis'));

      expect(_getFullText(original), equals('thisismybirthday'));
    });

    test(
        'should remove segment from beginning (returns new, original unchanged)',
        () {
      final Paragraph remaining = original.deleteRange(0, 4);

      expect(remaining.length, equals(12));
      final String remainingText = _getFullText(remaining);
      expect(remainingText, equals('ismybirthday'));

      expect(_getFullText(original), equals('thisismybirthday'));
    });

    test('should handle empty paragraph', () {
      final Paragraph empty = Paragraph.empty();
      expect(empty.length, equals(0));
      expect(empty.child.isEmpty, isTrue, reason: 'Found: "${empty.child}"');

      final Paragraph cut = empty.cut(0, 1);
      expect(cut.length, equals(0));
      expect(cut.child.isEmpty, isTrue);

      empty.insertText('Hello');
      expect(empty.length, equals(5));
      expect(_getFullText(empty), equals('Hello'));
    });

    test('should remove by id (modifies original)', () {
      final String targetId = original.child[1].id;
      original.removeById(targetId);

      expect(
        original.child.length,
        equals(3),
        reason: 'Found: length (${original.child.length}) = ${original.child}',
      );
      expect(original.length, equals(14));
      final String remainingText = _getFullText(original);
      expect(remainingText, equals('thismybirthday'));
    });

    test('should remove element directly (modifies original)', () {
      final RunBase target = original.child[2];
      original.remove(target);

      expect(original.child.length, equals(3));
      expect(original.length, equals(14));
      final String remainingText = _getFullText(original);
      expect(remainingText, equals('thisisbirthday'));
    });

    test('should update element (modifies original)', () {
      final RunBase oldRun = original.child[1];
      final TextRun newRun = TextRun.text(text: 'was');
      original.updateElement(
        newRun,
        index: 1,
        strict: false,
      );

      expect(original.child[1].cast<TextRun>().child.text, equals('was'));
      expect(oldRun.cast<TextRun>().child.text, equals('is'));
      expect(original.length, equals(17));
      final String fullText = _getFullText(original);
      expect(fullText, equals('thiswasmybirthday'));
    });

    test('should handle adding multiple runs (modifies original)', () {
      final List<TextRun> newRuns = [
        TextRun.text(text: ' Happy'),
        TextRun.text(text: ' New'),
        TextRun.text(text: ' Year!'),
      ];
      original.addAll(newRuns);

      expect(original.child.length, equals(7));
      expect(original.length, equals(16 + 6 + 4 + 6));
      final String fullText = _getFullText(original);
      expect(fullText, equals('thisismybirthday Happy New Year!'));
    });

    test('should maintain correct indices after multiple modifications', () {
      original
        ..insertText('Hello ', offset: 0)
        ..addRun(TextRun.text(text: ' everyone'));

      final Paragraph modified = original.deleteRange(5, 9);

      for (int i = 0; i < modified.child.length; i++) {
        final run = modified.child[i];
        expect(run.start, equals(i == 0 ? 0 : modified.child[i - 1].end));
        expect(run.end, equals(run.start + run.length));
        expect(run.index, equals(i));
        expect(run.parent, equals(modified));
      }
    });

    test('should chain deleteRange operations', () {
      final Paragraph step1 = original.deleteRange(0, 4);
      expect(_getFullText(step1), equals('ismybirthday'));

      final Paragraph step2 = step1.deleteRange(2, 4);
      expect(_getFullText(step2), equals('isbirthday'));

      final Paragraph step3 = step2.deleteRange(0, 2);
      expect(_getFullText(step3), equals('birthday'));

      expect(_getFullText(original), equals('thisismybirthday'));
    });

    test('should chain cut operations', () {
      final Paragraph cut1 = original.cut(0, 4);
      expect(_getFullText(cut1), equals('this'));

      final Paragraph cut2 = original.cut(4, 6);
      expect(_getFullText(cut2), equals('is'));

      final Paragraph cut3 = original.cut(6, 8);
      expect(_getFullText(cut3), equals('my'));

      final Paragraph cut4 = original.cut(8, 16);
      expect(_getFullText(cut4), equals('birthday'));

      expect(_getFullText(original), equals('thisismybirthday'));
    });
  });
}

// Helper function to extract full text from paragraph
String _getFullText(Paragraph paragraph) {
  final StringBuffer buffer = StringBuffer();
  for (final run in paragraph.child) {
    if (run is TextRun) {
      buffer.write(run.child.text);
    } else if (run is Run && run.child is TextRun) {
      buffer.write((run.child as TextRun).child.text);
    }
  }
  return buffer.toString();
}

Paragraph genInitialParagraph() => Paragraph(
      id: 'my-paragraph-id',
      styles: <Style>[
        Style.ref(
          'Normal',
          'my-style',
        ),
      ],
      alignment: null,
      numbering: null,
      children: <RunBase<dynamic>>[],
      pageBreak: ParagraphPageBreak.none,
    );
