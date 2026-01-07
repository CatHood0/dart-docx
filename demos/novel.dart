// filepath: demos/novel.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

const String chapter1 =
    'The night was quiet. The town slept under a pale moon, '
    'and only the old clock tower dared to count the hours. ';
const String chapter1More =
    'He walked without thinking, letting the cobblestones '
    'guide his steps toward the harbor.';

/// Mini-novel demo that generates a short story as a .docx file.
Future<void> main() async {
  Directory('demos_output').createSync(recursive: true);
  final File outFile = File('test_resources/mini_novel.docx');

  final DocxDocument document = DocxDocument(
    options: DocumentOptions.blank(
      title: 'A Short Walk at Midnight',
      styles: DocumentStylesSheet.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('Title')
              .names(<String, dynamic>{
                'Title': LanguageCodes.englishUS,
              })
              .fontSize(25.toHalfPointsFromPoints())
              .bold()
              .alignment(Alignment.center)
              .qFormat(true)
              .basedOn('Normal')
              .next('Normal')
              .build(),
          StyleBuilder.paragraph('Author')
              .names(<String, dynamic>{
                'Author': LanguageCodes.englishUS,
              })
              .fontSize(12.toHalfPointsFromPoints())
              .qFormat(true)
              .italic()
              .alignment(Alignment.center)
              .build(),
          StyleBuilder.paragraph('Chapter')
              .names(<String, dynamic>{
                'Chapter': LanguageCodes.englishUS,
              })
              .fontSize(18.toHalfPointsFromPoints())
              .uiPriority(15)
              .qFormat(true)
              .alignment(Alignment.center)
              .bold()
              .underline()
              .basedOn('Normal')
              .next('Normal')
              .spacing(
                after: 30.toTwipsFromPoints(),
              )
              .build(),
        ],
      ),
    ),
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Paragraph(
          data: <RunBase<dynamic>>[
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            Run(component: Break.lineBreak()),
            TextRun(
              data: TextPart(
                text: 'A Short Walk at Midnight',
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
            TextRun(
              data: TextPart(
                text: 'by Anonymous',
              ),
            ),
          ],
          pageBreak: ParagraphPagebreak.after,
          styles: <Style>[
            Style.reference('Author'),
          ],
        ),
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(text: 'Chapter I'),
            ),
          ],
          styles: <Style>[
            Style.reference('Chapter'),
            StyleBuilder.singularP()
                .spacing(after: 200.toTwipsFromPoints())
                .build(),
          ],
        ),
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(
                text: chapter1,
              ),
            ),
            Run(
              wrapInRunMark: false,
              component: Break.lineBreak(),
            ),
            TextRun(
              data: TextPart(
                text: chapter1More,
              ),
            ),
          ],
          styles: <Style>[],
          pageBreak: ParagraphPagebreak.after,
        ),
        // Short second chapter
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(text: 'Chapter II'),
            ),
          ],
          styles: <Style>[
            Style.reference('Chapter'),
          ],
        ),
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(
                text: 'He stepped into the '
                    'mist, and everything changed.',
              ),
            ),
          ],
          pageBreak: ParagraphPagebreak.after,
        ),
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(text: 'Chapter III'),
            ),
          ],
          styles: <Style>[
            Style.reference('Chapter'),
          ],
        ),
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(
                text:
                    'A faint light shimmered in the distance, a beacon in the '
                    'thick fog. It called to him, a silent promise of answers '
                    'or perhaps, new questions.',
              ),
            ),
          ],
          pageBreak: ParagraphPagebreak.after,
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxMetadataPacker()
      .dynamicFontSearch(true)
      .logPath(DocxPaths.settingsXmlFilePath)
      .bytes(document, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate mini-novel .docx');
  }
}
