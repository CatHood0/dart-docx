import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

const String prologue =
    'The night was quiet. Not the gentle quiet of a peaceful evening, '
    'but the profound silence that comes before a storm.\n'
    'The town slept under a pale moon, its silver light casting long shadows '
    'that seemed to whisper secrets to the cobblestones.';

const String chapter1Part1 =
    'He walked without thinking, letting the worn cobblestones guide his steps '
    'toward the harbor.\n'
    'Each footfall echoed in the emptiness, a lonely rhythm that matched the '
    'beating of his own heart.';

const String chapter1Part2 =
    'The air carried the scent of salt and decay—the perfume of a port town '
    'that had seen better days.\n'
    "Somewhere in the distance, a ship's bell tolled, marking the passage "
    'of time he could no longer measure.';

const String chapter1Part3 = 'Memories surfaced like ghosts in the fog.\n'
    'Her laughter, once bright as morning, now sounded distant and faded, '
    'a melody from another life.\n'
    'He wondered if she ever thought of him on nights like this, or if he '
    'had become just another ghost in her past.';

const String chapter2Part1 =
    'He stepped into the mist, and everything changed.\n'
    'The familiar buildings melted into shapeless forms, the streetlamps '
    'became mere suggestions of light.\n'
    'The world narrowed to the few feet he could see ahead, and the sound '
    'of his own breathing grew loud in his ears.';

const String chapter2Part2 =
    'A figure moved in the periphery—a shadow among shadows.\n'
    'Was it real, or just a trick of the mind, born from too many sleepless '
    'nights and too much regret?\n'
    'He quickened his pace, the cobblestones slick beneath his feet.';

const String chapter3Part1 =
    'A faint light shimmered in the distance, a beacon in the thick fog.\n'
    'It called to him, a silent promise of answers or perhaps, new questions.\n'
    'The light pulsed rhythmically, like a heartbeat made visible, drawing '
    'him forward with an almost magnetic pull.';

const String chapter3Part2 =
    'As he drew closer, the light resolved into the glow of a single lantern '
    'hanging from a weathered dock post.\n'
    'Beneath it stood an old man, his face lined with years and secrets.\n'
    '"You\'re late," the man said, his voice like gravel underfoot.\n'
    '"But then, you always were."';

const String epilogue =
    'The first rays of dawn began to pierce the fog, painting the sky in '
    'shades of rose and gold.\n'
    "The night's mysteries remained, but with the light came a fragile hope.\n"
    'Some journeys end; others simply change direction.\n'
    'He turned toward the rising sun and began to walk again.';

