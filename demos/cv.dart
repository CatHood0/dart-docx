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
              .runColor(Color.rgb(0x2079c7))
              .spacing(
                before: 0.35.inchesToTwips(),
                after: 0.15.inchesToTwips(),
              )
              .qFormat(true)
              .build(),
        ],
      ),
    ),
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        Column(
          children: <DocxTreeNode<dynamic>>[
            Paragraph.text(
              text: 'Tu nombre',
              styles: <Style>[
                Style.reference('title'),
              ],
            ),
            Paragraph.text(
              text: 'Inserta tu texto '
                  'aquí Inserta tu texto '
                  'aquí Inserta tu texto aquí',
              styles: <Style>[
                StyleBuilder.singularP()
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
        Column(
          children: <DocxTreeNode<dynamic>>[
            Paragraph.text(
              text: 'Tu calle 123',
              runStyles: <Style>[
                StyleBuilder.singularC()
                    .fontFamily(
                      'OpenSans',
                    )
                    .build(),
              ],
            ),
            Paragraph.text(
              text: 'Tu ciudad, Provincia x1234xxx',
              runStyles: <Style>[
                StyleBuilder.singularC()
                    .fontFamily(
                      'OpenSans',
                    )
                    .build(),
              ],
            ),
            Paragraph.text(
              text: '(54) 00 0 0000',
              runStyles: <Style>[
                StyleBuilder.singularC()
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
                StyleBuilder.singularC()
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
                Style.reference('section'),
                StyleBuilder.singularP()
                    .spacing(
                      before: 0.4.inchesToTwips(),
                      after: 0.15.inchesToTwips(),
                    )
                    .build(),
              ],
            ),
            Paragraph(
              data: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'Inserta tu texto aquí',
                  styles: <Object>[
                    StyleBuilder.singularC()
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
                    StyleBuilder.singularC()
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
                    StyleBuilder.singularC()
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
                    StyleBuilder.singularC()
                        .fontSize(
                          9.ptToHalfPoints(),
                        )
                        .build(),
                  ],
                ),
              ],
              styles: <Style>[
                Style.reference('body'),
                StyleBuilder.singularP()
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
                Style.reference('section'),
              ],
            ),
            ...Paragraph(
              data: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'Inserta tu texto aquí '
                      'Inserta tu texto aquí '
                      'Inserta tu texto aquí '
                      'Inserta tu texto aquí ',
                  styles: <Object>[
                    StyleBuilder.singularC()
                        .fontSize(
                          9.ptToHalfPoints(),
                        )
                        .build(),
                  ],
                ),
              ],
              styles: <Style>[
                Style.reference('body'),
                StyleBuilder.singularP()
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
                  StyleBuilder.singularC().fontSize(9.ptToHalfPoints()).build(),
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
      .defaultNormalStyle(Style.reference('body'))
      .execute(
        doc,
        applyCustomTheme: false,
      );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Failed to generate CV .docx');
  }
}

List<DocxTreeNode> getRepeatedSection({
  required String title,
  required String date,
  required String content,
  required int repeat,
  String subtitle1 = '',
  String subtitle2 = '',
  String subtitle3 = '',
  Style? contentStyle,
}) {
  return <DocxTreeNode<dynamic>>[
    Paragraph.text(
      text: title,
      styles: <Style>[
        Style.reference('section'),
      ],
    ),
    ...Paragraph(
      data: <RunBase<dynamic>>[
        if (subtitle1.isNotEmpty)
          TextRun.text(
            text: subtitle1,
            styles: <Object>[
              BoldAttribute(),
              StyleBuilder.singularC()
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
              StyleBuilder.singularC()
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
              StyleBuilder.singularC()
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
              StyleBuilder.singularC()
                  .fontSize(8.ptToHalfPoints())
                  .runColor(Color.rgb(
                    0x666666,
                    0.5.toAlphaUnit(),
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
                StyleBuilder.singularC()
                    .fontSize(9.ptToHalfPoints())
                    .runColor(Color.rgb(
                      0x666666,
                      0.5.toAlphaUnit(),
                    ))
                    .build(),
          ],
        ),
      ],
      styles: <Style>[
        Style.reference('body'),
        StyleBuilder.singularP()
            .spacing(
              line: 1.3.inchesToLineSpacing(),
              rule: LineRule.exact,
            )
            .build(),
      ],
    ).repeat(repeat),
  ];
}
