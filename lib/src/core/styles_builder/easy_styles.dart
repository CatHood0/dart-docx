import '../../../docx.dart';
import '../../docx_sdk/utils/language_codes.dart';

class EasyStyles {
  static Style get normal => StyleBuilder.paragraph('Normal')
      .name(
        'Normal',
        LanguageCodes.englishUS,
      )
      .fontFamily('Times New Roman')
      .fontSize(12.ptToHalfPoints())
      .alignment(Alignment.left)
      .spacing(before: 0, after: 160)
      .lang(DocxLanguage(language: LanguageCodes.englishUS))
      .qFormat(true)
      .build();

  static Style get listParagraph => StyleBuilder.paragraph('ListParagraph')
      .names(<String, dynamic>{
        'List Paragraph': LanguageCodes.englishUS,
        'Lista de Parrafo': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .keepNext(true)
      .keepLines(true)
      .activateWindowControl()
      .contextualSpacing(true)
      .qFormat(true)
      .build();

  static Style get defaultParagraphFont =>
      StyleBuilder.character('DefaultParagraphFont')
          .names(<String, dynamic>{
            'Default Paragraph Font': LanguageCodes.englishUS,
            'Estilo de Parrafo Predeterminado': List<String>.from(<String>[
              LanguageCodes.spanishES,
              LanguageCodes.spanishMX,
            ]),
          })
          .defaultValue(true)
          .build();

  static Style get hyperlink => StyleBuilder.character('Hyperlink')
      .names(<String, dynamic>{
        'Hyperlink': LanguageCodes.englishUS,
        'Hipervínculo': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .runColor(Color.rgb(0x0563C1))
      .underline()
      .build();

  static Style get heading1 => StyleBuilder.paragraph('Heading1')
      .names(<String, dynamic>{
        'Heading 1': LanguageCodes.englishUS,
        'Título 1': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(24.ptToHalfPoints())
      .bold()
      .spacing(before: 480)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(0)
      .uiPriority(9)
      .qFormat(true)
      .build();

  static Style get heading2 => StyleBuilder.paragraph('Heading2')
      .names(<String, dynamic>{
        'Heading 2': LanguageCodes.englishUS,
        'Título 2': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(18.ptToHalfPoints())
      .bold()
      .spacing(before: 360, after: 80)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(1)
      .uiPriority(9)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading3 => StyleBuilder.paragraph('Heading3')
      .names(<String, dynamic>{
        'Heading 3': LanguageCodes.englishUS,
        'Título 3': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(14.ptToHalfPoints())
      .bold()
      .spacing(before: 280, after: 80)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(2)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading4 => StyleBuilder.paragraph('Heading4')
      .names(<String, dynamic>{
        'Heading 4': LanguageCodes.englishUS,
        'Título 4': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(12.ptToHalfPoints())
      .bold()
      .spacing(before: 240, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(3)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading5 => StyleBuilder.paragraph('Heading5')
      .names(<String, dynamic>{
        'Heading 5': LanguageCodes.englishUS,
        'Título 5': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(12.ptToHalfPoints())
      .bold()
      .spacing(before: 220, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(4)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  static Style get heading6 => StyleBuilder.paragraph('Heading6')
      .names(<String, dynamic>{
        'Heading 6': LanguageCodes.englishUS,
        'Título 6': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .basedOn('Normal')
      .next('Normal')
      .fontFamily('Times New Roman')
      .fontSize(10.ptToHalfPoints())
      .bold()
      .spacing(before: 200, after: 40)
      .keepNext(true)
      .keepLines(true)
      .outlineLevel(5)
      .uiPriority(9)
      .semiHidden(true)
      .unhideWhenUsed(true)
      .qFormat(true)
      .build();

  /// Table Grid: A basic table with single tableBorders on all cells.
  static Style get tableGrid => TableStyleBuilder.table('TableGrid')
      .names(<String, dynamic>{
        'Table Grid': LanguageCodes.englishUS,
        'Cuadrícula de tabla': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .tableWidth(5000, 'pct')
      .tableBorders(
        top: BorderStyle.single,
        bottom: BorderStyle.single,
        left: BorderStyle.single,
        right: BorderStyle.single,
        insideH: BorderStyle.single,
        insideV: BorderStyle.single,
      )
      .cellMargins(
        top: 0,
        bottom: 0,
        left: 7.2.ptToTwips(),
        right: 7.2.ptToTwips(),
      )
      .rowProperties(
          height: 1.7.inchesToLineSpacing(),
          heightRule: TableHeightRule.atLeast)
      .cellVerticalAlignment(Alignment.center)
      .qFormat(true)
      .build();

  /// Light Shading: A table with light shading on the header and banded rows.
  static Style get lightShading => TableStyleBuilder.table('LightShading')
      .names(<String, dynamic>{
        'Light Shading': LanguageCodes.englishUS,
        'Sombreado claro': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .tableWidth(5000, 'pct')
      .tableBorders(
        top: BorderStyle.single,
        bottom: BorderStyle.single,
        left: BorderStyle.single,
        right: BorderStyle.single,
        insideH: BorderStyle.single,
        insideV: BorderStyle.single,
      )
      .cellMargins(
        top: 0,
        bottom: 0,
        left: 7.2.ptToTwips(),
        right: 7.2.ptToTwips(),
      )
      .rowProperties(
          height: 1.7.inchesToLineSpacing(),
          heightRule: TableHeightRule.atLeast)
      .cellVerticalAlignment(Alignment.center)
      .rowBandSize('1')
      .colBandSize('1')
      // Conditional style for first row (header)
      .addConditionalStyle(
        ConditionalTableStyle(
          'firstRow',
          TableStyleBuilder.table('LightShadingFirstRow')
              .tableShading(color: Color.rgb(0xD3D3D3))
              .bold(),
        ),
      )
      // Conditional style for banded rows (even rows)
      .addConditionalStyle(
        ConditionalTableStyle(
          'band1H',
          TableStyleBuilder.table('LightShadingBand1H')
              .tableShading(color: Color.rgb(0xF2F2F2)),
        ),
      )
      // Conditional style for first column (optional)
      .addConditionalStyle(
        ConditionalTableStyle(
          'firstCol',
          TableStyleBuilder.table('LightShadingFirstCol'),
        ),
      )
      .qFormat(true)
      .build();

  /// Medium Shading 1: A table with medium shading and accent colors.
  static Style get mediumShading1 => TableStyleBuilder.table('MediumShading1')
      .names(<String, dynamic>{
        'Medium Shading 1': LanguageCodes.englishUS,
        'Sombreado medio 1': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .tableWidth(5000, 'pct')
      .tableBorders(
        top: BorderStyle.single,
        bottom: BorderStyle.single,
        left: BorderStyle.single,
        right: BorderStyle.single,
        insideH: BorderStyle.single,
        insideV: BorderStyle.single,
      )
      .cellMargins(
        top: 0,
        bottom: 0,
        left: 7.2.ptToTwips(),
        right: 7.2.ptToTwips(),
      )
      .rowProperties(
          height: 1.7.inchesToLineSpacing(),
          heightRule: TableHeightRule.atLeast)
      .cellVerticalAlignment(Alignment.center)
      .rowBandSize('1')
      .colBandSize('1')
      // First row with a darker shade and white bold text
      .addConditionalStyle(
        ConditionalTableStyle(
            'firstRow',
            TableStyleBuilder.table('MediumShading1FirstRow')
                .tableShading(color: Color.rgb(0x4F81BD))
                .runColor(Color.rgb(0xFFFFFF))
                .bold()),
      )
      // Banded rows with light blue shade
      .addConditionalStyle(
        ConditionalTableStyle(
          'band1H',
          TableStyleBuilder.table('MediumShading1Band1H')
              .tableShading(color: Color.rgb(0xDCE6F1)),
        ),
      )
      // Last row with a bottom border emphasis
      .addConditionalStyle(
        ConditionalTableStyle(
          'lastRow',
          TableStyleBuilder.table('MediumShading1LastRow').tableBorders(
            bottom: BorderStyle.double,
            bottomSize: 8,
          ),
        ),
      )
      .qFormat(true)
      .build();

  /// Medium Shading 2: A table with a different color scheme.
  static Style get mediumShading2 => TableStyleBuilder.table('MediumShading2')
      .names(<String, dynamic>{
        'Medium Shading 2': LanguageCodes.englishUS,
        'Sombreado medio 2': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .tableWidth(5000, 'pct')
      .tableBorders(
        top: BorderStyle.single,
        bottom: BorderStyle.single,
        left: BorderStyle.single,
        right: BorderStyle.single,
        insideH: BorderStyle.single,
        insideV: BorderStyle.single,
      )
      .cellMargins(
        top: 0,
        bottom: 0,
        left: 7.2.ptToTwips(),
        right: 7.2.ptToTwips(),
      )
      .rowProperties(
          height: 1.7.inchesToLineSpacing(),
          heightRule: TableHeightRule.atLeast)
      .cellVerticalAlignment(Alignment.center)
      .rowBandSize('1')
      .colBandSize('1')
      // First row with a green shade
      .addConditionalStyle(
        ConditionalTableStyle(
            'firstRow',
            TableStyleBuilder.table('MediumShading2FirstRow')
                .tableShading(color: Color.rgb(0xC0504D))
                .runColor(Color.rgb(0xFFFFFF))
                .bold()),
      )
      // Banded rows with light red shade
      .addConditionalStyle(
        ConditionalTableStyle(
          'band1H',
          TableStyleBuilder.table('MediumShading2Band1H')
              .tableShading(color: Color.rgb(0xF2DCDB)),
        ),
      )
      // First column with bold text
      .addConditionalStyle(
        ConditionalTableStyle(
          'firstCol',
          TableStyleBuilder.table('MediumShading2FirstCol').bold(),
        ),
      )
      .qFormat(true)
      .build();

  /// Light List: A table with minimal tableBorders, only horizontal lines.
  static Style get lightList => TableStyleBuilder.table('LightList')
      .names(<String, dynamic>{
        'Light List': LanguageCodes.englishUS,
        'Lista clara': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .tableWidth(5000, 'pct')
      .tableBorders(
        top: BorderStyle.single,
        bottom: BorderStyle.single,
        insideH: BorderStyle.single,
      ) // No vertical tableBorders
      .cellMargins(
        top: 0,
        bottom: 0,
        left: 7.2.ptToTwips(),
        right: 7.2.ptToTwips(),
      )
      .rowProperties(
          height: 1.7.inchesToLineSpacing(),
          heightRule: TableHeightRule.atLeast)
      .cellVerticalAlignment(Alignment.center)
      .rowBandSize('1')
      // First row with bottom border only
      .addConditionalStyle(
        ConditionalTableStyle(
            'firstRow',
            TableStyleBuilder.table('LightListFirstRow')
                .tableBorders(
                  bottom: BorderStyle.double,
                  bottomSize: 8,
                )
                .bold()),
      )
      // Last row with top border only (to separate footer)
      .addConditionalStyle(
        ConditionalTableStyle(
            'lastRow',
            TableStyleBuilder.table('LightListLastRow').tableBorders(
              top: BorderStyle.single,
              topSize: 8,
            )),
      )
      .qFormat(true)
      .build();

  /// Light Grid: A table with tableBorders on the grid lines only.
  static Style get lightGrid => TableStyleBuilder.table('LightGrid')
      .names(<String, dynamic>{
        'Light Grid': LanguageCodes.englishUS,
        'Cuadrícula clara': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .tableWidth(5000, 'pct')
      .tableBorders(
        insideH: BorderStyle.single,
        insideV: BorderStyle.single,
      ) // Only inner tableBorders
      .cellMargins(
        top: 0,
        bottom: 0,
        left: 7.2.ptToTwips(),
        right: 7.2.ptToTwips(),
      )
      .rowProperties(height: 300, heightRule: TableHeightRule.atLeast)
      .cellVerticalAlignment(Alignment.center)
      .rowBandSize('1')
      // First row with bold and bottom border
      .addConditionalStyle(
        ConditionalTableStyle(
            'firstRow',
            TableStyleBuilder.table('LightGridFirstRow')
                .tableBorders(
                  bottom: BorderStyle.single,
                  bottomSize: 8,
                )
                .bold()),
      )
      // Last row with top border
      .addConditionalStyle(
        ConditionalTableStyle(
            'lastRow',
            TableStyleBuilder.table('LightGridLastRow').tableBorders(
              top: BorderStyle.single,
              topSize: 8,
            )),
      )
      .qFormat(true)
      .build();

  /// Plain Table 1: A table with no tableBorders, only spacing.
  static Style get plainTable1 => TableStyleBuilder.table('PlainTable1')
      .names(<String, dynamic>{
        'Plain Table 1': LanguageCodes.englishUS,
        'Tabla simple 1': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .tableWidth(5000, 'pct')
      .cellMargins(
        top: 0,
        bottom: 0,
        left: 7.2.ptToTwips(),
        right: 7.2.ptToTwips(),
      )
      .rowProperties(height: 300, heightRule: TableHeightRule.atLeast)
      .cellVerticalAlignment(Alignment.center)
      .rowBandSize('1')
      // First row with bold text
      .addConditionalStyle(
        ConditionalTableStyle(
            'firstRow', TableStyleBuilder.table('PlainTable1FirstRow').bold()),
      )
      // Banded rows with light gray background
      .addConditionalStyle(
        ConditionalTableStyle(
            'band1H',
            TableStyleBuilder.table('PlainTable1Band1H')
                .tableShading(color: Color.rgb(0xF2F2F2))),
      )
      .qFormat(true)
      .build();

  /// Grid Table 4: A table with thick outside tableBorders and thin inside tableBorders.
  static Style get gridTable4 => TableStyleBuilder.table('GridTable4')
      .names(<String, dynamic>{
        'Grid Table 4': LanguageCodes.englishUS,
        'Tabla de cuadrícula 4': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .tableWidth(5000, 'pct')
      .tableBorders(
        top: BorderStyle.double,
        topSize: 1.5.ptToTwips(),
        bottom: BorderStyle.double,
        bottomSize: 1.5.ptToTwips(),
        left: BorderStyle.single,
        right: BorderStyle.single,
        insideH: BorderStyle.single,
        insideV: BorderStyle.single,
      )
      .cellMargins(
        top: 0,
        bottom: 0,
        left: 7.2.ptToTwips(),
        right: 7.2.ptToTwips(),
      )
      .rowProperties(
          height: 1.7.inchesToLineSpacing(),
          heightRule: TableHeightRule.atLeast)
      .cellVerticalAlignment(Alignment.center)
      .rowBandSize('1')
      // First row with dark shading and white bold text
      .addConditionalStyle(
        ConditionalTableStyle(
            'firstRow',
            TableStyleBuilder.table('GridTable4FirstRow')
                .tableShading(color: Color.rgb(0x366092))
                .runColor(Color.rgb(0xFFFFFF))
                .bold()),
      )
      // Banded rows with light blue shading
      .addConditionalStyle(
        ConditionalTableStyle(
          'band1H',
          TableStyleBuilder.table('GridTable4Band1H')
              .tableShading(color: Color.rgb(0xD9E2F3)),
        ),
      )
      .qFormat(true)
      .build();

  /// Grid Table 5 Dark: A table with a dark theme.
  static Style get gridTable5Dark => TableStyleBuilder.table('GridTable5Dark')
      .names(<String, dynamic>{
        'Grid Table 5 Dark': LanguageCodes.englishUS,
        'Tabla de cuadrícula 5 oscura': List<String>.from(<String>[
          LanguageCodes.spanishES,
          LanguageCodes.spanishMX,
        ]),
      })
      .tableWidth(5000, 'pct')
      .tableBorders(
        top: BorderStyle.single,
        bottom: BorderStyle.single,
        left: BorderStyle.single,
        right: BorderStyle.single,
        insideH: BorderStyle.single,
        insideV: BorderStyle.single,
      )
      .cellMargins(
        top: 0,
        bottom: 0,
        left: 7.2.ptToTwips(),
        right: 7.2.ptToTwips(),
      )
      .rowProperties(
          height: 1.7.inchesToLineSpacing(),
          heightRule: TableHeightRule.atLeast)
      .cellVerticalAlignment(Alignment.center)
      .rowBandSize('1')
      // First row with black background and white bold text
      .addConditionalStyle(
        ConditionalTableStyle(
            'firstRow',
            TableStyleBuilder.table('GridTable5DarkFirstRow')
                .tableShading(color: Color.rgb(0x000000))
                .runColor(Color.rgb(0xFFFFFF))
                .bold()),
      )
      // Even rows with dark gray background
      .addConditionalStyle(
        ConditionalTableStyle(
            'band1H',
            TableStyleBuilder.table('GridTable5DarkBand1H')
                .tableShading(color: Color.rgb(0x404040))
                .runColor(Color.rgb(0xFFFFFF))),
      )
      // Odd rows with lighter gray background
      .addConditionalStyle(
        ConditionalTableStyle(
            'band2H',
            TableStyleBuilder.table('GridTable5DarkBand2H')
                .tableShading(color: Color.rgb(0x808080))
                .runColor(Color.rgb(0xFFFFFF))),
      )
      .qFormat(true)
      .build();

  /// Returns a list of all standard table styles.
  static List<Style> get standardTableStyles => <Style>[
        tableGrid,
        lightShading,
        mediumShading1,
        mediumShading2,
        lightList,
        lightGrid,
        plainTable1,
        gridTable4,
        gridTable5Dark,
      ];

  static List<Style> get standardDocumentStyles => <Style>[
        normal,
        listParagraph,
        defaultParagraphFont,
        hyperlink,
        ...standardTableStyles,
        heading1,
        heading2,
        heading3,
        heading4,
        heading5,
        heading6,
      ];
}
