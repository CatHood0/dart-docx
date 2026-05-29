import 'dart:io';
import 'dart:typed_data';
import 'package:docx/docx.dart';

/// Newspaper Demo showing multi-column layout with:
/// - 2-column layout using PageColumn
/// - Headlines, articles, and sidebar content
/// - Style references and StyleBuilder patterns
Future<void> main() async {
  final File outFile = File('test_resources/newspaper.docx');

  final PageSize pageSize = PageSize.letter;
  final DocumentMargins margins = DocumentMargins.fromCm(
    top: 2.0,
    right: 1.5,
    left: 1.5,
    bottom: 1.5,
    header: 1.0,
    footer: 1.0,
  );

  final DocxDocument doc = DocxDocument(
    options: DocumentOptions.standard(
      title: 'Daily News',
      section: DocumentLayout(
        size: pageSize,
        margins: margins,
        columns: ColumnOptions(
          numColumns: 2,
          equalWidth: false,
          columnWidths: <ColumnWidth>[
            ColumnWidth.points(width: 320.0, spaceAfter: 18),
            ColumnWidth.points(width: 170.0, spaceAfter: 0),
          ],
        ),
      ),
      styles: DocumentStyles.base(),
    ),
    root: RootBody(
      sections: <DocxNode<dynamic>>[
        Paragraph(
          children: <RunBase<dynamic>>[
            TextRun.text(
              text: 'THE DAILY NEWS',
              textStyle: TextStyle(
                fontSize: Point(28),
                fontFamily: 'Georgia',
              ),
            ),
          ],
          alignment: Alignment.center,
          textStyle: TextStyle(
            spacingAfter: Point(10),
          ),
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            TextRun.text(
              text: 'Monday, January 15, 2024  |  Volume CXXIII, No. 42',
              textStyle: TextStyle(
                fontSize: Point(10),
                fontFamily: 'Georgia',
                italic: true,
              ),
            ),
          ],
          alignment: Alignment.center,
          textStyle: TextStyle(
            spacingAfter: Point(4),
          ),
        ),

        // Thick separator line
        //TODO: create divider object
        Paragraph.text(
          text: '_______________________________________________',
          textStyle: TextStyle(
            spacingAfter: Point(5),
          ),
        ),

        Paragraph(
          children: <RunBase<dynamic>>[
            TextRun.text(
              text: 'MAJOR BREAKTHROUGH IN RENEWABLE ENERGY RESEARCH',
              textStyle: TextStyle(
                fontSize: Point(22),
                fontFamily: 'Georgia',
              ),
            ),
          ],
          alignment: Alignment.center,
          textStyle: TextStyle(
            spacingBefore: Point(5),
            spacingAfter: Point(7),
          ),
        ),

        // Subheadline
        Paragraph(
          children: <RunBase<dynamic>>[
            TextRun.text(
              text: 'Scientists announce revolutionary solar cell technology',
              textStyle: TextStyle(
                fontSize: Point(12),
                fontFamily: 'Georgia',
              ),
            ),
          ],
          alignment: Alignment.center,
          textStyle: TextStyle(
            spacingAfter: Point(10),
          ),
        ),

        // Byline
        Align(
          alignment: Alignment.center,
          child: Paragraph.text(
            text: 'By Jane Smith, Science Editor',
            textStyle: TextStyle(
              fontSize: Point(9),
              fontFamily: 'Georgia',
              spacingAfter: Point(5),
            ),
          ),
        ),

        Column(
          children: <DocxNode<dynamic>>[
            // Article 1: Main Story
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(text: _article1Paragraph1),
              ],
              textStyle: TextStyle(
                fontSize: Point(10),
                fontFamily: 'Georgia',
                firstLineIndent: Inch(0.5),
                spacingAfter: Point(5),
              ),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: _article1Paragraph2,
                ),
              ],
              textStyle: TextStyle(
                fontSize: Point(10),
                fontFamily: 'Georgia',
                spacingAfter: Point(5),
              ),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: _article1Paragraph3,
                ),
              ],
              textStyle: TextStyle(
                fontSize: Point(10),
                fontFamily: 'Georgia',
                spacingAfter: Point(5),
              ),
            ),

            // Section heading
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'LOCAL NEWS',
                ),
              ],
              textStyle: TextStyle(
                bold: true,
                fontSize: Point(12),
                fontFamily: 'Georgia',
                spacingBefore: Point(1),
                spacingAfter: Point(5),
              ),
            ),

            // Local news item
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'City Council Approves New Park Project',
                ),
              ],
              textStyle: TextStyle(
                bold: true,
                fontSize: Point(11),
                fontFamily: 'Georgia',
                spacingAfter: Point(5),
              ),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: _localNewsText1,
                ),
              ],
              textStyle: TextStyle(
                fontSize: Point(10),
                fontFamily: 'Georgia',
                spacingAfter: Point(5),
              ),
            ),

            // Another local news item
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'School District Announces Summer Programs',
                ),
              ],
              textStyle: TextStyle(
                bold: true,
                fontSize: Point(11),
                fontFamily: 'Georgia',
                spacingAfter: Point(5),
              ),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: _localNewsText2,
                ),
              ],
              textStyle: TextStyle(
                fontSize: Point(11),
                fontFamily: 'Georgia',
                spacingAfter: Point(5),
              ),
            ),

            // Sports section
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'SPORTS',
                ),
              ],
              textStyle: TextStyle(
                bold: true,
                fontSize: Point(12),
                fontFamily: 'Georgia',
                spacingBefore: Point(3),
                spacingAfter: Point(5),
              ),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'Tigers Win Championship Game',
                ),
              ],
              textStyle: TextStyle(
                bold: true,
                fontSize: Point(11),
                fontFamily: 'Georgia',
                spacingBefore: Point(10),
                spacingAfter: Point(5),
              ),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: _sportsText1,
                ),
              ],
              textStyle: TextStyle(
                fontSize: Point(10),
                fontFamily: 'Georgia',
                spacingAfter: Point(10),
              ),
            ),
          ],
        ),

        Column(
          children: <DocxNode<dynamic>>[
            // Weather Box
            WeatherBox(),

            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'OPINION',
                ),
              ],
              textStyle: TextStyle(
                bold: true,
                fontSize: Point(10),
                fontFamily: 'Georgia',
                spacingBefore: Point(10),
                spacingAfter: Point(5),
              ),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'The Future of Democracy',
                ),
              ],
              textStyle: TextStyle(
                bold: true,
                italic: true,
                fontSize: Point(11),
                fontFamily: 'Georgia',
                spacingBefore: Point(20),
                spacingAfter: Point(10),
              ),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: _opinionText1,
                ),
              ],
              textStyle: TextStyle(
                fontSize: Point(10),
                fontFamily: 'Georgia',
                spacingAfter: Point(10),
              ),
            ),

            // Business Section
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'BUSINESS',
                ),
              ],
              textStyle: TextStyle(
                bold: true,
                fontSize: Point(12),
                fontFamily: 'Georgia',
                spacingBefore: Point(20),
                spacingAfter: Point(5),
              ),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'Stock Market Reaches New Highs',
                ),
              ],
              textStyle: TextStyle(
                bold: true,
                fontSize: Point(11),
                fontFamily: 'Georgia',
                spacingBefore: Point(10),
                spacingAfter: Point(10),
              ),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: _businessText1,
                ),
              ],
              textStyle: TextStyle(
                fontSize: Point(10),
                fontFamily: 'Georgia',
                spacingAfter: Point(10),
              ),
            ),

            // Classifieds Section
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: 'CLASSIFIEDS',
                ),
              ],
              textStyle: TextStyle(
                bold: true,
                fontSize: Point(12),
                fontFamily: 'Georgia',
                spacingBefore: Point(20),
                spacingAfter: Point(10),
              ),
            ),
            Paragraph(
              children: <RunBase<dynamic>>[
                TextRun.text(
                  text: _classifiedsText,
                ),
              ],
              textStyle: TextStyle(
                fontSize: Point(10),
                fontFamily: 'Georgia',
                spacingAfter: Point(5),
              ),
            ),

            QuoteBox(),
          ],
        ),
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
    stderr.writeln('Failed to generate newspaper.docx');
    exit(1);
  }
}

