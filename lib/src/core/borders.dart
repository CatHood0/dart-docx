import '../../../docx.dart';
import '../docx_sdk/utils/component_commons.dart';

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
/// final border = DocxBorder(
///   style: BorderStyle.single,
///   size: 4,
///   color: Color.rgb(0x336699),
/// );
///
/// // Border from pixels
/// final pixelBorder = DocxBorder.pixels(
///   style: BorderStyle.double,
///   size: 2, // 2 pixels
///   color: Color.rgb(0xFF0000),
/// );
/// ```
///
/// See also:
/// - [DocxBorders] for applying borders to multiple sides
/// - [DocxCellBorders] for cell-specific border configurations
class DocxBorder {
  /// Creates a new border with the specified properties.
  ///
  /// [style] is the border line style (default: single).
  /// [size] is the border thickness in eighths of a point (default: 4).
  /// [space] is the spacing between border and content in points (default: 0).
  /// [color] is the border color (default: auto/black).
  const DocxBorder({
    this.style = BorderStyle.single,
    this.size = 4,
    this.space = 0,
    this.color,
  });

  /// Creates a border with no visible line.
  const DocxBorder.none({
    this.size = 4,
    this.space = 0,
    this.color,
  }) : style = BorderStyle.none;

  /// Creates a border with nil style.
  const DocxBorder.nil({
    this.size = 4,
    this.space = 0,
    this.color,
  }) : style = BorderStyle.nil;

  /// Creates a border from pixel measurements.
  ///
  /// This is useful when you want to specify border size in pixels
  /// rather than points.
  ///
  /// [style] is the border line style.
  /// [size] is the border thickness in pixels (converted to points).
  /// [space] is the spacing in pixels (converted to points).
  /// [color] is the border color.
  DocxBorder.pixels({
    this.style = BorderStyle.single,
    int size = 1,
    int space = 0,
    this.color,
  })  : size = size.pixelsToPt(),
        space = space.pixelsToPt();

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
  final int size;

  /// Space between border and content in point units.
  ///
  /// This creates space between the border line and the content.
  /// Useful for creating visual separation between border and text.
  final int space;

  /// Border color in ARGB format.
  ///
  /// Use `Color(0xFF336699)` for RGB colors.
  /// If null, defaults to 'auto' (typically black).
  final Color? color;

  /// Returns true if this border should be drawn (not none or nil).
  bool get isVisible =>
      style != BorderStyle.none && style != BorderStyle.nil;
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
/// - [DocxBorder] for individual border properties
/// - [DocxCellBorders] for cell-specific borders
class DocxBorders {
  /// Creates a new borders configuration.
  const DocxBorders({
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
  const DocxBorders.all(
    DocxBorder? all, {
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
  const DocxBorders.symmetric({
    DocxBorder? vertical,
    DocxBorder? horizontal,
    this.insideHorizontal,
    this.insideVertical,
  })  : top = vertical,
        right = horizontal,
        bottom = vertical,
        left = horizontal;

  /// Top border of the table or element.
  final DocxBorder? top;

  /// Right border of the table or element.
  final DocxBorder? right;

  /// Bottom border of the table or element.
  final DocxBorder? bottom;

  /// Left border of the table or element.
  final DocxBorder? left;

  /// Horizontal borders between table rows.
  final DocxBorder? insideHorizontal;

  /// Vertical borders between table columns.
  final DocxBorder? insideVertical;
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
/// - [DocxBorder] for individual border properties
/// - [DocxBorders] for table-level borders
class DocxCellBorders {
  /// Creates a new cell borders configuration.
  const DocxCellBorders({
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  /// Creates borders with the same style on all four sides.
  const DocxCellBorders.all(DocxBorder? all)
      : top = all,
        right = all,
        bottom = all,
        left = all;

  /// Creates borders with no visible lines.
  const DocxCellBorders.none()
      : top = const DocxBorder.none(),
        right = const DocxBorder.none(),
        bottom = const DocxBorder.none(),
        left = const DocxBorder.none();

  /// Creates borders with nil style.
  const DocxCellBorders.nil()
      : top = const DocxBorder.nil(),
        right = const DocxBorder.nil(),
        bottom = const DocxBorder.nil(),
        left = const DocxBorder.nil();

  /// Creates symmetric borders (top/bottom same, left/right same).
  const DocxCellBorders.symmetric({
    DocxBorder? vertical,
    DocxBorder? horizontal,
  })  : top = vertical,
        right = horizontal,
        bottom = vertical,
        left = horizontal;

  /// Top border of the cell.
  final DocxBorder? top;

  /// Right border of the cell.
  final DocxBorder? right;

  /// Bottom border of the cell.
  final DocxBorder? bottom;

  /// Left border of the cell.
  final DocxBorder? left;
}

/// Border configuration for paragraph elements.
///
/// Provides control over the borders of a paragraph with support
/// for all four sides, similar to HTML/CSS borders.
///
/// Example usage:
/// ```dart
/// final paragraphBorders = ParagraphBorders(
///   top: DocxBorder(style: BorderStyle.single, size: 4),
///   bottom: DocxBorder(style: BorderStyle.double, size: 6, space: 4),
///   between: DocxBorder(style: BorderStyle.dotted),
/// );
/// ```
///
/// Common patterns:
/// ```dart
/// // Simple top and bottom border
/// final simple = ParagraphBorders.topBottom(
///   DocxBorder(style: BorderStyle.single, size: 4),
/// );
///
/// // Box around paragraph
/// final box = ParagraphBorders.all(
///   DocxBorder(style: BorderStyle.single),
/// );
/// ```
class ParagraphBorders {
  /// Creates a new paragraph borders configuration.
  ///
  /// [top], [bottom], [left], [right] set individual side borders.
  /// [between] sets a border between the paragraph and the next one.
  const ParagraphBorders({
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.between,
  });

  /// Creates borders with the same style on all four sides.
  const ParagraphBorders.all(DocxBorder? all)
      : top = all,
        right = all,
        bottom = all,
        left = all,
        between = null;

  /// Creates only top and bottom borders.
  const ParagraphBorders.topBottom(DocxBorder? border)
      : top = border,
        right = null,
        bottom = border,
        left = null,
        between = null;

  /// Creates only left border (commonly used for lists/quotes).
  const ParagraphBorders.leftOnly(DocxBorder? border)
      : top = null,
        right = null,
        bottom = null,
        left = border,
        between = null;

  /// Creates no borders (all null).
  const ParagraphBorders.none()
      : top = null,
        right = null,
        bottom = null,
        left = null,
        between = null;

  /// Top border of the paragraph.
  final DocxBorder? top;

  /// Right border of the paragraph.
  final DocxBorder? right;

  /// Bottom border of the paragraph.
  final DocxBorder? bottom;

  /// Left border of the paragraph.
  final DocxBorder? left;

  /// Border between this paragraph and the next one.
  /// This is commonly used in legal documents or when you want
  /// a border between paragraphs without affecting the paragraph itself.
  final DocxBorder? between;
}
