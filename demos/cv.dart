import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';
import 'package:docx/src/core/extensions/cast_ext.dart';

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

final DocumentOptions options = DocumentOptions.standard(
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
);

/// Simple demo that generates a minimal CV as a .docx file.
Future<void> main() async {
  final File outFile = File('test_resources/cv.docx');

  DocxElements.instance.ensureInitialized();
  DocxElements.instance.debugMode(true);
  final Uint8List? bytes = await runCompilation(
    MyApp(),
    logAll: true,
    options: options,
    checkStylReferences: true,
  );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  }
}

class MyApp extends StatelessWidget {
  @override
  DocxNode<dynamic> build() {
    return RootBody(
      sections: <DocxNode<dynamic>>[
        PageColumn(
          id: 'page-column',
          children: <DocxNode<dynamic>>[
            Paragraph.text(
              id: '1',
              text: 'Tu nombre',
              styles: Style.ref('title').toList(),
            ),
            Paragraph.text(
              id: '2',
              text: 'Inserta tu texto '
                  'aquí Inserta tu texto '
                  'aquí Inserta tu texto aquí',
              textStyle: TextStyle(
                fontFamily: 'OpenSans',
              ),
            ),
            ContentSection(
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
              repeatTimes: 3,
            ),
            ContentSection(
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
              repeatTimes: 3,
            ),
            ContentSection(
              title: 'PROYECTOS',
              subtitle1: 'Nombre del proyecto',
              subtitle2: ' — ',
              subtitle3: 'Detalle',
              date: '',
              content: 'Inserta tu texto aquí ',
              repeatTimes: 1,
            ),
          ],
        ),
        PageColumn(
          id: 'page-column-2',
          children: <DocxNode<dynamic>>[
            Paragraph.text(
              id: 'pr-1',
              text: 'Tu calle 123',
              textStyle: TextStyle(
                fontFamily: 'OpenSans',
                bold: true,
              ),
            ),
            Paragraph.text(
              id: 'pr-2',
              text: 'Tu ciudad, Provincia x1234xxx',
              textStyle: TextStyle(
                fontFamily: 'OpenSans',
                bold: true,
              ),
            ),
            Paragraph.text(
              id: 'pr-3',
              text: '(54) 00 0 0000',
              textStyle: TextStyle(
                fontFamily: 'OpenSans',
                bold: true,
              ),
            ),
            Paragraph.text(
              id: 'pr-4',
              text: 'no_reply@example.com',
              textStyle: TextStyle(
                fontFamily: 'OpenSans',
                bold: true,
              ),
            ),
            Paragraph.text(
              id: 'pr-5',
              text: 'HABILIDADES',
              textStyle: TextStyle(
                spacingAfter: Inch(0.4),
                spacingBefore: Inch(0.15),
              ),
              styles: Style.ref('section').toList(),
            ),
            Paragraph(
              id: 'pr-6',
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
                spacingAfter: Point(5),
                lineSpacing: SpacingInch(1.5),
                lineSpacingRule: LineRule.exact,
              ),
              styles: Style.ref('body').toList(),
            ),
            Paragraph.text(
              id: 'pr-7',
              text: 'RECONOCIMIENTOS',
              styles: Style.ref('section').toList(),
            ),
            ...Paragraph(
              id: 'pr-10',
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
                spacingAfter: Point(1),
                lineSpacing: SpacingInch(1.5),
                lineSpacingRule: LineRule.exact,
              ),
              styles: Style.ref('body').toList(),
            ).repeat(4),
            ContentSection(
              title: 'IDIOMAS',
              date: '',
              content: 'Inserta tu texto aquí '
                  'Inserta tu texto aquí ',
              contentStyle: StyleBuilder.uc().fontSize(Point(9)).build(),
              repeatTimes: 1,
            ),
          ],
        ),
      ],
    );
  }
}

class ContentSection extends StatelessWidget {
  ContentSection({
    required this.title,
    required this.date,
    required this.content,
    this.contentStyle,
    this.repeatTimes = 1,
    this.subtitle1 = '',
    this.subtitle2 = '',
    this.subtitle3 = '',
    super.key,
  });

  final String title;
  final String date;
  final String content;
  final String subtitle1;
  final String subtitle2;
  final String subtitle3;
  final Style? contentStyle;
  final int repeatTimes;

  @override
  DocxNode<dynamic> build() {
    return Column(
      children: <DocxNode<dynamic>>[
        Paragraph.text(
          id: '($repeatTimes) 1',
          text: title,
          styles: <Style>[
            Style.ref('section'),
          ],
        ),
        ...Paragraph(
          id: '($repeatTimes) 2',
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
                  color: Color(0xFF666666),
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
                color: Color(0xFF666666),
              ),
              styles: contentStyle?.toList() ?? <Style>[],
            ),
          ],
          textStyle: TextStyle(
            lineSpacing: SpacingInch(1.3),
            lineSpacingRule: LineRule.exact,
          ),
          styles: Style.ref('body').toList(),
        ).repeat(repeatTimes)
      ],
    );
  }
}
