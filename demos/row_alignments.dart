import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

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
          //TODO: i think we can use ThemeData to improve this
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
    root: DocxRoot(
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
        Column(
          children: [
            TitleElement(
              title: '1. MainAxisAlignment.start',
              description: 'Children are aligned to the start (left in LTR). '
                  'This is the default alignment.',
              padding: 10,
              mainAxisAlignment: MainAxisAlignment.start,
            ),
            TitleElement(
              title: '2. MainAxisAlignment.center',
              description: 'Children are centered within the row.',
              padding: 10,
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            TitleElement(
              title: '3. MainAxisAlignment.spaceBetween',
              description:
                  'Children are distributed with maximum space between '
                  'them. First and last items are at the edges.',
              padding: 10,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
            TitleElement(
              title: '4. MainAxisAlignment.end',
              description: 'Children are aligned to the end (right in LTR).',
              padding: 10,
              mainAxisAlignment: MainAxisAlignment.end,
            ),
          ],
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
        TitleElement(
          title: '1. CrossAxisAlignment.start (Top)',
          description: 'Children are aligned to the top of the row.',
          padding: 3,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        TitleElement(
          title: '2. CrossAxisAlignment.center (Center)',
          description: 'Children are vertically centered within the row.',
          padding: 3,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
        TitleElement(
          title: '3. CrossAxisAlignment.end (Bottom)',
          description: 'Children are aligned to the bottom of the row.',
          padding: 3,
          crossAxisAlignment: CrossAxisAlignment.end,
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
            vertical: 3.toTwips(),
            horizontal: 6.toTwips(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            minHeight: 100.toPt(),
            children: <DocxNode<dynamic>>[
              LazyImage(
                data: ImageData.fileSized(
                  file: './assets/curriculum_libreoffice.png',
                  size: 50.toPixels(),
                ),
              ).drawing().run().paragraph(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                minHeight: Point(50),
                children: <DocxNode<dynamic>>[
                  Text('Home  ', styles: <Style>[Style.ref('Nav')]),
                  Text('About  ', styles: <Style>[Style.ref('Nav')]),
                  Text('Contact', styles: <Style>[Style.ref('Nav')]),
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
            vertical: Point(3),
            horizontal: Point(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            minHeight: Point(50),
            children: <DocxNode<dynamic>>[
              TitledCard(
                  title: 'Card 1', description: 'Description for card 1'),
              TitledCard(
                  title: 'Card 2', description: 'Description for card 2'),
              TitledCard(
                  title: 'Card 3', description: 'Description for card 3'),
            ],
          ),
        ),
        Paragraph.text(
          text: 'Use Case 3: Form Field Layout',
          styles: <Style>[Style.ref('UseCase')],
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: Point(3),
            horizontal: Point(8),
          ),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              minHeight: Point(30),
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
              minHeight: Point(30),
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
            vertical: Twip(3),
            horizontal: Twip(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            minHeight: Point(10),
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
      .autoRegisterFonts(true)
      .noTrimRuns()
      .normalStyleIfNeeded()
      .logPath(DocxPaths.documentFilePath)
      .execute(doc);

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate row_alignments.docx');
  }
}

class Box extends StatelessWidget {
  Box({
    required this.label,
    super.key,
  });

  final String label;
  @override
  DocxNode<dynamic> build() {
    return Paragraph.text(
      text: label,
      styles: <Style>[
        Style.ref('Box'),
      ],
    );
  }
}

class TitleElement extends StatelessWidget {
  TitleElement({
    required this.title,
    required this.padding,
    required this.description,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    super.key,
  });

  final String title;
  final String description;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final int padding;

  @override
  DocxNode build() {
    return Padding(
      padding: EdgeInsets.all(Point(padding)),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: <DocxNode<dynamic>>[
          Box(label: 'Item 1'),
          Box(label: 'Item 2'),
          Box(label: 'Item 3'),
        ],
      ),
    );
  }
}

class TitledCard extends StatelessWidget {
  TitledCard({
    required this.title,
    required this.description,
    super.key,
  });

  final String title;
  final String description;

  @override
  DocxNode build() {
    return Column(
      children: <DocxNode<dynamic>>[
        Text(title, styles: <Style>[Style.ref('CardTitle')]),
        Text(description, styles: <Style>[Style.ref('CardBody')]),
      ],
    );
  }
}
