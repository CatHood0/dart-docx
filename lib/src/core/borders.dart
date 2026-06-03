import '../../../docx.dart';

export '../../../docx.dart' show Color;
export '../docx_sdk/utils/component_commons.dart' show BorderStyle;

/// Definition of an individual border with style, thickness, spacing, and color.
///
/// Represents a single border line with configurable appearance.
/// The `size` property is measured in eighths of a point (so 4 = 0.5pt,
/// 8 = 1pt, 16 = 2pt, etc.).
///
/// Example usage:
/// ```dart
/// // Simple border
/// final border = BorderSide(
///   style: BorderStyle.single,
///   size: 4,
///   color: Color.rgb(0x336699),
/// );
///
/// // Border from pixels
/// final pixelBorder = BorderSide.pixels(
///   style: BorderStyle.double,
///   size: 2, // 2 pixels
///   color: Color.rgb(0xFF0000),
/// );
/// ```
///
/// See also:
/// - [TableBorders] for applying borders to multiple sides
/// - [TableCellBorders] for cell-specific border configurations
class BorderSide {
  /// Creates a new border with the specified properties.
  ///
  /// [style] is the border line style (default: single).
  /// [size] is the border thickness in eighths of a point (default: 4).
  /// [space] is the spacing between border and content in points (default: 0).
  /// [color] is the border color (default: auto/black).
  const BorderSide({
    this.style = BorderStyle.single,
    this.size = const Point(4),
    this.space = const Point(0),
    this.color,
  });

  /// Creates a border with no visible line.
  const BorderSide.none({
    this.size = const Point(4),
    this.space = const Point(0),
    this.color,
  }) : style = BorderStyle.none;

  /// Creates a border with nil style.
  const BorderSide.nil({
    this.size = const Point(4),
    this.space = const Point(0),
    this.color,
  }) : style = BorderStyle.nil;

  /// Border line style.
  ///
  /// Determines the visual appearance of the border line.
  /// Common values include single, double, dotted, dashed, and wave.
  final BorderStyle style;

  /// Border thickness in eighths of a point.
  ///
  /// Common values:
  /// - `4` = 0.5 points (default, thin border)
  /// - `6` = 0.75 points
  /// - `8` = 1 point
  /// - `12` = 1.5 points
  /// - `16` = 2 points
  /// - `24` = 3 points (thick border)
  final UnitValue size;

  /// Space between border and content in point units.
  ///
  /// This creates space between the border line and the content.
  /// Useful for creating visual separation between border and text.
  final UnitValue space;

  /// Border color in ARGB format.
  ///
  /// Use `Color(0xFF336699)` for RGB colors.
  /// If null, defaults to 'auto' (typically black).
  final Color? color;

  /// Returns true if this border should be drawn (not none or nil).
  bool get isVisible => style != BorderStyle.none && style != BorderStyle.nil;
}

/// Border configuration for table elements.
///
/// Allows individual control over all border sides of a table including
/// external borders and internal grid lines. Each side can have its own
/// style, thickness, and color.
///
/// Example usage:
/// ```dart
/// final borders = DocxBorders(
///   top: DocxBorder(style: BorderStyle.double, size: 8),
///   bottom: DocxBorder(style: BorderStyle.double, size: 8),
///   insideHorizontal: DocxBorder(style: BorderStyle.dotted),
///   insideVertical: DocxBorder(style: BorderStyle.dashed),
/// );
/// ```
///
/// Or use the factory constructors for common configurations:
/// ```dart
/// // All borders the same
/// final allSame = DocxBorders.all(DocxBorder(style: BorderStyle.single));
///
/// // Symmetric borders (top/bottom same, left/right same)
/// final symmetric = DocxBorders.symmetric(
///   vertical: DocxBorder(style: BorderStyle.thick),
///   horizontal: DocxBorder(style: BorderStyle.single),
/// );
/// ```
///
/// See also:
/// - [BorderSide] for individual border properties
/// - [TableCellBorders] for cell-specific borders
class TableBorders {
  /// Creates a new borders configuration.
  const TableBorders({
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.insideHorizontal,
    this.insideVertical,
  });

  /// Creates borders with the same style on all four outer sides.
  ///
  /// [all] is the border to apply to all sides.
  /// [insideHorizontal] and [insideVertical] override the inner borders.
  const TableBorders.all(
    BorderSide? all, {
    this.insideHorizontal,
    this.insideVertical,
  })  : top = all,
        right = all,
        bottom = all,
        left = all;

  /// Creates borders with symmetric configuration.
  ///
  /// [vertical] applies to top and bottom.
  /// [horizontal] applies to left and right.
  const TableBorders.symmetric({
    BorderSide? vertical,
    BorderSide? horizontal,
    this.insideHorizontal,
    this.insideVertical,
  })  : top = vertical,
        right = horizontal,
        bottom = vertical,
        left = horizontal;

  /// Top border of the table or element.
  final BorderSide? top;

