import 'dart:io';
import 'package:docx/docx.dart';
import 'package:test/test.dart';

void main() {
  test('Should create cv', () async {
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
                text: '• Senior Engineer at Acme Corp (2018 - Present)\n'
                    '• Software Developer at Example Inc. (2015 - 2018)',
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

    final DocxMetadataPacker packer =
        DocxMetadataPacker().dynamicFontSearch(true);
    final bytes = await packer.bytes(doc, applyCustomTheme: false);

    if (bytes != null) {
      await outFile.writeAsBytes(bytes);
      print('Saved CV to ${outFile.path}');
    } else {
      stderr.writeln('Failed to generate CV .docx');
    }
  });
  test('Should create a minimal DocxDocument and save it', () async {
    final DocxMetadataPacker parser = DocxMetadataPacker();
    final File docPathFile = File('test_resources/minimal_document.docx');
    parser
        .dynamicFontSearch(true)
        .bytes(
          applyCustomTheme: true,
          DocxDocument(
            options: DocumentOptions.blank(
              title: 'document',
              styles: DocumentStylesSheet.base().withNewStyles(
                <Style>[
                  StyleBuilder.character('code')
                      .name('Inline Code')
                      .fontFamily('Courier New')
                      .highlight('D3D3D3')
                      .build(),
                ],
              ),
            ),
            sections: <DocxContent<dynamic>>[
              Paragraph(
                data: <RunBase<dynamic>>[
                  TextRun(
                    data: TextPart(text: ' your can use'),
                  ),
                  HyperlinkRun(
                    data: HyperlinkTextPart(
                      hyperlink: 'https://pub.dev/packages/docx_transformer',
                      text: ' so, what is this link?',
                      styles: <Object>[
                        Style.reference('Hyperlink'),
                      ],
                    ),
                  ),
                  TextRun(
                    data: TextPart(
                      text: ' your can use',
                      styles: <Object>[
                        Style.reference('code'),
                        BoldAttribute(),
                      ],
                    ),
                  ),
                ],
                styles: <Style>[],
                pageBreak: ParagraphPagebreak.after,
                numbering: Numbering(
                  reference: 'unordered',
                  level: 0,
                ),
              ),
              Paragraph(
                data: <RunBase<dynamic>>[
                  TextRun(
                    data: TextPart(text: 'Yeah, we are in a 2nd page'),
                  ),
                  HyperlinkRun(
                    data: HyperlinkTextPart(
                      hyperlink: 'https://pub.dev/packages/docx_transformer',
                      text: ' and now, can we do about?',
                      styles: [
                        Style.reference('Hyperlink'),
                      ],
                    ),
                  ),
                ],
              ),
              TextFrame(
                data: <DocxContent<dynamic>>[
                  TextRun(
                    data: TextPart(
                      text: '',
                    ),
                  ),
                ],
                border: StyleBuilder.singularP()
                    .borders(
                      leftColor: '#0000FF',
                      rightColor: '#FFFF00',
                      left: BorderStyle.dashDotStroked,
                      right: BorderStyle.dashDotStroked,
                    )
                    .build(),
                width: 500,
                height: 500,
                xAlign: FrameHorizontalAlignment.left,
                // general text will be wrapped around this frame
                wrap: FrameWrap.square,
                // pinned horizontally
                hAnchor: FrameAnchor.page,
                // pinned vertically
                vAnchor: FrameAnchor.page,
                // put to top
                yAlign: FrameVerticalAlignment.top,
              ),
              LazyImage(
                data: ImageData(
                  buffer: File('test_resources/logo.jpg'),
                  extension: 'jpg',
                ),
              ),
            ],
          ),
        )
        .then((bytes) {
      assert(bytes != null, 'bytes should not be null');
      docPathFile.writeAsBytes(bytes!);
    });
  });
}
