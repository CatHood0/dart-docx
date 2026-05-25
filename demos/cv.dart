import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';
import 'package:docx/src/core/extensions/cast_ext.dart';

/// Simple demo that generates a minimal CV as a .docx file.
Future<void> main() async {
  final File outFile = File('test_resources/cv.docx');

  final PageSize pageSize = PageSize.letter;
  final DocumentMargins margins = DocumentMargins.fromCm(
    top: 1.52,
    right: 1.52,
    left: 1.52,
    bottom: 1.52,
    header: 0,
    footer: 0,
    gutter: 0,
  );

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'Curriculum',
      section: DocumentLayout(
        size: pageSize,
        margins: margins,
        columns: ColumnOptions(
          numColumns: 2,
          equalWidth: false,
          columnWidths: <ColumnWidth>[
            ColumnWidth.points(
              width: 355.45,
              spaceAfter: 18,
            ),
            ColumnWidth.points(
              width: 152.35,
              spaceAfter: 0,
            ),
          ],
        ),
      ),
      styles: DocumentStyles.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('title')
              .name('Title')
              .fontSize(Point(36))
              .fontFamily('Times New Roman')
              .bold()
              .alignment(Alignment.left)
              .qFormat(true)
              .spacing(
                before: Twip(5),
                after: Twip(12),
              )
              .uiPriority(20)
              .build(),
          StyleBuilder.paragraph('body')
              .name('Body')
              .fontSize(Point(9))
              .fontFamily('Merryweather')
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('section')
              .name('Subtitle')
              .fontSize(Point(9))
              .fontFamily('FreeSans')
              .bold()
              .runColor(Color(0x2079c7))
              .spacing(
                before: Inch(0.35),
                after: Inch(0.15),
              )
              .qFormat(true)
              .build(),
        ],
      ),
    ),
    root: DocxRoot(
      sections: <DocxNode<dynamic>>[
        PageColumn(
          children: <DocxNode<dynamic>>[
            Paragraph.text(
              text: 'Tu nombre',
              styles: Style.ref('title').toList(),
            ),
            Paragraph.text(
              text: 'Inserta tu texto '
                  'aquí Inserta tu texto '
                  'aquí Inserta tu texto aquí',
              textStyle: TextStyle(
                fontFamily: 'OpenSans',
              ),
            ),
            ...getRepeatedSection(
              title: 'EXPERIENCIA',
              subtitle1: 'Empresa, ',
              subtitle2: 'Ubicación — ',
              subtitle3: 'Puesto',
              date: 'MES de 20XX - PRESENTE',
              content: 'Inserta tu texto aquí '
                  'Inserta tu texto aquí '
                  'Inserta tu texto aquí '
                  'Inserta tu texto aquí '
                  'Inserta tu texto aquí ',
              repeat: 3,
            ),
            ...getRepeatedSection(
              title: 'EDUCACIÓN',
              subtitle1: 'Nombre de la escuela, ',
              subtitle2: 'Ubicación — ',
              subtitle3: 'Título',
              date: 'MES de 20XX - MES DE 20XX',
              content: 'Inserta tu texto aquí '
                  'Inserta tu texto aquí '
                  'Inserta tu texto aquí '
                  'Inserta tu texto aquí '
                  'Inserta tu texto aquí '
                  'Inserta tu texto aquí '
                  'Inserta tu texto aquí ',
              repeat: 3,
            ),
            ...getRepeatedSection(
              title: 'PROYECTOS',
              subtitle1: 'Nombre del proyecto',
              subtitle2: ' — ',
              subtitle3: 'Detalle',
              date: '',
              content: 'Inserta tu texto aquí ',
              repeat: 1,
            ),
          ],
        ),
        PageColumn(
          children: <DocxNode<dynamic>>[
            Paragraph.text(
              text: 'Tu calle 123',
              textStyle: TextStyle(
                fontFamily: 'OpenSans',
                bold: true,
              ),
            ),
            Paragraph.text(
              text: 'Tu ciudad, Provincia x1234xxx',
              textStyle: TextStyle(
                fontFamily: 'OpenSans',
                bold: true,
              ),
            ),
            Paragraph.text(
              text: '(54) 00 0 0000',
              textStyle: TextStyle(
                fontFamily: 'OpenSans',
                bold: true,
              ),
            ),
            Paragraph.text(
              text: 'no_reply@example.com',
              textStyle: TextStyle(
                fontFamily: 'OpenSans',
                bold: true,
              ),
            ),
            Paragraph.text(
              text: 'HABILIDADES',
              textStyle: TextStyle(
                spacingAfter: Inch(0.4),
                spacingBefore: Inch(0.15),
              ),
              styles: Style.ref('section').toList(),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'Inserta tu texto aquí',
                  textStyle: TextStyle(
                    fontSize: Point(9),
                  ),
                ),
                Run(component: Break.lineBreak()),
                TextRun.text(
                  text: 'Inserta tu texto aquí',
                  textStyle: TextStyle(
                    fontSize: Point(9),
                  ),
                ),
                Run(component: Break.lineBreak()),
                TextRun.text(
                  text: 'Inserta tu texto aquí '
                      'Inserta tu texto aquí ',
                  textStyle: TextStyle(
                    fontSize: Point(9),
                  ),
                ),
                Run(component: Break.lineBreak()),
                TextRun.text(
                  text: 'Inserta tu texto aquí '
                      'Inserta tu texto aquí ',
                  textStyle: TextStyle(
                    fontSize: Point(9),
                  ),
                ),
              ],
              textStyle: TextStyle(
                spacingAfter: Twip(5),
                lineSpacing: SpacingInch(1.5),
                lineSpacingRule: LineRule.exact,
              ),
              styles: Style.ref('body').toList(),
            ),
            Paragraph.text(
              text: 'RECONOCIMIENTOS',
              styles: Style.ref('section').toList(),
            ),
            ...Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'Inserta tu texto aquí '
                      'Inserta tu texto aquí '
                      'Inserta tu texto aquí '
                      'Inserta tu texto aquí ',
                  textStyle: TextStyle(
                    fontSize: Point(9),
                  ),
                ),
              ],
              textStyle: TextStyle(
                spacingAfter: Twip(1),
                lineSpacing: SpacingInch(1.5),
                lineSpacingRule: LineRule.exact,
              ),
              styles: Style.ref('body').toList(),
            ).repeat(4),
            ...getRepeatedSection(
              title: 'IDIOMAS',
              date: '',
              content: 'Inserta tu texto aquí '
                  'Inserta tu texto aquí ',
              contentStyle: StyleBuilder.uc().fontSize(Point(9)).build(),
              repeat: 1,
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
      .logLevel(LogLevel.config)
      .log(print)
      .normalStyle(Style.ref('body'))
      .setStandardStores()
      .execute(
        doc,
        applyCustomTheme: false,
        stages: DocxPipeline.defaultStages,
      );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate CV .docx');
  }
}

