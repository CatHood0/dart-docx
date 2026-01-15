import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

Future<void> main() async {
  final File outFile = File('test_resources/advanced_tables.docx');

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
      section: DocumentLayout(
        size: pageSize,
        margins: margins,
      ),
      styles: DocumentStylesSheet.base().withNewStyles(
        <Style>[
          StyleBuilder.paragraph('Title')
              .name('Title')
              .fontSize(28.ptToHalfPoints())
              .fontFamily('Georgia')
              .bold()
              .alignment(Alignment.center)
              .qFormat(true)
              .spacing(
                before: 12.ptToTwips(),
                after: 6.ptToTwips(),
              )
              .uiPriority(20)
              .build(),
          StyleBuilder.paragraph('Subtitle')
              .name('Subtitle')
              .fontSize(20.ptToHalfPoints())
              .fontFamily('Georgia')
              .bold()
              .alignment(Alignment.center)
              .qFormat(true)
              .spacing(
                before: 12.ptToTwips(),
                after: 6.ptToTwips(),
              )
              .uiPriority(20)
              .build(),
        ],
      ),
    ),
    root: DocumentRoot(
      sections: <DocxTreeNode<dynamic>>[
        // Document title
        Paragraph.text(
          text: 'Advanced Table Examples in DOCX',
          runStyles: <Object>[
            BoldAttribute(),
            StyleBuilder.singularC().fontSize(16.ptToHalfPoints()).build(),
          ],
          styles: <Style>[
            Style.reference('title'),
          ],
        ),
        Paragraph.text(text: ''), // Space

        // 1. Basic simple table
        Paragraph.text(
          text: '1. Basic Simple Table (2x2)',
          runStyles: <Object>[BoldAttribute()],
        ),
        Paragraph.text(text: 'Basic table with two rows and two columns.'),
        _buildSimpleTable(),
        Paragraph.text(text: ''),

        // 2. Table with merged cells
        Paragraph.text(
          text: '2. Table with Merged Cells',
          runStyles: <Object>[BoldAttribute()],
        ),
        Paragraph.text(text: 'Example of gridSpan (colspan) and rowSpan.'),
        _buildMergedCellsTable(),
        Paragraph.text(text: ''),

        // 3. Table with complex content
        Paragraph.text(
          text: '3. Table with Diverse Content',
          runStyles: <Object>[BoldAttribute()],
        ),
        Paragraph.text(
            text: 'Cells with multiple paragraphs, lists, and styles.'),
        _buildComplexContentTable(),
        Paragraph.text(text: ''),

        // 4. Table with custom borders
        Paragraph.text(
          text: '4. Table with Custom Borders',
          runStyles: <Object>[BoldAttribute()],
        ),
        Paragraph.text(text: 'Borders of different styles and colors.'),
        _buildCustomBordersTable(),
        Paragraph.text(text: ''),

        // 5. Table with backgrounds and shading
        Paragraph.text(
          text: '5. Table with Backgrounds and Shading',
          runStyles: <Object>[BoldAttribute()],
        ),
        Paragraph.text(text: 'Cells with different background colors.'),
        _buildShadedTable(),
        Paragraph.text(text: ''),

        // 6. Table with vertical alignment
        Paragraph.text(
          text: '6. Table with Vertical Alignment',
          runStyles: <Object>[BoldAttribute()],
        ),
        Paragraph.text(
            text: 'Content vertically aligned in different ways.'),
        _buildVerticalAlignmentTable(),
        Paragraph.text(text: ''),

        // 7. Table with custom widths
        Paragraph.text(
          text: '7. Table with Custom Widths',
          runStyles: <Object>[BoldAttribute()],
        ),
        Paragraph.text(text: 'Columns with different widths.'),
        _buildCustomWidthTable(),
        Paragraph.text(text: ''),

        // 8. Table with fixed header
        Paragraph.text(
          text: '8. Table with Fixed Header',
          runStyles: <Object>[BoldAttribute()],
        ),
        Paragraph.text(
            text: 'Header row that repeats on each page.'),
        _buildHeaderTable(),
        Paragraph.text(text: ''),

        // 9. Table with auto layout
        Paragraph.text(
          text: '9. Table with Auto Layout',
          runStyles: <Object>[BoldAttribute()],
        ),
        Paragraph.text(
          text: 'Table that automatically adjusts to content.',
        ),
        _buildAutoFitTable(),
        Paragraph.text(text: ''),

        // 10. Nested table
        Paragraph.text(
          text: '10. Nested Table',
          runStyles: <Object>[BoldAttribute()],
        ),
        Paragraph.text(text: 'Example of a table inside a cell.'),
        _buildNestedTable(),
      ],
    ),
  );

  final Uint8List? bytes = await DocxPacker()
      .dynamicFontSearch(true)
      .noTrimRuns()
      .setNormalIfNeeded(true)
      .bytes(
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
    tableConfig: TableProperties(
      styles: <Style>[Style.reference('TableGrid')],
      width: 5000,
      widthType: TableWidthType.pct,
      alignment: Alignment.center,
    ),
    gridCols: <GridColumn>[
      GridColumn(width: 2500),
      GridColumn(width: 2500),
    ],
    rows: <TableRow>[
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 2500,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Header 1',
                runStyles: <Object>[BoldAttribute()],
                styles: <Style>[Style.reference('Subtitle')],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2500,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Header 2',
                runStyles: <Object>[BoldAttribute()],
                styles: <Style>[Style.reference('Subtitle')],
              ),
            ],
          ),
        ],
      ),
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 2500,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Content A',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2500,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Content B',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 2. Table with merged cells
Table _buildMergedCellsTable() {
  return Table(
    tableConfig: TableProperties(
      styles: <Style>[Style.reference('TableGrid')],
      width: 7000,
      widthType: TableWidthType.dxa,
    ),
    gridCols: <GridColumn>[
      GridColumn(width: 2000),
      GridColumn(width: 2000),
      GridColumn(width: 2000),
      GridColumn(width: 2000),
    ],
    rows: <TableRow>[
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
              gridSpan: 2,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Horizontally merged (colspan=2)',
                runStyles: <Object>[BoldAttribute()],
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Normal cell',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Normal cell',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
        ],
      ),
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
              rowSpan: 2,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Vertically merged (rowspan=2)',
                runStyles: <Object>[BoldAttribute()],
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Row 1',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
              gridSpan: 2,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Multiple merge',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
        ],
      ),
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          // Empty cell because it's merged from the previous row
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
              rowSpan: 0, // Continues the merge
            ),
            children: <DocxTreeNode<dynamic>>[],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Row 2',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Normal',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Normal',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 3. Table with complex content
