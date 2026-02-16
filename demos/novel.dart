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
      creator: 'Midnight Writer',
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
              .runColor(Color.rgb(0x666666))
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
              .runColor(Color.rgb(0x444444))
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
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Paragraph(
          data: <RunBase<dynamic>>[
            ...Run(
              component: Break.lineBreak(),
            ).repeat(10).cast(),
            TextRun(
              data: TextPart(
                text: 'WHISPERS IN THE FOG',
                styles: <Object>[
                  BoldAttribute(),
                  StyleBuilder.singularC().smallCaps().build(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.reference('Title'),
          ],
        ),

        Paragraph(
          data: <RunBase<dynamic>>[
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            TextRun(
              data: TextPart(
                text: 'A Novel of Memory and Redemption',
              ),
            ),
          ],
          styles: <Style>[
            Style.reference('Subtitle'),
          ],
        ),

        Paragraph(
          data: <RunBase<dynamic>>[
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            TextRun(
              data: TextPart(
                text: 'by',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.reference('Subtitle'),
          ],
        ),

        Paragraph(
          data: <RunBase<dynamic>>[
            Run(component: Break.lineBreak()),
            TextRun(
              data: TextPart(
                text: 'Alexander Gray',
                styles: <Object>[
                  BoldAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.reference('Subtitle'),
          ],
          pageBreak: ParagraphPageBreak.after,
        ),

        // Prólogo
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(text: 'PROLOGUE'),
            ),
          ],
          styles: <Style>[
            Style.reference('Chapter'),
          ],
        ),

        Paragraph(
          data: _textWithBreaks(prologue),
          styles: <Style>[
            Style.reference('BodyText'),
          ],
          pageBreak: ParagraphPageBreak.after,
        ),

        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(text: 'CHAPTER I'),
            ),
            Run(component: Break.lineBreak()),
            TextRun(
              data: TextPart(
                text: 'The Harbor Walk',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.reference('Chapter'),
          ],
        ),

        Paragraph(
          data: _textWithBreaks(chapter1Part1),
          styles: <Style>[
            Style.reference('BodyText'),
          ],
        ),

        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(
                text: '"Sometimes the past doesn\'t stay buried. '
                    'Sometimes it walks beside you."',
              ),
            ),
          ],
          styles: <Style>[
            Style.reference('Quote'),
          ],
        ),

        Paragraph(
          data: _textWithBreaks(chapter1Part2),
          styles: <Style>[
            Style.reference('BodyText'),
          ],
        ),

        Paragraph(
          data: _textWithBreaks(chapter1Part3),
          styles: <Style>[
            Style.reference('BodyText'),
          ],
          pageBreak: ParagraphPageBreak.after,
        ),

        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(text: 'CHAPTER II'),
            ),
            Run(component: Break.lineBreak()),
            TextRun(
              data: TextPart(
                text: 'Shadows in the Mist',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.reference('Chapter'),
          ],
        ),

        Paragraph(
          data: _textWithBreaks(chapter2Part1),
          styles: <Style>[
            Style.reference('BodyText'),
          ],
        ),

        Paragraph(
          data: _textWithBreaks(chapter2Part2),
          styles: <Style>[
            Style.reference('BodyText'),
          ],
          pageBreak: ParagraphPageBreak.after,
        ),

        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(text: 'CHAPTER III'),
            ),
            Run(component: Break.lineBreak()),
            TextRun(
              data: TextPart(
                text: 'The Lantern and the Keeper',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.reference('Chapter'),
          ],
        ),

        Paragraph(
          data: _textWithBreaks(chapter3Part1),
          styles: <Style>[
            Style.reference('BodyText'),
          ],
        ),

        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(
                text: '"You\'re late," the man said, '
                    'his voice like gravel underfoot.',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.reference('BodyText'),
            StyleBuilder.singularP().indent(left: 360).build(),
          ],
        ),

        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(
                text: '"But then, you always were."',
                styles: <Object>[
                  ItalicAttribute(),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.reference('BodyText'),
            StyleBuilder.singularP().indent(left: 360).build(),
          ],
        ),

        Paragraph(
          data: _textWithBreaks(chapter3Part2),
          styles: <Style>[
            Style.reference('BodyText'),
          ],
        ),

        Paragraph(
          data: <RunBase<dynamic>>[
            Run(component: Break.lineBreak()),
            TextRun(
              data: TextPart(text: 'EPILOGUE'),
            ),
          ],
          styles: <Style>[
            Style.reference('Epilogue'),
          ],
        ),

        Paragraph(
          data: _textWithBreaks(epilogue),
          styles: <Style>[
            Style.reference('Epilogue'),
          ],
        ),

        Paragraph(
          data: <RunBase<dynamic>>[
            ...Run(
              component: Break.lineBreak(),
            ).repeat(4).cast(),
            TextRun(
              data: TextPart(
                text: '© 2023 Midnight Press',
                styles: <Object>[
                  FontSizeAttribute(9.ptToHalfPoints().toInt()),
                  ForegroundTextColorAttribute('999999'),
                ],
              ),
            ),
            Run(component: Break.lineBreak()),
            TextRun(
              data: TextPart(
                text: 'All rights reserved',
                styles: <Object>[
                  FontSizeAttribute(8.ptToHalfPoints().toInt()),
                  ForegroundTextColorAttribute('999999'),
                ],
              ),
            ),
          ],
          styles: <Style>[
            Style.reference('Normal'),
          ],
          alignment: Alignment.center,
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .dynamicFontSearch(true)
      .bytes(document, applyCustomTheme: false);

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
      runs.add(
        TextRun(
          data: TextPart(text: parts[i]),
        ),
      );
    }

    // Añadir Break.lineBreak() entre partes, pero no después de la última
    if (i < parts.length - 1) {
      runs.add(
        Run(
          wrapInRunMark: false,
          component: Break.lineBreak(),
        ),
      );
    }
  }

  return runs;
}