Future<void> main() async {
  final File outFile = File('test_resources/novel.docx');

  final DocxDocument document = DocxDocument(
    options: DocumentOptions(
      title: 'Whispers in the Fog',
      author: 'Midnight Writer',
      revisions: 0,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      lastModifiedBy: 'Me',
      editorSettings: EditorOptions(
        fontFamily: 'Arial',
        fontSize: 12.ptToHalfPoints(),
        complexScriptFontSize: 12.ptToHalfPoints(),
        //TODO:  we need to work of headers and footers
        headerType: 'default',
        footerType: 'default',
        metadata: EditorMetadata.zero(),
        showHeader: false,
        showFooter: false,
        language: DocxLanguage(
          language: LanguageCodes.englishUS,
          eastAsia: LanguageCodes.chineseCN,
          bidi: LanguageCodes.arabicSA,
        ),
        defaultOrderedListStyleType: LevelFormat.decimal.name,
        showPageNumber: false,
        showLineNumber: false,
        decodeUnicode: false,
      ),
      layoutOptions: DocumentLayout(columns: ColumnOptions()),
      description: 'A psychological thriller about memory and redemption',
      subject: 'Fiction / Thriller',
      keywords: <String>['noir', 'mystery', 'psychological', 'thriller'],
      styles: DocumentStyles.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('Title')
              .name('Title')
              .fontSize(28.ptToHalfPoints())
              .fontFamily('Georgia')
              .bold()
              .alignment(Alignment.center)
              .qFormat(true)
              .spacing(
                before: 12.ptToTwips(),
                after: 6.ptToTwips(),
              )
              .uiPriority(20)
              .build(),
          StyleBuilder.paragraph('Subtitle')
              .name('Subtitle')
              .fontSize(14.ptToHalfPoints())
              .fontFamily('Georgia')
              .italic()
              .runColor(Color(0x666666))
              .alignment(Alignment.center)
              .qFormat(true)
              .spacing(before: 60, after: 300)
              .uiPriority(19)
              .build(),
          StyleBuilder.paragraph('Chapter')
              .name('Chapter')
              .fontSize(20.ptToHalfPoints())
              .fontFamily('Georgia')
              .bold()
              .smallCaps()
              .alignment(Alignment.center)
              .qFormat(true)
              .spacing(before: 240, after: 120)
              .uiPriority(18)
              .basedOn('Normal')
              .next('BodyText')
              .build(),
          StyleBuilder.paragraph('BodyText')
              .name('Body Text')
              .fontSize(13.ptToHalfPoints())
              .fontFamily('Times New Roman')
              .alignment(Alignment.left)
              .qFormat(true)
              .spacing(line: 276)
              .indent(firstLine: 360)
              .uiPriority(10)
              .basedOn('Normal')
              .build(),
          StyleBuilder.paragraph('Quote')
              .name('Quote')
              .fontSize(12.ptToHalfPoints())
              .fontFamily('Times New Roman')
              .italic()
              .runColor(Color(0x444444))
              .alignment(Alignment.left)
              .qFormat(true)
              .indent(left: 360, right: 360)
              .spacing(before: 120, after: 120, line: 240)
              .uiPriority(15)
              .basedOn('Normal')
              .build(),
          StyleBuilder.paragraph('Epilogue')
              .name('Epilogue')
              .fontSize(12.ptToHalfPoints())
              .fontFamily('Times New Roman')
              .italic()
              .alignment(Alignment.left)
              .qFormat(true)
              .spacing(before: 240, after: 240, line: 240)
              .uiPriority(17)
              .basedOn('Normal')
              .build(),
        ],
      ),
      settings: SettingsOptions.base(
        defaultTabStop: 0.5.inchesToTwips().toString(),
        zoomPercent: '100',
        trackRevisions: false,
        autoHyphenation: false,
      ),
    ),
    root: DocxRoot(
      sections: <DocxNode<dynamic>>[
        Paragraph(
          children: <RunBase<dynamic>>[
            ...Run.lineBreak().repeat(10).cast(),
            TextRun(
              textPart: TextPart(
                text: 'WHISPERS IN THE FOG',
                styles: <Object>[
                  BoldAttribute(),
                  StyleBuilder.uc().smallCaps().build(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.ref('Title'),
          ],
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            ...Run.lineBreak().repeat(2).cast(),
            TextRun(
              textPart: TextPart(
                text: 'A Novel of Memory and Redemption',
              ),
            ),
          ],
          styles: <Style>[
            Style.ref('Subtitle'),
          ],
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            ...Run.lineBreak().repeat(2).cast(),
            TextRun(
              textPart: TextPart(
                text: 'by',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.ref('Subtitle'),
          ],
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            Run.lineBreak(),
            TextRun(
              textPart: TextPart(
                text: 'Alexander Gray',
                styles: <Object>[
                  BoldAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.ref('Subtitle'),
          ],
          pageBreak: ParagraphPageBreak.after,
        ),

        // Prólogo
        Paragraph.text(text: 'PROLOGUE', level: 1),

        Paragraph(
          children: _textWithBreaks(prologue),
          styles: <Style>[
            Style.ref('BodyText'),
          ],
          pageBreak: ParagraphPageBreak.after,
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            TextRun(
              textPart: TextPart(text: 'CHAPTER I'),
            ),
            Run.lineBreak(),
            TextRun(
              textPart: TextPart(
                text: 'The Harbor Walk',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.ref('Chapter'),
          ],
        ),

        Paragraph(
          children: _textWithBreaks(chapter1Part1),
          styles: <Style>[
            Style.ref('BodyText'),
          ],
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            TextRun(
              textPart: TextPart(
                text: '"Sometimes the past doesn\'t stay buried. '
                    'Sometimes it walks beside you."',
              ),
            ),
          ],
          styles: <Style>[
            Style.ref('Quote'),
          ],
        ),

        Paragraph(
          children: _textWithBreaks(chapter1Part2),
          styles: <Style>[
            Style.ref('BodyText'),
          ],
        ),

        Paragraph(
          children: _textWithBreaks(chapter1Part3),
          styles: <Style>[
            Style.ref('BodyText'),
          ],
          pageBreak: ParagraphPageBreak.after,
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            TextRun(
              textPart: TextPart(text: 'CHAPTER II'),
            ),
            Run.lineBreak(),
            TextRun(
              textPart: TextPart(
                text: 'Shadows in the Mist',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.ref('Chapter'),
          ],
        ),

        Paragraph(
          children: _textWithBreaks(chapter2Part1),
          styles: <Style>[
            Style.ref('BodyText'),
          ],
        ),

        Paragraph(
          children: _textWithBreaks(chapter2Part2),
          styles: <Style>[
            Style.ref('BodyText'),
          ],
          pageBreak: ParagraphPageBreak.after,
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            TextRun(
              textPart: TextPart(text: 'CHAPTER III'),
            ),
            Run.lineBreak(),
            TextRun(
              textPart: TextPart(
                text: 'The Lantern and the Keeper',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.ref('Chapter'),
          ],
        ),

        Paragraph(
          children: _textWithBreaks(chapter3Part1),
          styles: <Style>[
            Style.ref('BodyText'),
          ],
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            TextRun(
              textPart: TextPart(
                text: '"You\'re late," the man said, '
                    'his voice like gravel underfoot.',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.ref('BodyText'),
            StyleBuilder.up().indent(left: 360).build(),
          ],
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            TextRun(
              textPart: TextPart(
                text: '"But then, you always were."',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.ref('BodyText'),
            StyleBuilder.up().indent(left: 360).build(),
          ],
        ),

        Paragraph(
          children: _textWithBreaks(chapter3Part2),
          styles: <Style>[
            Style.ref('BodyText'),
          ],
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            Run.lineBreak(),
            TextRun(
              textPart: TextPart(text: 'EPILOGUE'),
            ),
          ],
          styles: <Style>[
            Style.ref('Epilogue'),
          ],
        ),

        Paragraph(
          children: _textWithBreaks(epilogue),
          styles: <Style>[
            Style.ref('Epilogue'),
          ],
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            ...Run(
              component: Break.lineBreak(),
            ).repeat(4).cast(),
            TextRun(
              textPart: TextPart(
                text: '© 2023 Midnight Press',
                styles: <Object>[
                  FontSizeAttribute(9.ptToHalfPoints().toInt()),
                  ForegroundTextColorAttribute(Color(999999)),
                ],
              ),
            ),
            Run(component: Break.lineBreak()),
            TextRun(
              textPart: TextPart(
                text: 'All rights reserved',
                styles: <Object>[
                  FontSizeAttribute(8.ptToHalfPoints().toInt()),
                  ForegroundTextColorAttribute(Color(0x999999)),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.ref('Normal'),
          ],
          alignment: Alignment.center,
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .dynamicFontSearch(true)
      .execute(document, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Couldnt generate .docx file');
  }
}

List<RunBase<dynamic>> _textWithBreaks(String text) {
  final List<RunBase<dynamic>> runs = <RunBase<dynamic>>[];
  final List<String> parts = text.split('\n');

  for (int i = 0; i < parts.length; i++) {
    if (parts[i].isNotEmpty) {
      runs.add(TextRun.text(text: parts[i]));
    }

    // Añadir Break.lineBreak() entre partes, pero no después de la última
    if (i < parts.length - 1) {
      runs.add(Run.lineBreak(wrapInRunMark: false));
    }
  }

  return runs;
}
