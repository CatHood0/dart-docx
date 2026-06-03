import '../../../utils/sizing_utils.dart';

/// Represents the width and optional spacing for an individual column.
class ColumnWidth {
  ColumnWidth({
    required this.width,
    this.spaceAfter,
  });

  ColumnWidth.points({
    required double width,
    int? spaceAfter,
  })  : width = width.ptToTwips(),
        spaceAfter = spaceAfter?.ptToTwips();

  ColumnWidth.pixels({
    required double width,
    int? spaceAfter,
  })  : width = width.pixelsToTwips(),
        spaceAfter = spaceAfter?.pixelsToTwips();

  ColumnWidth.inches({
    required double width,
    double? spaceAfter,
  })  : width = width.inchesToTwips(),
        spaceAfter = spaceAfter?.inchesToTwips();

  ColumnWidth.cm({
    required double width,
    double? spaceAfter,
  })  : width = width.centimetersToTwips(),
        spaceAfter = spaceAfter?.centimetersToTwips();

  ColumnWidth.mm({
    required double width,
    int? spaceAfter,
  })  : width = width.millimetersToTwips(),
        spaceAfter = spaceAfter?.millimetersToTwips();

  /// The width of the column in twips.
  final int width;

  /// The spacing after this column in twips.
  ///
  /// This spacing is applied between this column and the next one.
  final int? spaceAfter;
}

/// Defines the column layout for a section of the document.
///
/// [numColumns] The number of columns. If not provided, it implies a single column
/// unless specific [columnWidths] are given.
/// [space] The spacing between columns in twips.
/// [separator] Whether a vertical separator line should be shown between columns.
/// [equalWidth] If `true`, all columns will have equal width, and [columnWidths]
/// will be ignored for width calculations by Word. If `false`, you must provide
/// [columnWidths] for each column.
/// [columnWidths] A list of individual column width and spacing settings.
/// This is required if [equalWidth] is `false`.
class ColumnOptions {
  ColumnOptions({
    int? space,
    this.numColumns,
    this.separator = false,
    this.equalWidth = true,
    this.columnWidths,
  })  : space = space?.ptToTwips();

  /// The number of columns.
  final int? numColumns;

  /// The spacing between columns in twips.
  final int? space;

  /// Whether a vertical separator line should be shown between columns.
  final bool separator;

  /// Whether all columns should have equal width.
  /// If `true`, [columnWidths] are ignored for width distribution by Word.
  /// If `false`, [columnWidths] must be provided and define each column's width.
  final bool equalWidth;

  /// A list of individual column width and spacing settings.
  /// This is used when [equalWidth] is `false`.
  final List<ColumnWidth>? columnWidths;
}
