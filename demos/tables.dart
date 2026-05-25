import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

Future<void> main() async {
  final File outFile = File('test_resources/tables.docx');

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
      title: 'Advanced Table Examples',
      numberingOptions: NumberingStore.defaultNumberings,
      section: DocumentLayout(
        size: pageSize,
        margins: margins,
      ),
      styles: DocumentStyles.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('Title')
              .name('Title')
              .fontSize(Point(28))
              .fontFamily('Georgia')
              .bold()
              .alignment(Alignment.center)
              .qFormat(true)
              .spacing(
                before: Point(12),
                after: Point(6),
              )
              .uiPriority(20)
              .build(),
          StyleBuilder.paragraph('Subtitle')
              .name('Subtitle')
              .fontSize(Point(20))
              .fontFamily('Georgia')
              .bold()
              .alignment(Alignment.center)
              .qFormat(true)
              .spacing(
                before: Point(12),
                after: Point(6),
              )
              .uiPriority(20)
              .build(),
          StyleBuilder.paragraph('body')
              .name('Body')
              .fontFamily('Georgia')
              .alignment(Alignment.center)
              .uiPriority(18)
              .build(),
        ],
      ),
    ),
    root: DocxRoot(
      sections: <DocxNode<dynamic>>[
        // Document title
        Paragraph.text(
          text: 'Advanced Table Examples in DOCX',
          textStyle: TextStyle(
            fontSize: Point(16),
          ),
          styles: <Style>[
            Style.ref('title'),
          ],
        ),
        Run.lineBreak(),
        // 1. Basic simple table
        Paragraph.text(
          text: '1. Basic Simple Table (2x2)',
          textStyle: TextStyle(bold: true),
        ),
        Paragraph.text(text: 'Basic table with two rows and two columns.'),
        _buildSimpleTable(),
        Run.lineBreak(),

        // 2. Table with merged cells
        Paragraph.text(
          text: '2. Table with Merged Cells',
          textStyle: TextStyle(bold: true),
        ),
        Paragraph.text(text: 'Example of gridSpan (colspan) and rowSpan.'),
        _buildMergedCellsTable(),
        Run.lineBreak(),

        // 3. Table with complex content
        Paragraph.text(
          text: '3. Table with Diverse Content',
          textStyle: TextStyle(bold: true),
        ),
        Paragraph.text(
            text: 'Cells with multiple paragraphs, lists, and styles.'),
        _buildComplexContentTable(),
        Run.lineBreak(),

        // 4. Table with custom borders
        Paragraph.text(
          text: '4. Table with Custom Borders',
          textStyle: TextStyle(bold: true),
        ),
        Paragraph.text(text: 'Borders of different styles and colors.'),
        _buildCustomBordersTable(),
        Run.lineBreak(),

        // 5. Table with backgrounds and shading
        Paragraph.text(
          text: '5. Table with Backgrounds and Shading',
          textStyle: TextStyle(bold: true),
        ),
        Paragraph.text(text: 'Cells with different background colors.'),
        _buildShadedTable(),
        Run.lineBreak(),

        // 6. Table with vertical alignment
        Paragraph.text(
          text: '6. Table with Vertical Alignment',
          textStyle: TextStyle(bold: true),
        ),
        Paragraph.text(text: 'Content vertically aligned in different ways.'),
        _buildVerticalAlignmentTable(),
        Run.lineBreak(),

        // 7. Table with custom widths
        Paragraph.text(
          text: '7. Table with Custom Widths',
          textStyle: TextStyle(bold: true),
        ),
        Paragraph.text(text: 'Columns with different widths.'),
        _buildCustomWidthTable(),
        Run.lineBreak(),

        // 8. Table with fixed header
        Paragraph.text(
          text: '8. Table with Fixed Header',
          textStyle: TextStyle(bold: true),
        ),
        Paragraph.text(text: 'Header row that repeats on each page.'),
        _buildHeaderTable(),
        Run.lineBreak(),

        // 9. Table with auto layout
        Paragraph.text(
          text: '9. Table with Auto Layout',
          textStyle: TextStyle(bold: true),
        ),
        Paragraph.text(
          text: 'Table that automatically adjusts to content.',
        ),
        _buildAutoFitTable(),
        Run.lineBreak(),

        // 10. Nested table
        Paragraph.text(
          text: '10. Nested Table',
          textStyle: TextStyle(bold: true),
        ),
        Paragraph.text(text: 'Example of a table inside a cell.'),
        _buildNestedTable(),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .autoRegisterFonts(true)
      .noTrimRuns()
      .normalStyleIfNeeded()
      .logPath(DocxPaths.documentFilePath)
      .execute(
        doc,
        applyCustomTheme: false,
      );

  if (bytes != null) {
    await outFile.writeAsBytes(bytes);
  } else {
    stderr.writeln('Error generating the .docx document');
  }
}

Table _buildSimpleTable() {
  return Table(
    id: 'table-1',
    tableProperties: TableProperties.expand(
      styles: <Style>[Style.ref('TableGrid')],
      alignment: Alignment.center,
    ),
    columns: GridColumn(width: 2500).repeat(2),
    rows: <TableRow>[
      TableRow.header(
        height: Dxa(504),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          TableCell.one(
            cellConfig: TableCellConfig.auto(
                verticalAlignment: VerticalAlignment.center),
            child: Paragraph.text(
              text: 'Header 1',
              textStyle: TextStyle(bold: true),
              styles: <Style>[Style.ref('Subtitle')],
            ),
          ),
          TableCell.one(
            cellConfig: TableCellConfig.auto(
                verticalAlignment: VerticalAlignment.center),
            child: Paragraph.text(
              text: 'Header 2',
              textStyle: TextStyle(bold: true),
              align: Alignment.center,
              styles: <Style>[Style.ref('Subtitle')],
            ),
          ),
        ],
      ),
      TableRow(
        height: Dxa(504),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          TableCell.one(
            cellConfig: TableCellConfig.auto(
                verticalAlignment: VerticalAlignment.center),
            child: Paragraph.text(
              text: 'Content A',
              align: Alignment.center,
            ),
          ),
          TableCell.one(
            cellConfig: TableCellConfig.auto(
                verticalAlignment: VerticalAlignment.center),
            child: Paragraph.text(
              text: 'Content B',
              align: Alignment.center,
            ),
          ),
        ],
      ),
    ],
  );
}

