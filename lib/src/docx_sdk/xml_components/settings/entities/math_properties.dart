/// Options for configuring mathematical properties (`m:mathPr`).
class MathPropertiesOptions {
  /// Creates a new [MathPropertiesOptions] instance.
  ///
  /// [mathFont]: Specifies the default font for mathematical text.
  /// [breakBinary]: Specifies how binary operators are broken across lines.
  ///   Values: 'before', 'after', 'repeat'.
  /// [breakBinarySubtraction]: Specifies how subtraction operators are broken across lines.
  ///   Values: 'minusMinus', 'before', 'after'.
  /// [displayLoop]: Specifies whether math zones are displayed on a single line or wrapped.
  ///   Values: 'noBreak', 'break'.
  /// [integerLimit]: Specifies whether the math auto-correct integer limit is enabled.
  /// [wrapIndent]: Specifies the indent for wrapped math objects.
  const MathPropertiesOptions({
    this.mathFont,
    this.breakBinary,
    this.breakBinarySubtraction,
    this.displayLoop,
    this.integerLimit,
    this.wrapIndent,
  });

  /// The default font for mathematical text (e.g., 'Cambria Math').
  final String? mathFont;

  /// Specifies how binary operators (e.g., +, -) are broken across lines.
  final BreakBinaryType? breakBinary;

  /// Specifies how subtraction operators are broken across lines.
  final BreakBinarySubtractionType? breakBinarySubtraction;

  /// Specifies whether math zones are displayed on a single line or wrapped.
  final DisplayLoopType? displayLoop;

  /// Specifies whether the math auto-correct integer limit is enabled.
  final bool? integerLimit;

  /// Specifies the indent for wrapped math objects (in TWIPs).
  final String? wrapIndent;

  // Add more math properties as needed from the OOXML spec.
}

/// Specifies how binary operators (e.g., +, -) are broken across lines.
enum BreakBinaryType {
  /// Break before the binary operator.
  before('before'),

  /// Break after the binary operator.
  after('after'),

  /// Repeat the binary operator.
  repeat('repeat');

  const BreakBinaryType(this.value);
  final String value;
}

/// Specifies how subtraction operators are broken across lines.
enum BreakBinarySubtractionType {
  /// Use a double minus sign.
  minusMinus('minusMinus'),

  /// Break before the subtraction operator.
  before('before'),

  /// Break after the subtraction operator.
  after('after');

  const BreakBinarySubtractionType(this.value);
  final String value;
}

/// Specifies whether math zones are displayed on a single line or wrapped.
enum DisplayLoopType {
  /// Display on a single line (no break).
  noBreak('noBreak'),

  /// Allow wrapping.
  breakValue('break'); // Renamed to avoid conflict with keyword 'break'

  const DisplayLoopType(this.value);
  final String value;
}
