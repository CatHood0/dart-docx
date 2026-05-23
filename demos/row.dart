import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

Future<void> main() async {
  final File outFile = File('test_resources/row.docx');

  final PageSize pageSize = PageSize.letter;
  final DocumentMargins margins = DocumentMargins.fromCm(
    top: 1.52,
    right: 1.52,
    left: 1.52,
    bottom: 1.52,
    header: 1.1,
    footer: 1.1,
  );

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'Row Layout Tutorial',
      styles: DocumentStyles.base(),
      section: DocumentLayout(
        size: pageSize,
        margins: margins,
      ),
    ),
    root: DocxRoot(
      sections: <DocxNode<dynamic>>[
        Paragraph.text(
          text: '1. MainAxisAlignment.spaceBetween',
          styles: <Style>[
            StyleBuilder.paragraph('Heading1')
                .bold()
                .fontSize(14.ptToHalfPoints())
                .spacing(before: 200, after: 100)
                .build(),
          ],
        ),
        Paragraph.text(
          text: 'Children are distributed with space between them. '
              'Useful for laying out items like headers with logo on left and '
              'navigation on right.',
          styles: <Style>[
            StyleBuilder.paragraph('Body')
                .fontSize(10.ptToHalfPoints())
                .spacing(after: 120)
                .build(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <DocxNode<dynamic>>[
            LazyImage(
              asInline: true,
              data: ImageData.fileSized(
                file: './assets/curriculum_libreoffice.png',
                size: Pixel(80),
              ),
            ).drawing().run().paragraph(),
            Column(
              children: <DocxNode<dynamic>>[
                Paragraph.text(
                  text: 'Document Title',
                  styles: <Style>[
                    StyleBuilder.paragraph('Title')
                        .bold()
                        .fontSize(16.ptToHalfPoints())
                        .build(),
                  ],
                ),
                Paragraph.text(
                  text: 'Subtitle or description text',
                  styles: <Style>[
                    StyleBuilder.paragraph('Subtitle')
                        .fontSize(10.ptToHalfPoints())
                        .runColor(Color(0xFF666666))
                        .build(),
                  ],
                ),
              ],
            ),
          ],
        ),
        Paragraph.text(
          text: '2. MainAxisAlignment.start + CrossAxisAlignment.center',
          styles: <Style>[
            StyleBuilder.paragraph('Heading1')
                .bold()
                .fontSize(14.ptToHalfPoints())
                .spacing(before: 300, after: 100)
                .build(),
          ],
        ),
        Paragraph.text(
          text: 'Children aligned to the start (left) with vertical centering. '
              'Common for product cards with image on left and details on right.',
          styles: <Style>[
            StyleBuilder.paragraph('Body')
                .fontSize(10.ptToHalfPoints())
                .spacing(after: 120)
                .build(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <DocxNode<dynamic>>[
            LazyImage(
              asInline: true,
              data: ImageData.fileSized(
                file: './assets/curriculum_libreoffice.png',
                size: Pixel(100),
              ),
            ).drawing().run().paragraph(),
            Column(
              children: <DocxNode<dynamic>>[
                Paragraph.text(
                  text: 'Product Name',
                  styles: <Style>[
                    StyleBuilder.paragraph('Product')
                        .bold()
                        .fontSize(14.ptToHalfPoints())
                        .build(),
                  ],
                ),
                Paragraph.text(
                  text: 'This is a product description that explains '
                      'the features and benefits. It can span multiple '
                      'lines and will be vertically centered with the image.',
                  styles: <Style>[
                    StyleBuilder.paragraph('Body')
                        .fontSize(10.ptToHalfPoints())
                        .build(),
                  ],
                ),
              ],
            ),
          ],
        ),
        Paragraph.text(
          text: '3. MainAxisAlignment.center',
          styles: <Style>[
            StyleBuilder.paragraph('Heading1')
                .bold()
                .fontSize(14.ptToHalfPoints())
                .spacing(before: 300, after: 100)
                .build(),
          ],
        ),
        Paragraph.text(
          text: 'All children are centered within the row. '
              'Good for hero sections with centered content.',
          styles: <Style>[
            StyleBuilder.paragraph('Body')
                .fontSize(10.ptToHalfPoints())
                .spacing(after: 120)
                .build(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <DocxNode<dynamic>>[
            LazyImage(
              asInline: true,
              data: ImageData.fileSized(
                file: './assets/curriculum_libreoffice.png',
                size: Pixel(60),
              ),
            ).drawing().run().paragraph(),
            Paragraph.text(
              text: 'Centered Content',
              styles: <Style>[
                StyleBuilder.paragraph('Centered')
                    .bold()
                    .fontSize(12.ptToHalfPoints())
                    .alignment(Alignment.center)
                    .build(),
              ],
            ),
            LazyImage(
              asInline: true,
              data: ImageData.fileSized(
                file: './assets/curriculum_libreoffice.png',
                size: Pixel(60),
              ),
            ).drawing().run().paragraph(),
          ],
        ),
        Paragraph.text(
          text: '4. MainAxisAlignment.end',
          styles: <Style>[
            StyleBuilder.paragraph('Heading1')
                .bold()
                .fontSize(14.ptToHalfPoints())
                .spacing(before: 300, after: 100)
                .build(),
          ],
        ),
        Paragraph.text(
          text: 'Children are aligned to the end (right). '
              'Useful for signatures, dates, or trailing elements.',
          styles: <Style>[
            StyleBuilder.paragraph('Body')
                .fontSize(10.ptToHalfPoints())
                .spacing(after: 120)
                .build(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <DocxNode<dynamic>>[
            Column(
              children: <DocxNode<dynamic>>[
                Paragraph.text(
                  text: 'Authorized Signature',
                  styles: <Style>[
                    StyleBuilder.paragraph('Signature')
                        .fontSize(10.ptToHalfPoints())
                        .build(),
                  ],
                ),
                Paragraph.text(
                  text: '________________________',
                  styles: <Style>[
                    StyleBuilder.paragraph('Line')
                        .fontSize(10.ptToHalfPoints())
                        .build(),
                  ],
                ),
                Paragraph.text(
                  text: 'Date: ________________',
                  styles: <Style>[
                    StyleBuilder.paragraph('Date')
                        .fontSize(10.ptToHalfPoints())
                        .build(),
                  ],
                ),
              ],
            ),
          ],
        ),
        Paragraph.text(
          text: '5. Fixed Width Row with width parameter',
          styles: <Style>[
            StyleBuilder.paragraph('Heading1')
                .bold()
                .fontSize(14.ptToHalfPoints())
                .spacing(before: 300, after: 100)
                .build(),
          ],
        ),
        Paragraph.text(
          text: 'Using fixedWidth=true with width parameter gives precise '
              'control over the total row width. Each child gets equal share.',
          styles: <Style>[
            StyleBuilder.paragraph('Body')
                .fontSize(10.ptToHalfPoints())
                .spacing(after: 120)
                .build(),
          ],
        ),
        Row(
          width: Point(200),
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <DocxNode<dynamic>>[
            Column(
              children: <DocxNode<dynamic>>[
                Paragraph.text(
                  text: 'Column 1 (1/3)',
                  styles: <Style>[
                    StyleBuilder.paragraph('Col')
                        .bold()
                        .fontSize(10.ptToHalfPoints())
                        .build(),
                  ],
                ),
                Paragraph.text(
                  text: 'Width: ~166px',
                  styles: <Style>[
                    StyleBuilder.paragraph('Body')
                        .fontSize(9.ptToHalfPoints())
                        .build(),
                  ],
                ),
              ],
            ),
            Column(
              children: <DocxNode<dynamic>>[
                Paragraph.text(
                  text: 'Column 2 (1/3)',
                  styles: <Style>[
                    StyleBuilder.paragraph('Col')
                        .bold()
                        .fontSize(10.ptToHalfPoints())
                        .build(),
                  ],
                ),
                Paragraph.text(
                  text: 'Width: ~166px',
                  styles: <Style>[
                    StyleBuilder.paragraph('Body')
                        .fontSize(9.ptToHalfPoints())
                        .build(),
                  ],
                ),
              ],
            ),
            Column(
              children: <DocxNode<dynamic>>[
                Paragraph.text(
                  text: 'Column 3 (1/3)',
                  styles: <Style>[
                    StyleBuilder.paragraph('Col')
                        .bold()
                        .fontSize(10.ptToHalfPoints())
                        .build(),
                  ],
                ),
                Paragraph.text(
                  text: 'Width: ~166px',
                  styles: <Style>[
                    StyleBuilder.paragraph('Body')
                        .fontSize(9.ptToHalfPoints())
                        .build(),
                  ],
                ),
              ],
            ),
          ],
        ),
        Paragraph.text(
          text: '6. Nested Rows for Complex Layouts',
          styles: <Style>[
            StyleBuilder.paragraph('Heading1')
                .bold()
                .fontSize(14.ptToHalfPoints())
                .spacing(before: 300, after: 100)
                .build(),
          ],
        ),
        Paragraph.text(
          text: 'Rows can be nested to create more complex layouts like '
              'grids or cards with multiple sections.',
          styles: <Style>[
            StyleBuilder.paragraph('Body')
                .fontSize(10.ptToHalfPoints())
                .spacing(after: 120)
                .build(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <DocxNode<dynamic>>[
            Column(
              children: <DocxNode<dynamic>>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <DocxNode<dynamic>>[
                    LazyImage(
                      asInline: true,
                      data: ImageData.fileSized(
                        file: './assets/curriculum_libreoffice.png',
                        size: Pixel(40),
                      ),
                    ).drawing().run().paragraph(),
                    Paragraph.text(
                      text: 'Feature 1',
                      styles: <Style>[
                        StyleBuilder.paragraph('Feature')
                            .bold()
                            .fontSize(11.ptToHalfPoints())
                            .build(),
                      ],
                    ),
                  ],
                ),
                Paragraph.text(
                  text: 'Description of feature 1 with details.',
                  styles: <Style>[
                    StyleBuilder.paragraph('Body')
                        .fontSize(9.ptToHalfPoints())
                        .build(),
                  ],
                ),
              ],
            ),
            Column(
              children: <DocxNode<dynamic>>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <DocxNode<dynamic>>[
                    LazyImage(
                      asInline: true,
                      data: ImageData.fileSized(
                        file: './assets/curriculum_libreoffice.png',
                        size: Pixel(40),
                      ),
                    ).drawing().run().paragraph(),
                    Paragraph.text(
                      text: 'Feature 2',
                      styles: <Style>[
                        StyleBuilder.paragraph('Feature')
                            .bold()
                            .fontSize(11.ptToHalfPoints())
                            .build(),
                      ],
                    ),
                  ],
                ),
                Paragraph.text(
                  text: 'Description of feature 2 with details.',
                  styles: <Style>[
                    StyleBuilder.paragraph('Body')
                        .fontSize(9.ptToHalfPoints())
                        .build(),
                  ],
                ),
              ],
            ),
          ],
        ),
        Paragraph.text(
          text: '7. CrossAxisAlignment Variants (Vertical Alignment)',
          styles: <Style>[
            StyleBuilder.paragraph('Heading1')
                .bold()
                .fontSize(14.ptToHalfPoints())
                .spacing(before: 300, after: 100)
                .build(),
          ],
        ),
        Paragraph.text(
          text: 'CrossAxisAlignment controls how children are aligned '
              'vertically within the row height.',
          styles: <Style>[
            StyleBuilder.paragraph('Body')
                .fontSize(10.ptToHalfPoints())
                .spacing(after: 120)
                .build(),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <DocxNode<dynamic>>[
            LazyImage(
              asInline: true,
              data: ImageData.fileSized(
                file: './assets/curriculum_libreoffice.png',
                size: Pixel(80),
              ),
            ).drawing().run().paragraph(),
            Paragraph.text(
              text: 'Top aligned (CrossAxisAlignment.start)\n\n'
                  'This text has multiple lines\nto show the effect.',
              styles: <Style>[
                StyleBuilder.paragraph('Body')
                    .fontSize(10.ptToHalfPoints())
                    .build(),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <DocxNode<dynamic>>[
            LazyImage(
              asInline: true,
              data: ImageData.fileSized(
                file: './assets/curriculum_libreoffice.png',
                size: Pixel(80),
              ),
            ).drawing().run().paragraph(),
            Paragraph.text(
              text: 'Center aligned (CrossAxisAlignment.center)\n\n'
                  'This text has multiple lines\nto show the effect.',
              styles: <Style>[
                StyleBuilder.paragraph('Body')
                    .fontSize(10.ptToHalfPoints())
                    .build(),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <DocxNode<dynamic>>[
            LazyImage(
              asInline: true,
              data: ImageData.fileSized(
                file: './assets/curriculum_libreoffice.png',
                size: Pixel(80),
              ),
            ).drawing().run().paragraph(),
            Paragraph.text(
              text: 'Bottom aligned (CrossAxisAlignment.end)\n\n'
                  'This text has multiple lines\nto show the effect.',
              styles: <Style>[
                StyleBuilder.paragraph('Body')
                    .fontSize(10.ptToHalfPoints())
                    .build(),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .autoRegisterFonts(true)
      .noTrimRuns()
      .normalStyleIfNeeded()
      .logPath(DocxPaths.documentFilePath)
      .execute(doc);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate row.docx');
  }
}
