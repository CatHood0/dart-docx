import '../../../docx.dart';

/// Handles document margin specifications with support for multiple units.
///
/// This class provides a comprehensive way to define document margins (top,
/// right, left, bottom, header, footer, and gutter) with conversion between
/// different measurement units commonly used in document processing:
/// - dxa (twentieths of a point)
/// - centimeters (cm)
/// - points (pt)
/// - inches (in)
///
/// Example usage:
/// ```dart
/// // Create margins from centimeters
/// final margins = DocumentMargins.fromCm(
///   top: 2.5,
///   right: 2.5,
///   left: 3.0,
///   bottom: 2.5,
///   header: 1.0, // if defined component, header is mandatory
///   footer: 1.0, // if footer component, header is mandatory
///   gutter: 0.0,
/// );
///
/// // Convert to inches
/// final marginsInInches = margins.toInches();
/// ```
class DocumentMargins {
  const DocumentMargins({
    required this.top,
    required this.right,
    required this.left,
    required this.bottom,
    this.header,
    this.footer,
    this.gutter,
  });

  /// Creates a [DocumentMargins] instance from centimeter values.
  ///
  /// All values are automatically converted to dxa units using
  /// [centimetersToDxa] extension method.
  DocumentMargins.fromCm({
    required num top,
    required num right,
    required num left,
    required num bottom,
    num? header,
    num? footer,
    num? gutter,
  })  : top = top.centimetersToDxa(),
        right = right.centimetersToDxa(),
        left = left.centimetersToDxa(),
        bottom = bottom.centimetersToDxa(),
        header = header?.centimetersToDxa(),
        footer = footer?.centimetersToDxa(),
        gutter = gutter?.centimetersToDxa();

  /// Creates a [DocumentMargins] instance from point values.
  ///
  /// All values are automatically converted to dxa units using
  /// [ptToDxa] extension method.
  DocumentMargins.fromPoints({
    required num top,
    required num right,
    required num left,
    required num bottom,
    num? header,
    num? footer,
    num? gutter,
  })  : top = top.ptToDxa(),
        right = right.ptToDxa(),
        left = left.ptToDxa(),
        bottom = bottom.ptToDxa(),
        header = header?.ptToDxa(),
        footer = footer?.ptToDxa(),
        gutter = gutter?.ptToDxa();

  /// Creates a [DocumentMargins] instance from inch values.
  ///
  /// All values are automatically converted to dxa units using
  /// [inchesToDxa] extension method.
  DocumentMargins.fromInches({
    required num top,
    required num right,
    required num left,
    required num bottom,
    num? header,
    num? footer,
    num? gutter,
  })  : top = top.inchesToDxa(),
        right = right.inchesToDxa(),
        left = left.inchesToDxa(),
        bottom = bottom.inchesToDxa(),
        header = header?.inchesToDxa(),
        footer = footer?.inchesToDxa(),
        gutter = gutter?.inchesToDxa();

  /// Converts the current margin values from dxa to inches.
  ///
  /// Returns a new [DocumentMargins] instance with all values converted
  /// to inches using [dxaToInches] extension method.
  ///
  /// Useful for displaying margin values in inch-based interfaces.
  DocumentMargins toInches() {
    return DocumentMargins(
      top: top.dxaToInches(),
      right: right.dxaToInches(),
      left: left.dxaToInches(),
      bottom: bottom.dxaToInches(),
      header: header?.dxaToInches(),
      footer: footer?.dxaToInches(),
      gutter: gutter?.dxaToInches(),
    );
  }

  /// Top margin in dxa units (twentieths of a point).
  final num top;

  /// Right margin in dxa units (twentieths of a point).
  final num right;

  /// Left margin in dxa units (twentieths of a point).
  final num left;

  /// Bottom margin in dxa units (twentieths of a point).
  final num bottom;

  /// Header margin in dxa units (twentieths of a point).
  /// Represents the distance from the top of the page to the header content.
  final num? header;

  /// Footer margin in dxa units (twentieths of a point).
  /// Represents the distance from the bottom of the page to the footer content.
  final num? footer;

  /// Gutter margin in dxa units (twentieths of a point).
  /// Represents additional space added to the inside margins for binding.
  final num? gutter;
}
