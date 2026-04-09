import 'package:xml/xml.dart';

import '../../../../../../docx.dart';
import '../../../../../core/extensions/string_ext.dart';

/// Document table with configurable rows and cells.
///
/// Tables in DOCX support multiple elements per cell (paragraphs,
/// images, lists, etc.). This component allows creating tables with
/// customizable properties such as borders, width, alignment, and styles.
///
/// The `Table` class is the main container for table structures in DOCX documents.
/// It manages the overall table configuration, column definitions, and row organization.
///
/// Example usage:
/// ```dart
/// final table = Table(
///   rows: [
///     TableRow(
///       cells: [
///         TableCell(
///           children: [
///             Paragraph.text(text: 'Cell 1'),
///             Paragraph.text(text: 'Second paragraph in same cell'),
///           ],
///           cellConfig: TableCellConfig(width: 2000),
///         ),
///         TableCell(
///           children: [Paragraph.text(text: 'Cell 2')],
///         ),
///       ],
///       rowConfig: TableRowConfig(height: 500),
///     ),
///   ],
///   tableConfig: TableConfig(
///     style: Style.reference('TableGrid'),
///     alignment: Alignment.center,
///   ),
///   gridCols: [GridColumn(width: 2000), GridColumn(width: 3000)],
/// );
/// ```
class Table extends DocxTreeNode<List<TableRow>> {
  Table({
    required List<TableRow> rows,
    required this.gridCols,
    this.tableConfig,
    super.id,
    super.parent,
  })  : assert(gridCols.length == rows.length, 'grid'),
        super(child: rows) {
    int rowIndex = 0;
    for (final TableRow row in child) {
      row
        ..parent = this
        ..index = rowIndex
        ..depth = depth + 1;
      rowIndex++;
    }
  }

  /// Configuration for the entire table, including styles,
  /// borders, alignment, and layout properties.
  final TableProperties? tableConfig;

  /// Definition of column widths for the table.
  ///
  /// Each `GridColumn` specifies the width of its corresponding column.
  /// The number of `GridColumn` objects must match the number of cells
  /// in each row. Use width `-1` for automatic column sizing.
  final List<GridColumn> gridCols;

  @override
  List<XmlElement> buildXml({required DocumentContext context}) {
    context.currentContentPart = this;

    final List<XmlNode> tableChildren = <XmlNode>[];

    // Build table properties (tblPr) if configuration exists
    final List<XmlNode> tblPrNodes = tableConfig == null
        ? <XmlNode>[]
        : tableConfig!.buildXml(context: context);
    if (tblPrNodes.isNotEmpty) {
      tableChildren.add(
        XmlElement.tag(
          'w:tblPr',
          children: tblPrNodes,
          isSelfClosing: false,
        ),
      );
    }

    // Build column grid definitions (tblGrid)
    final List<XmlNode> gridCols = <XmlNode>[];
    for (final GridColumn option in this.gridCols) {
      gridCols.add(
        XmlElement.tag(
          'w:gridCol',
          attributes: <XmlAttribute>[
            if (option.width >= 0)
              XmlAttribute(
                'w:w'.toName(),
                option.width.toString(),
              ),
          ],
          isSelfClosing: true,
        ),
      );
    }
    tableChildren.add(
      XmlElement.tag(
        'w:tblGrid',
        children: gridCols,
        isSelfClosing: false,
      ),
    );

    // Build all table rows
    for (final TableRow row in child) {
      final List<XmlElement> rowXml = row.buildXml(context: context);
      tableChildren.addAll(rowXml);
    }

    return <XmlElement>[
      XmlElement.tag(
        'w:tbl',
        children: tableChildren,
        isSelfClosing: false,
      ),
    ];
  }

  @override
  Table get copy => Table(
        id: id,
        rows: child,
        tableConfig: tableConfig,
        gridCols: gridCols,
        parent: parent,
      );

  @override
  DocxTreeNode? visitElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = false,
  }) {
    for (final TableRow element in child) {
      if (element.isEmptyNode()) continue;
      if (shouldGetElement(element)) {
        return element;
      } else if (visitChildrenIfNeeded) {
        final DocxTreeNode? foundedEl = element.visitElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          return foundedEl;
        }
      }
    }
    return null;
  }

  @override
  List<DocxTreeNode>? visitAllElement(
    bool Function(DocxTreeNode element) shouldGetElement, {
    bool visitChildrenIfNeeded = true,
  }) {
    if (child.isEmpty) return <DocxTreeNode>[];
    final List<DocxTreeNode> elements = <DocxTreeNode>[];
    for (final TableRow element in child) {
      if (element.isEmptyNode()) continue;
      if (shouldGetElement(element)) {
        elements.add(element);
      } else if (visitChildrenIfNeeded) {
        final List<DocxTreeNode<dynamic>>? foundedEl = element.visitAllElement(
          shouldGetElement,
          visitChildrenIfNeeded: true,
        );
        if (foundedEl != null) {
          elements.addAll(foundedEl);
        }
      }
    }
    return elements;
  }
}

/// Represents the width for an individual column in a table.
///
/// This class provides constructors for different measurement units
/// that automatically convert to twips (1/1440 of an inch) which is
/// the standard unit used in DOCX documents.
///
/// Example usage:
/// ```dart
/// // Fixed width in twips
/// GridColumn(width: 2500),
///
/// // Width in points (1 point = 20 twips)
/// GridColumn.points(width: 72.0), // 1 inch = 72 points
///
/// // Width in inches
/// GridColumn.inches(width: 1.5),
///
/// // Width in centimeters
/// GridColumn.cm(width: 3.81), // approximately 1.5 inches
///
/// // Width in millimeters
/// GridColumn.mm(width: 38.1), // approximately 1.5 inches
///
/// // Auto width (adjusts to content)
/// GridColumn(width: -1),
/// ```
class GridColumn {
  GridColumn({
    this.width = -1,
  });

  /// Creates a `GridColumn` with width specified in points.
  ///
  /// Points are a typographic measurement unit (1 point = 1/72 inch).
  GridColumn.points({
    required double width,
  }) : width = width.ptToTwips();

  /// Creates a `GridColumn` with width specified in inches.
  GridColumn.inches({
    required double width,
  }) : width = width.inchesToTwips();

  /// Creates a `GridColumn` with width specified in centimeters.
  GridColumn.cm({
    required double width,
  }) : width = width.centimetersToTwips();

  /// Creates a `GridColumn` with width specified in millimeters.
  GridColumn.mm({
    required double width,
  }) : width = width.millimetersToTwips();

  /// The width of the column in twips (1/1440 of an inch).
  ///
  /// Common values:
  /// - `-1`: Auto width (adjusts to content)
  /// - `1000`: Approximately 0.7 inches
  /// - `2500`: Approximately 1.74 inches
  /// - `5000`: Approximately 3.47 inches
  final int width;
}
