import '../../../../../docx.dart';

/// Configuration for an individual table cell in DOCX documents.
///
/// The `TableCellConfig` class defines all configurable properties for
/// a single table cell, including dimensions, merging behavior,
/// alignment, borders, and background styling. This configuration is
/// used when creating `TableCell` objects to customize their appearance
/// and behavior.
///
/// Example usage:
/// ```dart
/// TableCellConfig(
///   width: 3000,
///   widthType: TableWidthType.dxa,
///   gridSpan: 2,  // Spans 2 columns (colspan)
///   rowSpan: 3,   // Spans 3 rows (rowspan)
///   verticalAlignment: VerticalAlignment.center,
///   borders: TableCellBorders(
///     top: TableBorder(style: BorderStyle.double, size: 8),
///     bottom: TableBorder(style: BorderStyle.single, size: 4),
///   ),
///   shading: Shading(
///     fill: Color.rgb(0xFFE6E6),
///     style: ShadingPattern.clear,
///   ),
/// );
/// ```
class TableCellConfig {
  const TableCellConfig({
    required this.width,
    required this.widthType,
    this.columnSpan,
    this.rowSpan,
    this.verticalAlignment,
    TableCellBorders? borders,
    this.shading,
  })  : assert(width >= 0, 'width cannot be less than zero'),
        assert(width != 0 || widthType != TableWidthType.expand || width == 0 && widthType == TableWidthType.expand,
            'widthType of type expand requires that width property be zero or less'),
        assert(width == 0 && widthType == TableWidthType.auto || width != 0 && widthType != TableWidthType.auto,
            'TableWidthType.auto can only be used when width is zero or less'),
        borders = borders ?? singleBorders;

  const TableCellConfig.dxa({
    required this.width,
    this.columnSpan,
    this.rowSpan,
    this.verticalAlignment,
    TableCellBorders? borders,
    this.shading,
  })  : widthType = TableWidthType.dxa,
        assert(width > 0, 'width cannot be less than one when TableWidthType is not auto'),
        borders = borders ?? singleBorders;

  const TableCellConfig.pct({
    required this.width,
    this.columnSpan,
    this.rowSpan,
    this.verticalAlignment,
    TableCellBorders? borders,
    this.shading,
  })  : assert(width > 0, 'width cannot be less than one when TableWidthType is not auto'),
        widthType = TableWidthType.pct,
        borders = borders ?? singleBorders;

  /// Let to the Word table to fill the row as well as the content require
  const TableCellConfig.auto({
    this.rowSpan,
    this.columnSpan,
    this.verticalAlignment,
    TableCellBorders? borders,
    this.shading,
  })  : width = 0,
        widthType = TableWidthType.auto,
        borders = borders ?? singleBorders;

  const TableCellConfig.nil({
    this.rowSpan,
    this.columnSpan,
    this.verticalAlignment,
    TableCellBorders? borders,
    this.shading,
  })  : width = 0,
        widthType = TableWidthType.nil,
        borders = borders ?? singleBorders;

  static const TableCellBorders singleBorders = TableCellBorders.all(
    BorderSide(style: BorderStyle.single),
  );

  static final TableCellBorders noneBorders = TableCellBorders.all(
    BorderSide(style: BorderStyle.none),
  );

  static final TableCellBorders dotBorders = TableCellBorders.all(
    BorderSide(style: BorderStyle.dotted),
  );

  static final TableCellBorders waveBorders = TableCellBorders.all(
    BorderSide(style: BorderStyle.wave),
  );

  /// Cell width specification.
  ///
  /// When combined with `widthType`, determines the cell's horizontal
  /// dimension. Can be specified in various units (twips, percentage, etc.).
  /// Use `null` for automatic width calculation based on content.
  final int width;

  /// Unit type for the cell width measurement.
  ///
  /// Determines how the `width` value is interpreted:
  /// - `TableWidthType.dxa`: Twips (1/1440 inch)
  /// - `TableWidthType.pct`: Percentage of table width
  /// - `TableWidthType.auto`: Automatic sizing based on content
  /// - `TableWidthType.nil`: No specific width (inherits from table)
  final TableWidthType widthType;

  /// Number of columns the cell spans horizontally (colspan).
  ///
  /// - `null` or `1`: Cell occupies a single column (default)
  /// - `>1`: Cell spans the specified number of columns
  ///
  /// Example: `gridSpan: 3` creates a cell that spans 3 columns.
  final int? columnSpan;

  /// Number of rows the cell spans vertically (rowspan).
  ///
  /// - `null`: No vertical merging (default)
  /// - `0`: Continues an existing vertical merge from a previous row
  /// - `>1`: Starts a vertical merge spanning the specified number of rows
  ///
  /// Example usage for a 3-row merge:
  /// ```dart
  /// // First row: start the merge
  /// TableCellConfig(rowSpan: 3),
  ///
  /// // Second row: continue the merge
  /// TableCellConfig(rowSpan: 0),
  ///
  /// // Third row: continue the merge
  /// TableCellConfig(rowSpan: 0),
  /// ```
  final int? rowSpan;

  /// Vertical alignment of content within the cell.
  ///
  /// Controls how content is positioned vertically within the cell's
  /// available space. Useful for cells with fixed heights or for
  /// aligning content consistently across rows.
  ///
  /// Options:
  /// - `VerticalAlignment.top`: Align content to the top
  /// - `VerticalAlignment.center`: Center content vertically
  /// - `VerticalAlignment.bottom`: Align content to the bottom
  final VerticalAlignment? verticalAlignment;

  /// Border configuration specific to this individual cell.
  ///
  /// Allows custom border styling on a per-cell basis, overriding
  /// any table-wide border settings. Each side can be configured
  /// independently with its own style, thickness, and color.
  ///
  /// Defaults to single-line borders on all sides when not specified.
  final TableCellBorders? borders;

  /// Background fill/shading for the cell.
  ///
  /// Applies color and pattern fills to the cell background. Can be
  /// used for highlighting, categorization, or visual separation of
  /// table cells.
  ///
  /// Example:
  /// ```dart
  /// shading: Shading(
  ///   fill: Color.rgb(0xFFCCCC),
  ///   style: ShadingPattern.diagStripe,
  /// ),
  /// ```
  final Shading? shading;
}
