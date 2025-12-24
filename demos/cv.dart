import 'dart:io';
import 'package:docx/docx.dart';

/// Simple demo that generates a minimal CV as a .docx file.
Future<void> main() async {
  final File outFile = File('test_resources/cv.docx');

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.blank(
      title: 'Curriculum - Jane Doe',
      styles: DocumentStylesSheet.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('Name')
              .fontFamily('Times New Roman')
              .fontSize(24)
              .bold()
              .alignment(Alignment.center)
              .build(),
          StyleBuilder.paragraph('SectionHeading')
              .fontSize(14)
              .bold()
              .spacing(after: 200)
              .build(),
        ],
      ),
    ),
    sections: <DocxContent<dynamic>>[
      Paragraph(
        data: <RunBase<dynamic>>[
          Run(
            component: Drawing(
              data: LazyImage(
                data: ImageData(
                  buffer: File('assets/cv_person.jpg'),
                  extension: 'jpg',
                  width: 200,
                  height: 200,
                  unit: Unit.pixels96,
                ),
              ),
            ),
          ),
          TextRun(
            data: TextPart(
              text: 'Jane Doe',
              styles: <Object>[Style.reference('Name')],
            ),
          ),
        ],
      ),
      Paragraph(
        data: <RunBase<dynamic>>[
          TextRun(
            data: TextPart(
                text: 'Email: jane.doe@example.com '
                    '• Phone: +1 234 567 890'),
          ),
        ],
      ),
      ColumnBreak(),
      Paragraph(
        data: <RunBase<dynamic>>[
          TextRun(
            data: TextPart(
              text: 'Experience',
              styles: <Object>[
                Style.reference(
                  'SectionHeading',
                ),
              ],
            ),
          ),
        ],
      ),
      Paragraph(
        data: <RunBase<dynamic>>[
          TextRun(
            data: TextPart(
              text: '• Senior Engineer at Acme '
                  'Corp (2018 - Present)',
            ),
          ),
          Break.lineBreak(),
          TextRun(
            data: TextPart(
                text: '• Software Developer at '
                    'Example Inc. (2015 - 2018)'),
          ),
        ],
      ),
      Paragraph(
        data: <RunBase<dynamic>>[
          TextRun(
            data: TextPart(
              text: 'Education',
              styles: <Object>[
                Style.reference('SectionHeading'),
              ],
            ),
          ),
        ],
      ),
      Paragraph(
        data: <RunBase<dynamic>>[
          TextRun(
            data: TextPart(
              text: 'M.Sc. Computer Science — '
                  'University of Examples (2013 - 2015)',
            ),
          ),
          Break.lineBreak(),
          TextRun(
            data: TextPart(
              text: 'B.Sc. Computer Science — '
                  'College of Samples (2009 - 2013)',
            ),
          ),
        ],
      ),
    ],
  );

  final DocxMetadataPacker packer =
      DocxMetadataPacker().dynamicFontSearch(true);
  final bytes = await packer.bytes(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
    print('Saved CV to ${outFile.path}');
  } else {
    stderr.writeln('Failed to generate CV .docx');
  }
}
