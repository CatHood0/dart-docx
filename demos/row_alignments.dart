import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';
import 'package:docx/src/docx_sdk/components/layout/constraints/padding.dart';

Future<void> main() async {
  final File outFile = File('test_resources/row_alignments.docx');

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
      title: 'Row Alignments Showcase',
      styles: DocumentStyles.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('Title')
              .name('Title')
              .bold()
              .fontSize(24.ptToHalfPoints())
              .fontFamily('Georgia')
              .alignment(Alignment.center)
              .spacing(after: 200)
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('Subtitle')
              .name('Subtitle')
              .fontSize(12.ptToHalfPoints())
              .fontFamily('Georgia')
              .alignment(Alignment.center)
              .runColor(Color(0xFF666666))
              .spacing(after: 400)
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('Section')
              .name('Section')
              .bold()
              .fontSize(16.ptToHalfPoints())
              .fontFamily('Georgia')
              .spacing(before: 200, after: 150)
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('UseCase')
              .name('Use Case')
              .bold()
              .fontSize(12.ptToHalfPoints())
              .fontFamily('Georgia')
              .spacing(before: 100, after: 50)
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('Box')
              .name('Box')
              .fontSize(10.ptToHalfPoints())
              .fontFamily('Georgia')
              .alignment(Alignment.center)
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('CardTitle')
              .name('Card Title')
              .bold()
              .fontSize(11.ptToHalfPoints())
              .fontFamily('Georgia')
              .alignment(Alignment.center)
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('CardBody')
              .name('Card Body')
              .fontSize(9.ptToHalfPoints())
              .fontFamily('Georgia')
              .alignment(Alignment.center)
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('Nav')
              .name('Navigation')
              .fontSize(10.ptToHalfPoints())
              .fontFamily('Georgia')
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('Label')
              .name('Label')
              .bold()
              .fontSize(10.ptToHalfPoints())
              .fontFamily('Georgia')
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('Input')
              .name('Input')
              .fontSize(10.ptToHalfPoints())
              .fontFamily('Georgia')
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('SigLine')
              .name('Signature Line')
              .fontSize(10.ptToHalfPoints())
              .fontFamily('Georgia')
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('SigLabel')
              .name('Signature Label')
              .fontSize(9.ptToHalfPoints())
              .fontFamily('Georgia')
              .runColor(Color(0xFF888888))
              .qFormat(true)
              .build(),
        ],
      ),
      section: DocumentLayout(
        size: pageSize,
        margins: margins,
      ),
    ),
    root: DocumentRoot(
      sections: <DocxNode<dynamic>>[
        Paragraph.text(
          text: 'Row Alignment Showcase',
          styles: <Style>[Style.ref('Title')],
        ),
        Paragraph.text(
          text: 'This document demonstrates all Row alignment options '
              'available in the docx library.',
          styles: <Style>[Style.ref('Subtitle')],
        ),
        Paragraph.text(
          text: 'MainAxisAlignment Variants',
          styles: <Style>[Style.ref('Section')],
        ),
        _buildAlignmentDemo(
          title: '1. MainAxisAlignment.start',
          description: 'Children are aligned to the start (left in LTR). '
              'This is the default alignment.',
          alignment: MainAxisAlignment.start,
        ),
        _buildAlignmentDemo(
          title: '2. MainAxisAlignment.center',
          description: 'Children are centered within the row.',
          alignment: MainAxisAlignment.center,
        ),
        _buildAlignmentDemo(
          title: '3. MainAxisAlignment.spaceBetween',
          description: 'Children are distributed with maximum space between '
              'them. First and last items are at the edges.',
          alignment: MainAxisAlignment.spaceBetween,
        ),
        _buildAlignmentDemo(
          title: '4. MainAxisAlignment.end',
          description: 'Children are aligned to the end (right in LTR).',
          alignment: MainAxisAlignment.end,
        ),
        Paragraph.text(
          text: 'CrossAxisAlignment Variants',
          styles: <Style>[Style.ref('Section')],
        ),
        Paragraph.text(
          text: 'CrossAxisAlignment controls vertical positioning '
              'when children have different heights.',
          styles: <Style>[Style.ref('Normal')],
        ),
        _buildCrossAlignmentDemo(
          title: '1. CrossAxisAlignment.start (Top)',
          description: 'Children are aligned to the top of the row.',
          crossAlignment: CrossAxisAlignment.start,
        ),
        _buildCrossAlignmentDemo(
          title: '2. CrossAxisAlignment.center (Center)',
          description: 'Children are vertically centered within the row.',
          crossAlignment: CrossAxisAlignment.center,
        ),
        _buildCrossAlignmentDemo(
          title: '3. CrossAxisAlignment.end (Bottom)',
          description: 'Children are aligned to the bottom of the row.',
          crossAlignment: CrossAxisAlignment.end,
        ),
        Paragraph.text(
          text: 'Practical Use Cases',
          styles: <Style>[Style.ref('Section')],
        ),
        Paragraph.text(
          text: 'Use Case 1: Header Layout (logo + navigation)',
          styles: <Style>[Style.ref('UseCase')],
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 3.ptToTwips(),
            horizontal: 6.ptToTwips(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            minHeight: 100.ptToDxa(),
            children: <DocxNode<dynamic>>[
              LazyImage(
                asInline: true,
                data: ImageData.fileSized(
                  file: './assets/curriculum_libreoffice.png',
                  unit: Unit.pixels96,
                  size: 50,
                ),
              ).drawing().run().paragraph(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                minHeight: 50.ptToDxa(),
                children: <DocxNode<dynamic>>[
                  Paragraph.text(
                      text: 'Home  ', styles: <Style>[Style.ref('Nav')]),
                  Paragraph.text(
                      text: 'About  ', styles: <Style>[Style.ref('Nav')]),
                  Paragraph.text(
                      text: 'Contact', styles: <Style>[Style.ref('Nav')]),
                ],
              ),
            ],
          ),
        ),
        Paragraph.text(
          text: 'Use Case 2: Card Grid with Fixed Width',
          styles: <Style>[Style.ref('UseCase')],
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 3.ptToTwips(),
            horizontal: 8.ptToTwips(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            minHeight: 50.ptToDxa(),
            children: <DocxNode<dynamic>>[
              _buildCard('Card 1', 'Description for card 1'),
              _buildCard('Card 2', 'Description for card 2'),
              _buildCard('Card 3', 'Description for card 3'),
            ],
          ),
        ),
        Paragraph.text(
          text: 'Use Case 3: Form Field Layout',
          styles: <Style>[Style.ref('UseCase')],
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 3.ptToTwips(),
            horizontal: 8.ptToTwips(),
          ),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              minHeight: 30.ptToDxa(),
              children: <DocxNode<dynamic>>[
                Paragraph.text(
                    text: 'Name:', styles: <Style>[Style.ref('Label')]),
                Paragraph.text(
                    text: '___________________________',
                    styles: <Style>[Style.ref('Input')]),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              minHeight: 30.ptToDxa(),
              children: <DocxNode<dynamic>>[
                Paragraph.text(
                    text: 'Email:', styles: <Style>[Style.ref('Label')]),
                Paragraph.text(
                    text: '___________________________',
                    styles: <Style>[Style.ref('Input')]),
              ],
            ),
          ]),
        ),
        Paragraph.text(
          text: 'Use Case 4: Signature Block',
          styles: <Style>[Style.ref('UseCase')],
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 3.ptToTwips(),
            horizontal: 8.ptToTwips(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            minHeight: 10.ptToDxa(),
            children: <DocxNode<dynamic>>[
              Column(
                children: <DocxNode<dynamic>>[
                  Paragraph.text(
                      text: '_________________________',
                      styles: <Style>[Style.ref('SigLine')]),
                  Paragraph.text(
                      text: 'Signature',
                      styles: <Style>[Style.ref('SigLabel')]),
                  Paragraph.text(
                      text: 'Date: _______________',
                      styles: <Style>[Style.ref('Input')]),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .dynamicFontSearch(true)
      .noTrimRuns()
      .setNormalIfNeeded(true)
      .logPath(DocxPaths.documentFilePath)
      .execute(doc);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate row_alignments.docx');
  }
}

Paragraph _buildBox(String label) {
  return Paragraph.text(text: label, styles: <Style>[Style.ref('Box')]);
}

Paragraph _buildTallBox(String label) {
  return Paragraph.text(
      text: '$label\n\n\n', styles: <Style>[Style.ref('Box')]);
}

Paragraph _buildShortBox(String label) {
  return Paragraph.text(text: label, styles: <Style>[Style.ref('Box')]);
}

Paragraph _buildMediumBox(String label) {
  return Paragraph.text(text: '$label\n', styles: <Style>[Style.ref('Box')]);
}

DocxNode _buildAlignmentDemo({
  required String title,
  required String description,
  required MainAxisAlignment alignment,
}) {
  return Padding(
    padding: EdgeInsets.all(10.ptToTwips()),
    child: Row(
      mainAxisAlignment: alignment,
      children: <DocxNode<dynamic>>[
        _buildBox('Item 1'),
        _buildBox('Item 2'),
        _buildBox('Item 3'),
      ],
    ),
  );
}

DocxNode _buildCrossAlignmentDemo({
  required String title,
  required String description,
  required CrossAxisAlignment crossAlignment,
}) {
  return Padding(
    padding: EdgeInsets.all(3.ptToTwips()),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: crossAlignment,
      minHeight: 40.ptToDxa(),
      children: <DocxNode<dynamic>>[
        _buildTallBox('Tall'),
        _buildShortBox('Short'),
        _buildMediumBox('Medium'),
      ],
    ),
  );
}

Column _buildCard(String title, String description) {
  return Column(
    children: <DocxNode<dynamic>>[
      Paragraph.text(text: title, styles: <Style>[Style.ref('CardTitle')]),
      Paragraph.text(text: description, styles: <Style>[Style.ref('CardBody')]),
    ],
  );
}