/// 2. Table with merged cells
Table _buildMergedCellsTable() {
  return Table(
    id: 'table-2',
    tableProperties: TableProperties(
      styles: <Style>[Style.ref('TableGrid')],
      width: 7000,
      widthType: TableWidthType.dxa,
    ),
    columns: GridColumn(width: 2000).repeat(3),
    rows: <TableRow>[
      TableRow(
        height: Dxa(504),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          TableCell.one(
            cellConfig: TableCellConfig.dxa(
              width: 2000,
              columnSpan: 2,
            ),
            child: Paragraph.text(
              text: 'Horizontally merged (colspan=2)',
              textStyle: TextStyle(bold: true),
              align: Alignment.center,
            ),
          ),
          ...TableCell.one(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
            ),
            child: Paragraph.text(
              text: 'Normal cell',
              align: Alignment.center,
            ),
          ).repeat(2).cast(),
        ],
      ),
      TableRow(
        height: Dxa(504),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          TableCell.one(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
              rowSpan: 2,
            ),
            child: Paragraph.text(
              text: 'Vertically merged (rowspan=2)',
              textStyle: TextStyle(bold: true),
              align: Alignment.center,
            ),
          ),
          TableCell.one(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
            ),
            child: Paragraph.text(
              text: 'Row 1',
              align: Alignment.center,
            ),
          ),
          TableCell.one(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
              columnSpan: 2,
            ),
            child: Paragraph.text(
              text: 'Multiple merge',
              align: Alignment.center,
            ),
          ),
        ],
      ),
      TableRow(
        height: Dxa(504),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          // Empty cell because it's merged from the previous row
          TableCell.empty(cellConfig: TableCellConfig.dxa(width: 2000)),
          TableCell.one(
            cellConfig: TableCellConfig.dxa(width: 2000, rowSpan: 0),
            child: Paragraph.text(
              text: 'Row 2',
              align: Alignment.center,
            ),
          ),
          TableCell.one(
            cellConfig: TableCellConfig.dxa(width: 2000),
            child: Paragraph.text(
              text: 'Normal',
              align: Alignment.center,
            ),
          ),
        ],
      ),
    ],
  );
}

