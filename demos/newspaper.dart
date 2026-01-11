import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

Future<void> main() async {
  final File outFile = File('test_resources/newspaper.docx');

  final PageSize pageSize = PageSize.letter;
  final DocumentMargins margins = DocumentMargins.fromCm(
    top: 1.5,
    right: 1.5,
    left: 1.5,
    bottom: 1.5,
    header: 0,
    footer: 0,
    gutter: 0,
  );

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'Periódico',
      section: DocumentLayout(
        size: pageSize,
        margins: margins,
        columns: ColumnOptions(
          numColumns: 3,
          equalWidth: true,
          columnWidths: <ColumnWidth>[
            ColumnWidth.points(width: 180, spaceAfter: 10),
            ColumnWidth.points(width: 180, spaceAfter: 10),
            ColumnWidth.points(width: 180, spaceAfter: 0),
          ],
        ),
      ),
      styles: DocumentStylesSheet.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('headline')
              .fontSize(24.ptToHalfPoints())
              .fontFamily('Times New Roman')
              .bold()
              .spacing(
                before: 10.ptToTwips(),
                after: 10.ptToTwips(),
              )
              .build(),
          StyleBuilder.paragraph('body')
              .fontSize(10.ptToHalfPoints())
              .fontFamily('Arial')
              .spacing(
                line: 1.5.inchesToLineSpacing(),
                after: 5.ptToTwips(),
              )
              .build(),
          StyleBuilder.paragraph('sectionTitle')
              .fontSize(14.ptToHalfPoints())
              .fontFamily('Verdana')
              .bold()
              .runColor(Color.rgb(0x333333))
              .spacing(
                before: 12.ptToTwips(),
                after: 8.ptToTwips(),
              )
              .build(),
        ],
      ),
    ),
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Column(
          children: <DocxTreeNode<dynamic>>[
            Paragraph.text(
              text: 'Titular Principal',
              styles: <Style>[
                Style.reference('headline'),
              ],
            ),
            Paragraph.text(
              text: 'Este es el contenido del artículo principal. '
                  'Puedes agregar más texto aquí para simular un artículo '
                  'de periódico. Este texto se ajustará a las columnas definidas.',
              styles: <Style>[
                Style.reference('body'),
              ],
            ),
          ],
        ),
        Column(
          children: <DocxTreeNode<dynamic>>[
            Paragraph.text(
              text: 'Sección: Noticias Locales',
              styles: <Style>[
                Style.reference('sectionTitle'),
              ],
            ),
            Paragraph.text(
              text: 'Aquí puedes incluir noticias locales. '
                  'Este es un ejemplo de cómo se vería el contenido en una columna.',
              styles: <Style>[
                Style.reference('body'),
              ],
            ),
          ],
        ),
        Column(
          children: <DocxTreeNode<dynamic>>[
            Paragraph.text(
              text: 'Sección: Deportes',
              styles: <Style>[
                Style.reference('sectionTitle'),
              ],
            ),
            Paragraph.text(
              text: 'Resumen de los eventos deportivos recientes. '
                  'Este texto también se ajustará a las columnas.',
              styles: <Style>[
                Style.reference('body'),
              ],
            ),
          ],
        ),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .dynamicFontSearch(true)
      .noTrimRuns()
      .setNormalIfNeeded(true)
      .defaultNormalStyle(Style.reference('body'))
      .logPath(DocxPaths.documentFilePath)
      .bytes(
        doc,
        applyCustomTheme: false,
      );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate newspaper .docx');
  }
}
