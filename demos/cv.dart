import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

/// Simple demo that generates a minimal CV as a .docx file.
Future<void> main() async {
  final File outFile = File('test_resources/cv.docx');

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
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
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Paragraph(data: <RunBase<dynamic>>[
          Run(
            component: WordDrawingML(
              data: FloatingImage(
                data: ImageData(
                  buffer: await File('assets/cv_person.png').readAsBytes(),
                  extension: 'png',
                  anchorConfig: AnchorConfig(
                    wrapType: WrapType.none,
                    wrapSide: null,
                    anchorOffsetX: 0.5.toEmuFromInches(),
                    anchorOffsetY: 0,
                    horizontalAnchor: HorizontalAnchorPosition.paragraph,
                    verticalAnchor: VerticalAnchorPosition.paragraph,
                    horizontalPosition: AnchorPosition.left,
                    verticalPosition: AnchorPosition.top,
                  ),
                  width: 1.toEmuFromInches(),
                  height: 1.toEmuFromInches(),
                ),
              ),
            ),
          ),
        ]),
        Paragraph(
          data: <RunBase<dynamic>>[
            TextRun(
              data: TextPart(
                text: 'Jane Doe',
                styles: <Object>[
                  Style.reference('Name'),
                ],
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
        // ColumnBreak(),
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
            Run(component: Break.lineBreak(), wrapInRunMark: true),
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
            Run(component: Break.lineBreak(), wrapInRunMark: true),
            TextRun(
              data: TextPart(
                text: 'B.Sc. Computer Science — '
                    'College of Samples (2009 - 2013)',
              ),
            ),
          ],
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxMetadataPacker()
      .dynamicFontSearch(true)
      .logPath(DocxPaths.documentFilePath)
      .bytes(doc, applyCustomTheme: false);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
    print('Saved CV to ${outFile.path}');
  } else {
    stderr.writeln('Failed to generate CV .docx');
  }
}