class WeatherBox extends StatelessWidget {
  @override
  DocxNode<dynamic> build() {
    /// Builds a weather information box using a table
    return Table(
      tableProperties: TableProperties(
        width: 2700,
        widthType: TableWidthType.dxa,
        borders: TableBorders.symmetric(
          vertical: BorderSide(
            style: BorderStyle.single,
            size: Point(8),
            color: Colors.black,
          ),
          horizontal: BorderSide(
            style: BorderStyle.single,
            size: Point(8),
            color: Colors.black,
          ),
        ),
      ),
      columns: GridColumn(width: 800).repeat(2),
      rows: <TableRow>[
        TableRow(
          cells: <TableCell>[
            TableCell.one(
              cellConfig: TableCellConfig.dxa(width: 800),
              child: Paragraph.text(
                text: 'WEATHER',
                textStyle: TextStyle(
                  bold: true,
                  fontSize: Point(10),
                  fontFamily: 'Georgia',
                ),
                align: Alignment.center,
              ),
            ),
            TableCell.one(
              cellConfig: TableCellConfig.dxa(width: 800),
              child: Paragraph.text(
                text: '5-DAY FORECAST',
                textStyle: TextStyle(
                  bold: true,
                  fontSize: Point(10),
                  fontFamily: 'Georgia',
                ),
                align: Alignment.center,
              ),
            ),
          ],
        ),
        TableRow(
          cells: <TableCell>[
            TableCell.one(
              cellConfig: TableCellConfig.dxa(width: 800),
              child: Column(
                children: [
                  Text(
                    'Sunny',
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: Point(9),
                      fontFamily: 'Georgia',
                    ),
                  ),
                  Text(
                    '72F',
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: Point(9),
                      fontFamily: 'Georgia',
                    ),
                  ),
                ],
              ),
            ),
            TableCell.one(
              cellConfig: TableCellConfig.dxa(width: 800),
              child: Column(
                children: [
                  Text(
                    'Mon: 72F',
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: Point(9),
                      fontFamily: 'Georgia',
                    ),
                  ),
                  Text(
                    'Tue: 68F',
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: Point(9),
                      fontFamily: 'Georgia',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class QuoteBox extends StatelessWidget {
  @override
  DocxNode<dynamic> build() {
    return Table(
      tableProperties: TableProperties(
        width: 2000,
        widthType: TableWidthType.dxa,
        borders: TableBorders.all(
          BorderSide(
            style: BorderStyle.single,
            size: Point(2),
            color: Color(0xFF000080),
          ),
        ),
      ),
      columns: <GridColumn>[GridColumn(width: 1600)],
      rows: <TableRow>[
        TableRow(
          cells: <TableCell>[
            TableCell.one(
              cellConfig: TableCellConfig.dxa(
                width: 1600,
                shading: Shading.clear(fill: Color(0xFFF5F5F5)),
              ),
              child: Paragraph(
                children: <RunBase<dynamic>>[
                  TextRun.text(
                    text:
                        '"The best way to predict the future is to create it."',
                  ),
                ],
                textStyle: TextStyle(
                  italic: true,
                  fontSize: Point(11),
                  fontFamily: 'Georgia',
                  spacingBefore: Point(12),
                  spacingAfter: Point(5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const String _article1Paragraph1 =
    'In a groundbreaking announcement that has sent shockwaves through the scientific community, '
    'researchers at the National Renewable Energy Laboratory have unveiled a new type of solar cell '
    'that promises to revolutionize the way we think about clean energy. The new technology, which '
    'has been in development for over a decade, achieves an unprecedented 47% efficiency rate, '
    'significantly higher than the 25-30% typically achieved by commercial solar panels today.';

const String _article1Paragraph2 =
    'Dr. Sarah Chen, the lead researcher on the project, explained that the breakthrough came from '
    'a novel approach to capturing sunlight. "Traditional solar cells can only capture certain '
    'wavelengths of light," she said. "Our new material is designed to absorb across a much broader '
    'spectrum, including wavelengths that were previously inaccessible."';

const String _article1Paragraph3 =
    'The implications of this discovery are vast. Industry experts predict that if the technology '
    'can be scaled for commercial production, it could lead to a 50% reduction in the cost of solar '
    'energy generation. This would make solar power competitive with fossil fuels in many parts of '
    'the world, accelerating the transition to a low-carbon economy.';

const String _localNewsText1 =
    'The City Council voted unanimously Tuesday to approve funding for the construction of a new '
    'community park in the downtown area. The 5-acre park will feature walking trails, a children\'s '
    'playground, and a public garden. Construction is expected to begin in the spring and be '
    'completed by fall.';

const String _localNewsText2 =
    'The local school district has announced a variety of summer enrichment programs for students '
    'of all ages. Programs include STEM camps, arts workshops, and athletic clinics. Registration '
    'opens next month, and scholarships are available for qualifying families.';

const String _sportsText1 =
    'The hometown Tigers clinched their first championship title in 15 years with a thrilling '
    '42-38 victory over the rival Eagles Saturday night. Quarterback Mike Johnson threw for 350 '
    'yards and 4 touchdowns in the winning effort. The team will be honored at a rally '
    'scheduled for next Tuesday at City Hall.';

const String _opinionText1 =
    'As we face unprecedented challenges in the 21st century, from climate change to political '
    'division, it is more important than ever to strengthen our democratic institutions. This week, '
    'we examine the forces that threaten democratic governance and explore what citizens can do to '
    'protect and preserve our freedoms.';

const String _businessText1 =
    'The stock market surged to record highs this week, driven by strong earnings reports from '
    'major technology companies. The S&P 500 index closed above 5,000 for the first time in '
    'history, reflecting investor confidence in the economy\'s resilience despite ongoing '
    'challenges.';

const String _classifiedsText =
    'FOR SALE: Antique oak desk, excellent condition. \$250. Call 555-0123.\n\n'
    'FOR RENT: Charming 2BR apartment downtown. \$1,200/month. 555-0456.\n\n'
    'SERVICES: Professional lawn care. Free estimates. 555-0789.';