List<DocxNode> getRepeatedSection({
  required String title,
  required String date,
  required String content,
  required int repeat,
  String subtitle1 = '',
  String subtitle2 = '',
  String subtitle3 = '',
  Style? contentStyle,
}) {
  return <DocxNode<dynamic>>[
    Paragraph.text(
      text: title,
      styles: <Style>[
        Style.ref('section'),
      ],
    ),
    ...Paragraph(
      children: <RunBase<dynamic>>[
        if (subtitle1.isNotEmpty)
          TextRun.text(
            text: subtitle1,
            textStyle: TextStyle(fontSize: Point(11), bold: true),
          ),
        if (subtitle2.isNotEmpty)
          TextRun.text(
            text: subtitle2,
            styles: [
              StyleBuilder.uc()
                  .fontSize(
                    Point(11),
                  )
                  .build(),
            ],
          ),
        if (subtitle3.isNotEmpty)
          TextRun.text(
            text: subtitle3,
            textStyle: TextStyle(fontSize: Point(11), italic: true),
          ),
        if (date.isNotEmpty) Run(component: Break.lineBreak()),
        if (date.isNotEmpty)
          TextRun.text(
            text: date,
            textStyle: TextStyle(
              fontSize: Point(8),
              fontColor: Color(0x55666666),
            ),
          ),
        if (date.isNotEmpty ||
            subtitle1.isNotEmpty ||
            subtitle2.isNotEmpty ||
            subtitle3.isNotEmpty)
          Run(component: Break.lineBreak()),
        TextRun.text(
          text: content,
          textStyle: TextStyle(
            fontSize: Point(9),
            fontColor: Color(0x55666666),
          ),
          styles: contentStyle?.toList() ?? <Style>[],
        ),
      ],
      textStyle: TextStyle(
        lineSpacing: SpacingInch(1.3),
        lineSpacingRule: LineRule.exact,
      ),
      styles: Style.ref('body').toList(),
    ).repeat(repeat),
  ];
}