Table _buildComplexContentTable() {
  return Table(
    tableConfig: TableProperties(
      styles: <Style>[Style.reference('TableGrid')],
      width: 8000,
      widthType: TableWidthType.dxa,
    ),
    gridCols: <GridColumn>[
      GridColumn(width: 4000),
      GridColumn(width: 4000),
    ],
    rows: <TableRow>[
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 800,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 4000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Text with multiple formats:',
                runStyles: <Object>[BoldAttribute()],
              ),
              Paragraph.text(text: ''),
              Paragraph.text(
                text: 'Normal text ',
              ),
              Paragraph(
                data: <RunBase<dynamic>>[
                  TextRun.text(text: 'Text in '),
                  TextRun.text(
                    text: 'bold',
                    styles: <Object>[BoldAttribute()],
                  ),
                  TextRun.text(text: ' and '),
                  TextRun.text(
                    text: 'italic',
                    styles: <Object>[ItalicAttribute()],
                  ),
                  TextRun.text(text: ' combined.'),
                ],
              ),
              Paragraph.text(text: ''),
              Paragraph.text(
                text: 'Underlined and strikethrough text:',
                runStyles: <Object>[UnderlineAttribute(), StrikeAttribute()],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 4000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'List inside a table:',
                runStyles: <Object>[BoldAttribute()],
              ),
              Paragraph.text(text: ''),
              Paragraph(
                data: <RunBase<dynamic>>[
                  TextRun.text(text: 'List item 1'),
                ],
                numbering: Numbering(
                  reference: 'unordered',
                  level: 0,
                  refId: 1,
                ),
              ),
              Paragraph(
                data: <RunBase<dynamic>>[
                  TextRun.text(text: 'List item 2 with longer text'),
                ],
                numbering: Numbering(
                  reference: 'unordered',
                  level: 0,
                  refId: 1,
                ),
              ),
              Paragraph(
                data: <RunBase<dynamic>>[
                  TextRun.text(text: 'Text '),
                  TextRun.text(
                    text: 'special',
                    styles: <Object>[
                      BoldAttribute(),
                      StyleBuilder.singularC()
                          .runColor(Color.rgb(0xFF0000))
                          .build(),
                    ],
                  ),
                ],
                numbering: Numbering(
                  reference: 'unordered',
                  level: 0,
                  refId: 1,
                ),
              ),
              Paragraph.text(text: ''),
              Paragraph.text(
                text: 'Final paragraph with right alignment',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.right).build(),
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
    tableConfig: TableProperties(
      width: 6000,
      widthType: TableWidthType.dxa,
      borders: TableBorders(
        top: TableBorder(
            style: BorderStyle.double, size: 8, color: Color.rgb(0xFF0000)),
        bottom: TableBorder(
            style: BorderStyle.double, size: 8, color: Color.rgb(0xFF0000)),
        left: TableBorder(
            style: BorderStyle.dashed, size: 4, color: Color.rgb(0x0000FF)),
        right: TableBorder(
            style: BorderStyle.dashed, size: 4, color: Color.rgb(0x0000FF)),
        insideHorizontal: TableBorder(style: BorderStyle.dotted, size: 2),
        insideVertical: TableBorder(style: BorderStyle.dotted, size: 2),
      ),
    ),
    gridCols: <GridColumn>[
      GridColumn(width: 3000),
      GridColumn(width: 3000),
    ],
    rows: <TableRow>[
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              borders: TableCellBorders(
                top: TableBorder(
                    style: BorderStyle.single,
                    size: 12,
                    color: Color.rgb(0x00FF00)),
                bottom: TableBorder(
                    style: BorderStyle.single,
                    size: 12,
                    color: Color.rgb(0x00FF00)),
              ),
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Thick green borders',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              borders: TableCellBorders(
                left: TableBorder(
                    style: BorderStyle.wave,
                    size: 6,
                    color: Color.rgb(0xFF00FF)),
                right: TableBorder(
                    style: BorderStyle.wave,
                    size: 6,
                    color: Color.rgb(0xFF00FF)),
              ),
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Wavy magenta borders',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
        ],
      ),
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              borders: TableCellBorders(
                top: TableBorder(
                    style: BorderStyle.dashDot,
                    size: 4,
                    color: Color.rgb(0xFFA500)),
                bottom: TableBorder(
                    style: BorderStyle.dashDot,
                    size: 4,
                    color: Color.rgb(0xFFA500)),
                left: TableBorder(
                    style: BorderStyle.dashDot,
                    size: 4,
                    color: Color.rgb(0xFFA500)),
                right: TableBorder(
                    style: BorderStyle.dashDot,
                    size: 4,
                    color: Color.rgb(0xFFA500)),
              ),
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'All orange borders',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              borders: TableCellBorders(
                top: TableBorder(style: BorderStyle.none),
                bottom: TableBorder(style: BorderStyle.none),
                left: TableBorder(style: BorderStyle.none),
                right: TableBorder(style: BorderStyle.none),
              ),
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'No borders',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
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
    tableConfig: TableProperties(
      width: 6000,
      widthType: TableWidthType.dxa,
    ),
    gridCols: <GridColumn>[
      GridColumn(width: 3000),
      GridColumn(width: 3000),
    ],
    rows: <TableRow>[
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              shading: Shading(
                fill: Color.rgb(0xFFCCCC),
                style: ShadingPattern.clear,
              ),
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Light red background',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              shading: Shading(
                fill: Color.rgb(0xCCFFCC),
                style: ShadingPattern.clear,
              ),
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Light green background',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
        ],
      ),
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              shading: Shading(
                fill: Color.rgb(0xCCCCFF),
                style: ShadingPattern.diagCross,
              ),
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Blue background with pattern',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
              shading: Shading(
                fill: Color.rgb(0xFFFFCC),
                style: ShadingPattern.horzStripe,
              ),
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Yellow background with stripes',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
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
    tableConfig: TableProperties(
      width: 6000,
      widthType: TableWidthType.dxa,
    ),
    gridCols: <GridColumn>[
      GridColumn(width: 2000),
      GridColumn(width: 2000),
      GridColumn(width: 2000),
    ],
    rows: <TableRow>[
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 1000,
          heightRule: TableHeightRule.exact,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
              verticalAlignment: VerticalAlignment.top,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Aligned top',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
              verticalAlignment: VerticalAlignment.center,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Aligned center',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
              verticalAlignment: VerticalAlignment.bottom,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Aligned bottom',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 7. Table with custom widths
Table _buildCustomWidthTable() {
  return Table(
    tableConfig: TableProperties(
      width: 10000,
      widthType: TableWidthType.dxa,
      alignment: Alignment.center,
    ),
    gridCols: <GridColumn>[
      GridColumn(width: 1000), // 10%
      GridColumn(width: 3000), // 30%
      GridColumn(width: 4000), // 40%
      GridColumn(width: 2000), // 20%
    ],
    rows: <TableRow>[
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 1000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: '10%',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 3000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: '30%',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 4000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: '40% (wider)',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2000,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: '20%',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
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
    tableConfig: TableProperties(
      width: 5000,
      widthType: TableWidthType.pct,
    ),
    gridCols: <GridColumn>[
      GridColumn(width: 2500),
      GridColumn(width: 2500),
    ],
    rows: <TableRow>[
      // Header row
      TableRow(
        rowConfig: TableStyleBuilder.singularTable()
            .rowProperties(
              height: 504,
              heightRule: TableHeightRule.atLeast,
              cantSplit: true,
            )
            .tableShading(color: Color.rgb(0xE6E6E6)),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 2500,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'HEADER 1',
                runStyles: <Object>[BoldAttribute()],
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 2500,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'HEADER 2',
                runStyles: <Object>[BoldAttribute()],
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
        ],
      ),
      // Data rows
      for (int i = 1; i <= 5; i++)
        TableRow(
          rowConfig: TableStyleBuilder.singularTable().rowProperties(
            height: 504,
            heightRule: TableHeightRule.atLeast,
          ),
          cells: <TableCell>[
            TableCell(
              cellConfig: TableCellConfig(
                width: 2500,
                widthType: TableWidthType.dxa,
              ),
              children: <DocxTreeNode<dynamic>>[
                Paragraph.text(
                  text: 'Data A$i',
                  styles: <Style>[
                    StyleBuilder.singularP()
                        .alignment(Alignment.center)
                        .build(),
                  ],
                ),
              ],
            ),
            TableCell(
              cellConfig: TableCellConfig(
                width: 2500,
                widthType: TableWidthType.dxa,
              ),
              children: <DocxTreeNode<dynamic>>[
                Paragraph.text(
                  text: 'Data B$i',
                  styles: <Style>[
                    StyleBuilder.singularP()
                        .alignment(Alignment.center)
                        .build(),
                  ],
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
    tableConfig: TableProperties(
      layout: true, // autofit
      width: 5000,
      widthType: TableWidthType.pct,
    ),
    gridCols: <GridColumn>[
      GridColumn(width: -1), // Auto width
      GridColumn(width: -1),
      GridColumn(width: -1),
    ],
    rows: <TableRow>[
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.auto,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              widthType: TableWidthType.auto,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Short text',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              widthType: TableWidthType.auto,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'A bit longer text',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              widthType: TableWidthType.auto,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text:
                    'Much longer text than the others to demonstrate autofit',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// 10. Nested table
Table _buildNestedTable() {
  return Table(
    tableConfig: TableProperties(
      width: 7000,
      widthType: TableWidthType.dxa,
    ),
    gridCols: <GridColumn>[
      GridColumn(width: 3500),
      GridColumn(width: 3500),
    ],
    rows: <TableRow>[
      TableRow(
        rowConfig: TableStyleBuilder.singularTable().rowProperties(
          height: 504,
          heightRule: TableHeightRule.atLeast,
        ),
        cells: <TableCell>[
          TableCell(
            cellConfig: TableCellConfig(
              width: 3500,
              widthType: TableWidthType.dxa,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text: 'Cell with nested table:',
                runStyles: <Object>[BoldAttribute()],
              ),
              // Nested table
              Table(
                tableConfig: TableProperties(
                  width: 3000,
                  widthType: TableWidthType.dxa,
                ),
                gridCols: <GridColumn>[
                  GridColumn(width: 1500),
                  GridColumn(width: 1500),
                ],
                rows: <TableRow>[
                  TableRow(
                    rowConfig: TableStyleBuilder.singularTable().rowProperties(
                      height: 300,
                      heightRule: TableHeightRule.atLeast,
                    ),
                    cells: <TableCell>[
                      TableCell(
                        cellConfig: TableCellConfig(
                          width: 1500,
                          widthType: TableWidthType.dxa,
                          shading: Shading(
                            fill: Color.rgb(0xE6F7FF),
                            style: ShadingPattern.clear,
                          ),
                        ),
                        children: <DocxTreeNode<dynamic>>[
                          Paragraph.text(
                            text: 'A1',
                            styles: <Style>[
                              StyleBuilder.singularP()
                                  .alignment(Alignment.center)
                                  .build(),
                            ],
                          ),
                        ],
                      ),
                      TableCell(
                        cellConfig: TableCellConfig(
                          width: 1500,
                          widthType: TableWidthType.dxa,
                          shading: Shading(
                            fill: Color.rgb(0xFFF7E6),
                            style: ShadingPattern.clear,
                          ),
                        ),
                        children: <DocxTreeNode<dynamic>>[
                          Paragraph.text(
                            text: 'A2',
                            styles: <Style>[
                              StyleBuilder.singularP()
                                  .alignment(Alignment.center)
                                  .build(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  TableRow(
                    rowConfig: TableStyleBuilder.singularTable().rowProperties(
                      height: 300,
                      heightRule: TableHeightRule.atLeast,
                    ),
                    cells: <TableCell>[
                      TableCell(
                        cellConfig: TableCellConfig(
                          width: 1500,
                          widthType: TableWidthType.dxa,
                          shading: Shading(
                            fill: Color.rgb(0xF7E6FF),
                            style: ShadingPattern.clear,
                          ),
                        ),
                        children: <DocxTreeNode<dynamic>>[
                          Paragraph.text(
                            text: 'B1',
                            styles: <Style>[
                              StyleBuilder.singularP()
                                  .alignment(Alignment.center)
                                  .build(),
                            ],
                          ),
                        ],
                      ),
                      TableCell(
                        cellConfig: TableCellConfig(
                          width: 1500,
                          widthType: TableWidthType.dxa,
                          shading: Shading(
                            fill: Color.rgb(0xE6FFE6),
                            style: ShadingPattern.clear,
                          ),
                        ),
                        children: <DocxTreeNode<dynamic>>[
                          Paragraph.text(
                            text: 'B2',
                            styles: <Style>[
                              StyleBuilder.singularP()
                                  .alignment(Alignment.center)
                                  .build(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          TableCell(
            cellConfig: TableCellConfig(
              width: 3500,
              widthType: TableWidthType.dxa,
              verticalAlignment: VerticalAlignment.center,
            ),
            children: <DocxTreeNode<dynamic>>[
              Paragraph.text(
                text:
                    'This cell contains normal content next to a nested table in the left cell.',
                styles: <Style>[
                  StyleBuilder.singularP().alignment(Alignment.center).build(),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
