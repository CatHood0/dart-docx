import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

/// Simple demo that generates a minimal CV as a .docx file.
Future<void> main() async {
  final File outFile = File('test_resources/cv.docx');

  final PageSize pageSize = PageSize.letter;
  final DocumentMargins margins = DocumentMargins.fromCm(
    top: 1.02,
    right: 1.52,
    left: 1.52,
    bottom: 1.52,
    header: 0,
    footer: 0,
    gutter: 0,
  );

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'Curriculum - Jane Doe',
      section: DocumentLayout(
        size: pageSize,
        margins: margins,
        columns: ColumnOptions(
          numColumns: 2,
          columnWidths: <ColumnWidth>[
            ColumnWidth.points(
              width: 800,
              spaceAfter: 10,
            ),
            ColumnWidth.points(width: 500),
          ],
        ),
      ),
      styles: DocumentStylesSheet.base(),
    ),
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Column(
          children: <DocxTreeNode<dynamic>>[
            Paragraph(
              data: <RunBase<dynamic>>[
                TextRun(
                  data: TextPart(text: 'Experience'),
                ),
              ],
            ),
          ],
        ),
        Column(
          children: <DocxTreeNode<dynamic>>[
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
            )
          ],
        ),
        Column(
          children: <DocxTreeNode<dynamic>>[
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
            )
          ],
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxMetadataPacker()
      .dynamicFontSearch(true)
      .logPaths(<String>[DocxPaths.coreFilePath]).bytes(
    doc,
    applyCustomTheme: false,
  );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate CV .docx');
  }
}

        // Paragraph(
        //   data: <RunBase<dynamic>>[
        //     Run(
        //       component: DrawingML(
        //         data: FloatingImage(
        //           data: ImageData(
        //             buffer: await File('assets/cv_person.png').readAsBytes(),
        //             extension: 'png',
        //             anchorConfig: AnchorConfig(
        //               wrapType: WrapType.noWrap,
        //               wrapSide: null,
        //               anchorOffsetX: 0.5.inchesToEmu(),
        //               anchorOffsetY: 0,
        //               horizontalAnchor: HorizontalAnchorPosition.paragraph,
        //               verticalAnchor: VerticalAnchorPosition.paragraph,
        //               horizontalPosition: AnchorPosition.left,
        //               verticalPosition: AnchorPosition.top,
        //             ),
        //             width: 1.inchesToEmu(),
        //             height: 1.inchesToEmu(),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