//TODO: change TableCell to use TableCell.one when needed
// i can do it, but it's boring at this point  changing
// barely 500 lines just for that
/// 3. Table with complex content
Table _buildComplexContentTable() {
  return Table(
    id: 'table-3',
    tableProperties: TableProperties(
      styles: <Style>[Style.ref('TableGrid')],
      width: 8000,
      widthType: TableWidthType.dxa,
    ),
    columns: GridColumn(width: 4000).repeat(2),
    rows: <TableRow>[
      TableRow(
        height: Dxa(800),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig.dxa(width: 4000),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: 'Text with multiple formats:',
                textStyle: TextStyle(bold: true),
              ),
              Run.lineBreak(),
              Paragraph.text(
                text: 'Normal text ',
              ),
              Paragraph(
                children: <RunBase<dynamic>>[
                  TextRun.text(text: 'Text in '),
                  TextRun.text(
                    text: 'bold',
                    textStyle: TextStyle(bold: true),
                  ),
                  TextRun.text(text: ' and '),
                  TextRun.text(
                    text: 'italic',
                    textStyle: TextStyle(italic: true),
                  ),
                  TextRun.text(text: ' combined.'),
                ],
              ),
              Run.lineBreak(),
              Paragraph.text(
                text: 'Underlined and strikethrough text:',
                textStyle: TextStyle(
                  underline: true,
                  strikethrough: true,
                ),
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 4000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: 'List inside a table:',
                textStyle: TextStyle(bold: true),
              ),
              Run.lineBreak(),
              Paragraph.text(
                text: 'List item 1',
                styles: <Style>[Style.ref('ListParagraph')],
                numbering: Numbering(
                  reference: 'unordered',
                  level: 0,
                  refId: 1,
                ),
              ),
              Paragraph.text(
                text: 'List item 2 with longer text',
                styles: <Style>[Style.ref('ListParagraph')],
                numbering: Numbering(
                  reference: 'unordered',
                  level: 0,
                  refId: 3,
                ),
              ),
              Paragraph(
                children: <RunBase<dynamic>>[
                  TextRun.text(text: 'Text '),
                  TextRun.text(
                    text: 'special',
                    textStyle: TextStyle(
                      bold: true,
                      fontColor: Color(0xFF0000),
                    ),
                  ),
                ],
                styles: <Style>[Style.ref('ListParagraph')],
                numbering: Numbering(
                  reference: 'unordered',
                  level: 0,
                  refId: 2,
                ),
              ),
              Run.lineBreak(),
              Paragraph.text(
                text: 'Final paragraph with right alignment',
                styles: <Style>[
                  StyleBuilder.up().alignment(Alignment.right).build(),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 4. Table with custom borders
Table _buildCustomBordersTable() {
  return Table(
    id: 'table-4',
    tableProperties: TableProperties(
      width: 6000,
      widthType: TableWidthType.dxa,
      borders: TableBorders.symmetric(
        vertical: BorderSide(
          style: BorderStyle.double,
          size: Point(4),
          color: Color(0xFF0000),
        ),
        horizontal: BorderSide(
          style: BorderStyle.dashed,
          size: Point(8),
          color: Color(0x0000FF),
        ),
        insideHorizontal: BorderSide(style: BorderStyle.dotted, size: Point(2)),
        insideVertical: BorderSide(style: BorderStyle.dotted, size: Point(2)),
      ),
    ),
    columns: GridColumn(width: 3000).repeat(2),
    rows: <TableRow>[
      TableRow(
        height: Dxa(504),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              borders: TableCellBorders.symmetric(
                vertical: BorderSide(
                  style: BorderStyle.single,
                  size: Point(12),
                  color: Color(0x00FF00),
                ),
              ),
            ),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: 'Thick green borders',
                align: Alignment.center,
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              borders: TableCellBorders.symmetric(
                horizontal: BorderSide(
                  style: BorderStyle.wave,
                  size: Point(6),
                  color: Color(0xFF00FF),
                ),
              ),
            ),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: 'Wavy magenta borders',
                align: Alignment.center,
              ),
            ],
          ),
        ],
      ),
      TableRow(
        height: Point(504),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig.dxa(
              width: 3000,
              borders: TableCellBorders.all(
                BorderSide(
                  style: BorderStyle.dashDot,
                  size: Point(4),
                  color: Color(0xFFA500),
                ),
              ),
            ),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: 'All orange borders',
                align: Alignment.center,
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              borders: TableCellBorders.all(BorderSide.none()),
            ),
            children: <DocxNode<dynamic>>[
              Paragraph.text(text: 'No borders', align: Alignment.center),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 5. Table with backgrounds and shading
Table _buildShadedTable() {
  return Table(
    id: 'table-5',
    tableProperties: TableProperties(
      width: 6000,
      widthType: TableWidthType.dxa,
    ),
    columns: GridColumn(width: 3000).repeat(2),
    rows: <TableRow>[
      TableRow(
        height: Dxa(504),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          TableCell.one(
            cellConfig: TableCellConfig.dxa(
              width: 3000,
              shading: Shading(
                fill: Color(0xFFCCCC),
                style: ShadingPattern.clear,
              ),
            ),
            child: Paragraph.text(
              text: 'Light red background',
              align: Alignment.center,
            ),
          ),
          TableCell.one(
            cellConfig: TableCellConfig.dxa(
              width: 3000,
              shading: Shading.clear(fill: Color(0xCCFFCC)),
            ),
            child: Paragraph.text(
              text: 'Light green background',
              align: Alignment.center,
            ),
          ),
        ],
      ),
      TableRow(
        height: Dxa(504),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              shading: Shading.diagonalCross(fill: Color(0xCCCCFF)),
            ),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: 'Blue background with pattern',
                align: Alignment.center,
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              shading: Shading.horizontalStripe(fill: Color(0xFFFFCC)),
            ),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: 'Yellow background with stripes',
                align: Alignment.center,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 6. Table with vertical alignment
Table _buildVerticalAlignmentTable() {
  return Table(
    id: 'table-6',
    tableProperties: TableProperties(widthType: TableWidthType.auto),
    columns: GridColumn.cm(width: 200).repeat(3),
    rows: <TableRow>[
      TableRow(
        height: Dxa(780),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          TableCell.one(
            cellConfig: TableCellConfig.dxa(
              width: 2000,
              verticalAlignment: VerticalAlignment.top,
            ),
            child: Paragraph.text(
              text: 'Aligned top',
              align: Alignment.center,
            ),
          ),
          TableCell.one(
            cellConfig: TableCellConfig.dxa(
              width: 2000,
              verticalAlignment: VerticalAlignment.center,
            ),
            child: Paragraph.text(
              text: 'Aligned center',
              align: Alignment.center,
            ),
          ),
          TableCell.one(
            cellConfig: TableCellConfig.dxa(
              width: 2000,
              verticalAlignment: VerticalAlignment.bottom,
            ),
            child: Paragraph.text(
              text: 'Aligned bottom',
              align: Alignment.center,
            ),
          ),
        ],
      ),
    ],
  );
}

/// 7. Table with custom widths
Table _buildCustomWidthTable() {
  return Table(
    id: 'table-7',
    tableProperties: TableProperties(
      widthType: TableWidthType.auto,
      alignment: Alignment.center,
    ),
    columns: <GridColumn>[
      GridColumn(width: 1000), // 10%
      GridColumn(width: 3000), // 30%
      GridColumn(width: 4000), // 40%
      GridColumn(width: 2000), // 20%
    ],
    rows: <TableRow>[
      TableRow(
        height: Dxa(504),
        heightRule: TableHeightRule.atLeast,
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig.dxa(width: 1000),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: '10%',
                align: Alignment.center,
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig.dxa(width: 3000),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: '30%',
                align: Alignment.center,
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig.dxa(width: 4000),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: '40% (wider)',
                align: Alignment.center,
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig.dxa(width: 2000),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: '20%',
                align: Alignment.center,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 8. Table with fixed header
Table _buildHeaderTable() {
  return Table(
    id: 'table-8',
    tableProperties: TableProperties(
      width: 5000,
      widthType: TableWidthType.pct,
    ),
    columns: GridColumn(width: 2500).repeat(2),
    rows: <TableRow>[
      // Header row
      TableRow(
        isHeader: true,
        heightRule: TableHeightRule.auto,
        canSplit: false,
        cells: <TableCell>[
          TableCell.one(
            cellConfig: TableCellConfig(
              width: 2500,
              widthType: TableWidthType.dxa,
              shading: Shading.clear(
                color: Color(0xE6E6E6),
              ),
            ),
            child: Paragraph.text(
              text: 'HEADER 1',
              align: Alignment.center,
              textStyle: TextStyle(bold: true),
            ),
          ),
          TableCell.one(
            cellConfig: TableCellConfig(
              width: 2500,
              widthType: TableWidthType.dxa,
              shading: Shading.clear(
                color: Color(0xE6E6E6),
              ),
            ),
            child: Paragraph.text(
              text: 'HEADER 2',
              textStyle: TextStyle(bold: true),
              align: Alignment.center,
            ),
          ),
        ],
      ),
      for (int i = 1; i <= 5; i++)
        TableRow(
          height: Dxa(504),
          heightRule: TableHeightRule.atLeast,
          cells: <TableCell>[
            TableCell.one(
              cellConfig: TableCellConfig(
                width: 2500,
                widthType: TableWidthType.dxa,
              ),
              child: Paragraph.text(
                text: 'Data A$i',
                align: Alignment.center,
              ),
            ),
            TableCell(
              cellConfig: TableCellConfig.dxa(width: 2500),
              children: <DocxNode<dynamic>>[
                Paragraph.text(
                  text: 'Data B$i',
                  align: Alignment.center,
                ),
              ],
            ),
          ],
        ),
    ],
  );
}

/// 9. Table with auto layout
Table _buildAutoFitTable() {
  return Table(
    id: 'table-9',
    tableProperties: TableProperties(
      layout: true,
      width: 5000,
      widthType: TableWidthType.pct,
    ),
    columns: GridColumn.intrintric().repeat(3),
    rows: <TableRow>[
      TableRow(
        height: Dxa(504),
        heightRule: TableHeightRule.auto,
        cells: <TableCell>[
          TableCell.one(
            cellConfig: TableCellConfig.auto(),
            child: Paragraph.text(
              text: 'Short text',
              align: Alignment.center,
            ),
          ),
          TableCell.one(
            cellConfig: TableCellConfig.auto(),
            child: Paragraph.text(
              text: 'A bit longer text',
              align: Alignment.center,
            ),
          ),
          TableCell.one(
            cellConfig: TableCellConfig.auto(),
            child: Paragraph.text(
              text: 'Much longer text than the others to demonstrate autofit',
              align: Alignment.center,
            ),
          ),
        ],
      ),
    ],
  );
}

/// 10. Nested table
Table _buildNestedTable() {
  return Table(
    id: 'table-10',
    tableProperties: TableProperties(
      width: 7000,
      widthType: TableWidthType.dxa,
    ),
    columns: GridColumn(width: 3500).repeat(2),
    rows: <TableRow>[
      TableRow(
        height: Dxa(504),
        heightRule: TableHeightRule.auto,
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig.dxa(width: 3500),
            children: <DocxNode<dynamic>>[
              Paragraph.text(
                text: 'Cell with nested table:',
                textStyle: TextStyle(bold: true),
              ),
              Table(
                tableProperties: TableProperties(
                  width: 3000,
                  widthType: TableWidthType.dxa,
                ),
                columns: GridColumn(width: 1500).repeat(2),
                rows: <TableRow>[
                  TableRow(
                    height: Dxa(300),
                    heightRule: TableHeightRule.atLeast,
                    cells: <TableCell>[
                      TableCell.one(
                        cellConfig: TableCellConfig(
                          width: 1500,
                          widthType: TableWidthType.dxa,
                          shading: Shading.clear(fill: Color(0xE6F7FF)),
                        ),
                        child: Paragraph.text(
                          text: 'A1',
                          align: Alignment.center,
                        ),
                      ),
                      TableCell.one(
                        cellConfig: TableCellConfig(
                          width: 1500,
                          widthType: TableWidthType.dxa,
                          shading: Shading.clear(fill: Color(0xFFF7E6)),
                        ),
                        child: Paragraph.text(
                          text: 'A2',
                          align: Alignment.center,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    height: Dxa(300),
                    heightRule: TableHeightRule.auto,
                    cells: <TableCell>[
                      TableCell.one(
                        cellConfig: TableCellConfig.dxa(
                          width: 1500,
                          shading: Shading.clear(fill: Color(0xF7E6FF)),
                        ),
                        child: Paragraph.text(
                          text: 'B1',
                          align: Alignment.center,
                        ),
                      ),
                      TableCell.one(
                        cellConfig: TableCellConfig(
                          width: 1500,
                          widthType: TableWidthType.dxa,
                          shading: Shading.clear(fill: Color(0xE6FFE6)),
                        ),
                        child: Paragraph.text(
                          text: 'B2',
                          align: Alignment.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          TableCell.one(
            cellConfig: TableCellConfig.dxa(
              width: 3500,
              verticalAlignment: VerticalAlignment.center,
            ),
            child: Paragraph.text(
              text: 'This cell contains normal content next to '
                  'a nested table in the left cell.',
              align: Alignment.center,
            ),
          ),
        ],
      ),
    ],
  );
}