  /// Right border of the table or element.
  final BorderSide? right;

  /// Bottom border of the table or element.
  final BorderSide? bottom;

  /// Left border of the table or element.
  final BorderSide? left;

  /// Horizontal borders between table rows.
  final BorderSide? insideHorizontal;

  /// Vertical borders between table columns.
  final BorderSide? insideVertical;
}

/// Border configuration for individual table cells.
///
/// Provides control over the borders of specific cells within a table.
/// This allows for custom border styling on a per-cell basis, independent
/// of the overall table border configuration.
///
/// Example usage:
/// ```dart
/// final cellBorders = DocxCellBorders(
///   top: DocxBorder(style: BorderStyle.single, color: Color.rgb(0xFF0000)),
///   bottom: DocxBorder(style: BorderStyle.double, size: 8),
/// );
/// ```
///
/// Or use factory constructors for common patterns:
/// ```dart
/// // All borders the same
/// final allSame = DocxCellBorders.all(DocxBorder(style: BorderStyle.single));
///
/// // No visible borders
/// final noBorders = DocxCellBorders.none();
///
/// // Nil borders (used in some Word document scenarios)
/// final nilBorders = DocxCellBorders.nil();
/// ```
///
/// See also:
/// - [BorderSide] for individual border properties
/// - [TableBorders] for table-level borders
class TableCellBorders {
  /// Creates a new cell borders configuration.
  const TableCellBorders({
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  /// Creates borders with the same style on all four sides.
  const TableCellBorders.all(BorderSide? all)
      : top = all,
        right = all,
        bottom = all,
        left = all;

  /// Creates borders with no visible lines.
  const TableCellBorders.none()
      : top = const BorderSide.none(),
        right = const BorderSide.none(),
        bottom = const BorderSide.none(),
        left = const BorderSide.none();

  /// Creates borders with nil style.
  const TableCellBorders.nil()
      : top = const BorderSide.nil(),
        right = const BorderSide.nil(),
        bottom = const BorderSide.nil(),
        left = const BorderSide.nil();

  /// Creates symmetric borders (top/bottom same, left/right same).
  const TableCellBorders.symmetric({
    BorderSide? vertical,
    BorderSide? horizontal,
  })  : top = vertical,
        right = horizontal,
        bottom = vertical,
        left = horizontal;

  /// Top border of the cell.
  final BorderSide? top;

  /// Right border of the cell.
  final BorderSide? right;

  /// Bottom border of the cell.
  final BorderSide? bottom;

  /// Left border of the cell.
  final BorderSide? left;
}

/// Border configuration for paragraph elements.
///
/// Provides control over the borders of a paragraph with support
/// for all four sides, similar to HTML/CSS borders.
///
/// Example usage:
/// ```dart
/// final paragraphBorders = Borders(
///   top: DocxBorder(style: BorderStyle.single, size: 4),
///   bottom: DocxBorder(style: BorderStyle.double, size: 6, space: 4),
///   between: DocxBorder(style: BorderStyle.dotted),
/// );
/// ```
///
/// Common patterns:
/// ```dart
/// // Simple top and bottom border
/// final simple = Borders.topBottom(
///   DocxBorder(style: BorderStyle.single, size: 4),
/// );
///
/// // Box around paragraph
/// final box = Borders.all(
///   DocxBorder(style: BorderStyle.single),
/// );
/// ```
class Borders {
  /// Creates a new paragraph borders configuration.
  ///
  /// [top], [bottom], [left], [right] set individual side borders.
  /// [between] sets a border between the paragraph and the next one.
  const Borders({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.between,
  });

  /// Creates borders with the same style on all four sides.
  const Borders.all(BorderSide? all)
      : top = all,
        right = all,
        bottom = all,
        left = all,
        between = null;

  /// Creates only top and bottom borders.
  const Borders.vertical(BorderSide? border)
      : top = border,
        right = null,
        bottom = border,
        left = null,
        between = null;

  /// Creates only left border (commonly used for lists/quotes).
  const Borders.left(BorderSide? border)
      : top = null,
        right = null,
        bottom = null,
        left = border,
        between = null;

  const Borders.right(BorderSide? border)
      : top = null,
        right = border,
        bottom = null,
        left = null,
        between = null;

  const Borders.top(BorderSide? border)
      : top = border,
        right = null,
        bottom = null,
        left = null,
        between = null;

  const Borders.bottom(BorderSide? border)
      : top = null,
        right = null,
        bottom = border,
        left = null,
        between = null;

  /// Top border of the paragraph.
  final BorderSide? top;

  /// Right border of the paragraph.
  final BorderSide? right;

  /// Bottom border of the paragraph.
  final BorderSide? bottom;

  /// Left border of the paragraph.
  final BorderSide? left;

  /// Border between this paragraph and the next one.
  /// This is commonly used in legal documents or when you want
  /// a border between paragraphs without affecting the paragraph itself.
  final BorderSide? between;
}
