import '../../../docx.dart';

class EasyStyles {
  static Style get normal => StyleBuilder.paragraph('Normal')
      .name('Normal')
      .fontFamily('Times New Roman')
      .fontSize(12.ptToHalfPoints())
      .alignment(Alignment.left)
      .spacing(before: 0, after: 160)
      .lang(DocxLanguage(language: LanguageCodes.englishUS))
      .qFormat(true)
      .build();

  static Style get listParagraph => StyleBuilder.paragraph('ListParagraph')
      .name('List Paragraph')
      .basedOn('Normal')
      .keepNext(true)
      .keepLines(true)
      .activateWindowControl()
      .contextualSpacing(true)
      .qFormat(true)
      .build();

  static Style get defaultParagraphFont =>
      StyleBuilder.character('DefaultParagraphFont')
          .name('Default Paragraph Font')
          .defaultValue(true)
          .build();

  static Style get hyperlink => StyleBuilder.character('Hyperlink')
      .name('Hyperlink')
      .runColor(Color.rgb(0x0563C1))
      .underline()
      .build();

  static Style get heading1 => StyleBuilder.paragraph('Heading1')
      .name('Heading 1')
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
      .name('Heading 2')
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
      .name('Heading 3')
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
      .name('Heading 4')
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
      .name('Heading 5')
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
      .name('Heading 6')
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
      .name('Table Grid')
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
      .name('Light Shading')
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
          'band1Horz',
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
      .name('Medium Shading 1')
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
          'band1Horz',
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
      .name('Medium Shading 2')
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
          'band1Horz',
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
      .name('Light List')
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
      .name('Light Grid')
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
      .name('Plain Table 1')
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
            'band1Horz',
            TableStyleBuilder.table('PlainTable1Band1H')
                .tableShading(color: Color.rgb(0xF2F2F2))),
      )
      .qFormat(true)
      .build();

  /// Grid Table 4: A table with thick outside tableBorders and thin inside tableBorders.
  static Style get gridTable4 => TableStyleBuilder.table('GridTable4')
      .name('Grid Table 4')
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
          'band1Horz',
          TableStyleBuilder.table('GridTable4Band1H')
              .tableShading(color: Color.rgb(0xD9E2F3)),
        ),
      )
      .qFormat(true)
      .build();

  /// Grid Table 5 Dark: A table with a dark theme.
  static Style get gridTable5Dark => TableStyleBuilder.table('GridTable5Dark')
      .name('Grid Table 5 Dark')
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
            'band1Horz',
            TableStyleBuilder.table('GridTable5DarkBand1H')
                .tableShading(color: Color.rgb(0x404040))
                .runColor(Color.rgb(0xFFFFFF))),
      )
      // Odd rows with lighter gray background
      .addConditionalStyle(
        ConditionalTableStyle(
            'band2Horz',
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
