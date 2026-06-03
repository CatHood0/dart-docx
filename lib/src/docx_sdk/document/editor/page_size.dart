import '../../../../docx.dart';

/// Represents page dimensions with unit conversion capabilities.
///
/// This class provides a flexible way to define and manipulate page sizes
/// with support for multiple units: centimeters, millimeters, inches, and
/// DXA (twentieths of a point). It includes predefined standard page sizes
/// and methods for unit conversion and orientation changes.
///
/// DXA (twentieths of a point) is the internal unit used by Microsoft Word
/// for page dimensions (1 DXA = 1/20 point, 1 point = 1/72 inch).
///
/// Example usage:
/// ```dart
/// // Create A4 page size
/// final a4 = PageSize.a4;
/// print(a4.inCm); // (21.0, 29.7)
///
/// // Create custom page size from inches
/// final custom = PageSize.fromInches(8.5, 11.0);
///
/// // Convert to landscape orientation
/// final landscape = custom.toLandscape();
/// ```
class PageSize {
  /// Creates a page size from centimeter values, converting to DXA units.
  PageSize.fromCm(double width, double height)
      : width = Dxa(width.toCentimenters().toDxa()),
        height = Dxa(height.toCentimenters().toDxa()) {
    assert(height > 0, 'Height must be greater than 0');
    assert(width > 0, 'Width must be greater than 0');
  }

  /// Creates a page size from millimeter values.
  PageSize.fromMm(double width, double height)
      : width = Dxa(width.toMillimeter().toDxa()),
        height = Dxa(height.toMillimeter().toDxa()) {
    assert(height > 0, 'Height must be greater than 0');
    assert(width > 0, 'Width must be greater than 0');
  }

  PageSize.fromPixels(double width, double height)
      : width = Dxa(width.toPixels().toDxa()),
        height = Dxa(height.toPixels().toDxa()) {
    assert(height > 0, 'Height must be greater than 0');
    assert(width > 0, 'Width must be greater than 0');
  }

  /// Creates a page size from inch values.
  PageSize.fromInches(double widthIn, double heightIn)
      : this.fromCm(widthIn * 2.54, heightIn * 2.54);

  PageSize.fromUnitValue(this.width, this.height);

  /// The width of the page in DXA units (twentieths of a point).
  final UnitValue width;

  /// The height of the page in DXA units (twentieths of a point).
  final UnitValue height;

  /// Standard A4 page size: 21.0 cm × 29.7 cm.
  static PageSize get a4 => PageSize.fromCm(21.0, 29.7);

  /// Standard US Letter page size: 21.59 cm × 27.94 cm.
  static PageSize get letter => PageSize.fromCm(21.59, 27.94);

  /// Standard US Legal page size: 21.59 cm × 35.56 cm.
  static PageSize get legal => PageSize.fromCm(21.59, 35.56);

  /// Standard A5 page size: 14.8 cm × 21.0 cm.
  static PageSize get a5 => PageSize.fromCm(14.8, 21.0);

  /// Standard A3 page size: 29.7 cm × 42.0 cm.
  static PageSize get a3 => PageSize.fromCm(29.7, 42.0);

  /// Converts the page size to centimeter-based values.
  ///
  /// Returns: A new [PageSize] instance with raw centimeter values.
  PageSize toCm() {
    final (double, double) values = inCm;
    return PageSize.fromUnitValue(
      values.$1.toInt().toCentimenters(),
      values.$2.toInt().toCentimenters(),
    );
  }

  /// Converts the page size to inch-based values.
  ///
  /// Returns: A new [PageSize] instance with raw inch values.
  PageSize toInches() {
    final (double, double) values = inInches;
    return PageSize.fromUnitValue(values.$1.toInt().toInch(), values.$2.toInt().toInch());
  }

  /// Gets the page dimensions in centimeters as a tuple.
  ///
  /// Returns: A tuple (width, height) in centimeters.
  (double, double) get inCm =>
      (width.toCm().toDouble(), height.toCm().toDouble());

  /// Gets the page dimensions in millimeters as a tuple.
  ///
  /// Returns: A tuple (width, height) in millimeters.
  (double, double) get inMm {
    return (width.toMm().toDouble(), height.toMm().toDouble());
  }

  /// Gets the page dimensions in inches as a tuple.
  ///
  /// Returns: A tuple (width, height) in inches.
  (double, double) get inInches {
    return (width.toInches().toDouble(), height.toInches().toDouble());
  }

  /// Converts the page to landscape orientation.
  ///
  /// Swaps the width and height values to create a landscape-oriented page.
  /// If the page is already in landscape (width > height), returns a copy.
  ///
  /// Returns: A new [PageSize] in landscape orientation.
  PageSize toLandscape() => PageSize.fromUnitValue(height, width);

  /// Converts the page to portrait orientation.
  ///
  /// Ensures the smaller dimension is width and the larger is height.
  /// If the page is already in portrait (height >= width), returns a copy.
  ///
  /// Returns: A new [PageSize] in portrait orientation.
  PageSize toPortrait() => PageSize.fromUnitValue(
        width < height ? width : height,
        width > height ? width : height,
      );

  @override
  String toString() {
    return 'PageSettings(${width.toPixels().toStringAsFixed(1)}'
        '×'
        '${height.toPixels().toStringAsFixed(1)})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageSize &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}
