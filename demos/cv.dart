import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

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
              .fontSize(36.ptToHalfPoints())
              .fontFamily('Times New Roman')
              .bold()
              .alignment(Alignment.left)
              .qFormat(true)
              .spacing(
                before: 5.ptToTwips(),
                after: 12.ptToTwips(),
              )
              .uiPriority(20)
              .build(),
          StyleBuilder.paragraph('body')
              .name('Body')
              .fontSize(9.ptToHalfPoints())
              .fontFamily('Merryweather')
              .qFormat(true)
              .build(),
          StyleBuilder.paragraph('section')
              .name('Subtitle')
              .fontSize(9.ptToHalfPoints())
              .fontFamily('FreeSans')
              .bold()
              .runColor(Color(0x2079c7))
              .spacing(
                before: 0.35.inchesToTwips(),
                after: 0.15.inchesToTwips(),
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
              styles: <Style>[
                Style.ref('title'),
              ],
            ),
            Paragraph.text(
              text: 'Inserta tu texto '
                  'aquí Inserta tu texto '
                  'aquí Inserta tu texto aquí',
              styles: <Style>[
                StyleBuilder.up()
                    .fontFamily(
                      'OpenSans',
                    )
                    .build(),
              ],
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
              runStyles: <Style>[
                StyleBuilder.uc()
                    .fontFamily(
                      'OpenSans',
                    )
                    .build(),
              ],
            ),
            Paragraph.text(
              text: 'Tu ciudad, Provincia x1234xxx',
              runStyles: <Style>[
                StyleBuilder.uc()
                    .fontFamily(
                      'OpenSans',
                    )
                    .build(),
              ],
            ),
            Paragraph.text(
              text: '(54) 00 0 0000',
              runStyles: <Style>[
                StyleBuilder.uc()
                    .fontFamily(
                      'OpenSans',
                    )
                    .bold()
                    .build(),
              ],
            ),
            Paragraph.text(
              text: 'no_reply@example.com',
              runStyles: <Style>[
                StyleBuilder.uc()
                    .fontFamily(
                      'OpenSans',
                    )
                    .bold()
                    .build(),
              ],
            ),
            Paragraph.text(
              text: 'HABILIDADES',
              styles: <Style>[
                Style.ref('section'),
                StyleBuilder.up()
                    .spacing(
                      before: 0.4.inchesToTwips(),
                      after: 0.15.inchesToTwips(),
                    )
                    .build(),
              ],
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'Inserta tu texto aquí',
                  styles: <Object>[
                    StyleBuilder.uc()
                        .fontSize(
                          9.ptToHalfPoints(),
                        )
                        .build(),
                  ],
                ),
                Run(component: Break.lineBreak()),
                TextRun.text(
                  text: 'Inserta tu texto aquí',
                  styles: <Object>[
                    StyleBuilder.uc()
                        .fontSize(
                          9.ptToHalfPoints(),
                        )
                        .build(),
                  ],
                ),
                Run(component: Break.lineBreak()),
                TextRun.text(
                  text: 'Inserta tu texto aquí '
                      'Inserta tu texto aquí ',
                  styles: <Object>[
                    StyleBuilder.uc()
                        .fontSize(
                          9.ptToHalfPoints(),
                        )
                        .build(),
                  ],
                ),
                Run(component: Break.lineBreak()),
                TextRun.text(
                  text: 'Inserta tu texto aquí '
                      'Inserta tu texto aquí ',
                  styles: <Object>[
                    StyleBuilder.uc()
                        .fontSize(
                          9.ptToHalfPoints(),
                        )
                        .build(),
                  ],
                ),
              ],
              styles: <Style>[
                Style.ref('body'),
                StyleBuilder.up()
                    .spacing(
                      after: 5.ptToTwips(),
                      line: 1.5.inchesToLineSpacing(),
                      rule: LineRule.exact,
                    )
                    .build(),
              ],
            ),
            Paragraph.text(
              text: 'RECONOCIMIENTOS',
              styles: <Style>[
                Style.ref('section'),
              ],
            ),
            ...Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'Inserta tu texto aquí '
                      'Inserta tu texto aquí '
                      'Inserta tu texto aquí '
                      'Inserta tu texto aquí ',
                  styles: <Object>[
                    StyleBuilder.uc()
                        .fontSize(
                          9.ptToHalfPoints(),
                        )
                        .build(),
                  ],
                ),
              ],
              styles: <Style>[
                Style.ref('body'),
                StyleBuilder.up()
                    .spacing(
                      after: 1.ptToTwips(),
                      line: 1.5.inchesToLineSpacing(),
                      rule: LineRule.exact,
                    )
                    .build(),
              ],
            ).repeat(4),
            ...getRepeatedSection(
              title: 'IDIOMAS',
              date: '',
              content: 'Inserta tu texto aquí '
                  'Inserta tu texto aquí ',
              contentStyle:
                  StyleBuilder.uc().fontSize(9.ptToHalfPoints()).build(),
              repeat: 1,
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
      .logLevel(LogLevel.config)
      .log(print)
      .defaultNormalStyle(Style.ref('body'))
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
            styles: <Object>[
              BoldAttribute(),
              StyleBuilder.uc()
                  .fontSize(
                    11.ptToHalfPoints(),
                  )
                  .build(),
            ],
          ),
        if (subtitle2.isNotEmpty)
          TextRun.text(
            text: subtitle2,
            styles: <Object>[
              StyleBuilder.uc()
                  .fontSize(
                    11.ptToHalfPoints(),
                  )
                  .build(),
            ],
          ),
        if (subtitle3.isNotEmpty)
          TextRun.text(
            text: subtitle3,
            styles: <Object>[
              ItalicAttribute(),
              StyleBuilder.uc()
                  .fontSize(
                    11.ptToHalfPoints(),
                  )
                  .build(),
            ],
          ),
        if (date.isNotEmpty) Run(component: Break.lineBreak()),
        if (date.isNotEmpty)
          TextRun.text(
            text: date,
            styles: <Object>[
              StyleBuilder.uc()
                  .fontSize(8.ptToHalfPoints())
                  .runColor(Color(
                    0x55666666,
                  ))
                  .build(),
            ],
          ),
        if (date.isNotEmpty ||
            subtitle1.isNotEmpty ||
            subtitle2.isNotEmpty ||
            subtitle3.isNotEmpty)
          Run(component: Break.lineBreak()),
        TextRun.text(
          text: content,
          styles: <Object>[
            contentStyle ??
                StyleBuilder.uc()
                    .fontSize(9.ptToHalfPoints())
                    .runColor(Color(
                      0x55666666,
                    ))
                    .build(),
          ],
        ),
      ],
      styles: <Style>[
        Style.ref('body'),
        StyleBuilder.up()
            .spacing(
              line: 1.3.inchesToLineSpacing(),
              rule: LineRule.exact,
            )
            .build(),
      ],
    ).repeat(repeat),
  ];
}
