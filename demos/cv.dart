import 'dart:io';
import 'package:docx/docx.dart';

/// Simple demo that generates a minimal CV as a .docx file.
Future<void> main() async {
  Directory('demos_output').createSync(recursive: true);
  final File outFile = File('demos_output/cv.docx');

  //TODO: add two columns, one for the personal info
  // and the other for the experiences, colleges, etc
  final PageSettings pageSize = PageSettings.letter;
  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.blank(
      title: 'Curriculum - Jane Doe',
      section: SectionOptions(
        size: pageSize,
        //TODO: column settings are not being applied
        columns: ColumnSettings(
          space: 200,
          numColumns: 2,
          equalWidth: false,
          separator: false,
          columnWidths: <ColumnWidthSetting>[
            // first take just a part
            ColumnWidthSetting(width: 150),
            // last one takes the rest
            ColumnWidthSetting(width: 250),
          ],
        ),
      ),
      styles: DocumentStylesSheet.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('Name')
              .fontFamily('Times New Roman')
              .fontSize(24.toHalfPointsFromPoints())
              .bold()
              .alignment(Alignment.center)
              .build(),
          StyleBuilder.paragraph('SectionHeading')
              .fontSize(14.toHalfPointsFromPoints())
              .bold()
              .spacing(after: 200)
              .build(),
        ],
      ),
    ),
    sections: <DocxContent<dynamic>>[
      Paragraph(
        data: <RunBase<dynamic>>[
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
                text: 'Email: jane.doe@example.com • Phone: +1 234 567 890'),
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
              text: '• Senior Engineer at Acme Corp (2018 - Present)',
            ),
          ),
        ],
      ),
      Paragraph(
        data: <RunBase<dynamic>>[
          TextRun(
            data: TextPart(
              text: '• Software Developer at Example Inc. (2015 - 2018)',
            ),
          ),
        ],
      ),
      Paragraph(
        data: <RunBase<dynamic>>[
          TextRun(
            data: TextPart(
                text: 'Education',
                styles: <Object>[Style.reference('SectionHeading')]),
          ),
        ],
      ),
      Paragraph(
        data: <RunBase<dynamic>>[
          TextRun(
            data: TextPart(
                text:
                    'M.Sc. Computer Science — University of Examples (2013 - 2015)\nB.Sc. Computer Science — College of Samples (2009 - 2013)'),
          ),
        ],
      ),
    ],
  );

  final DocxMetadataPacker packer = DocxMetadataPacker();
  packer.dynamicFontSearch(true);
  final bytes = await packer.bytes(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
    print('Saved CV to ${outFile.path}');
  } else {
    stderr.writeln('Failed to generate CV .docx');
  }
}
