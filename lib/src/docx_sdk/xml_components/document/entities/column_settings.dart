import '../../../utils/sizing_utils.dart';

/// Represents the width and optional spacing for an individual column.
class ColumnWidthSetting {
  ColumnWidthSetting({
    required int width,
    this.spaceAfter,
  }) : width = width.toTwipsFromPoints();

  /// The width of the column in twips.
  final int width;

  /// The spacing after this column in twips.
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
class ColumnSettings {
  ColumnSettings({
    int? space,
    this.numColumns,
    this.separator = false,
    // Default to equal width for simplicity
    this.equalWidth = true,
    this.columnWidths,
  })  : space = space?.toTwipsFromPoints(),
        assert(
          equalWidth == true || columnWidths != null && columnWidths.isNotEmpty,
          'If equalWidth is false, columnWidths must be provided.',
        );

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
  final List<ColumnWidthSetting>? columnWidths;
}
